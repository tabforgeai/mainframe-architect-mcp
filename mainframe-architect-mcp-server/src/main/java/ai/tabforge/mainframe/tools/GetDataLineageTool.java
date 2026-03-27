package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.CobolProgram;
import ai.tabforge.mainframe.model.DependencyGraph;
import ai.tabforge.mainframe.model.JclJob;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;

/**
 * Tool 4: get_data_lineage
 */
public class GetDataLineageTool {

    private static final Logger log = LoggerFactory.getLogger(GetDataLineageTool.class);
    private static final String TOOL_NAME = "get_data_lineage";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {
            "field_name": {
              "type": "string",
              "description": "Data field name to trace (e.g. CUSTOMER-BALANCE)"
            },
            "copybook": {
              "type": "string",
              "description": "Optional: copybook where the field is defined (e.g. CUSTMAST)"
            }
          },
          "required": ["field_name"]
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public GetDataLineageTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Traces a COBOL data field across the entire repository: where it is defined " +
                "(copybook), which programs reference it, and which JCL jobs are affected.")
            .inputSchema(jsonMapper, INPUT_SCHEMA)
            .build();

        return new McpServerFeatures.AsyncToolSpecification(tool, (exchange, request) -> {
            String fieldName   = (String) request.arguments().get("field_name");
            String copybookArg = (String) request.arguments().get("copybook");
            log.info("Tool {}: field_name={}, copybook={}", TOOL_NAME, fieldName, copybookArg);
            return Mono.fromCallable(() -> execute(fieldName, copybookArg))
                .map(text -> McpSchema.CallToolResult.builder().addTextContent(text).build());
        });
    }

    private String execute(String fieldName, String copybookName) throws Exception {
        ObjectNode result = jackson.createObjectNode();
        result.put("field", fieldName.toUpperCase());

        // 1. Find defining copybook
        String definedIn = "unknown";
        if (copybookName != null) {
            definedIn = copybookName.toUpperCase();
        } else {
            for (var cb : graph.allCopybooks()) {
                boolean found = cb.getFields().stream()
                    .anyMatch(f -> f.getName().equalsIgnoreCase(fieldName));
                if (found) {
                    definedIn = cb.getName() + " (" + cb.getFilePath() + ")";
                    break;
                }
            }
        }
        result.put("defined_in", definedIn);

        // 2. Programs referencing this field (working storage) + programs COPYing the copybook
        List<CobolProgram> referencingPrograms = graph.programsWithField(fieldName);
        if (copybookName != null) {
            for (CobolProgram p : graph.programsUsing(copybookName)) {
                if (referencingPrograms.stream().noneMatch(r -> r.getName().equals(p.getName()))) {
                    referencingPrograms.add(p);
                }
            }
        }
        result.set("referenced_by_programs",
            jackson.valueToTree(referencingPrograms.stream().map(CobolProgram::getName).toList()));

        // 3. JCL jobs invoking those programs
        List<String> affectedJobs = new ArrayList<>();
        for (CobolProgram p : referencingPrograms) {
            for (JclJob job : graph.jobsCallingProgram(p.getName())) {
                if (!affectedJobs.contains(job.getName())) affectedJobs.add(job.getName());
            }
        }
        result.set("appears_in_jobs", jackson.valueToTree(affectedJobs));

        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
