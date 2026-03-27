package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.Copybook;
import ai.tabforge.mainframe.model.CobolProgram;
import ai.tabforge.mainframe.model.DependencyGraph;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;

import java.util.Optional;

/**
 * Tool 2: identify_copybooks
 */
public class IdentifyCopybooksTool {

    private static final Logger log = LoggerFactory.getLogger(IdentifyCopybooksTool.class);
    private static final String TOOL_NAME = "identify_copybooks";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {
            "program_name": {
              "type": "string",
              "description": "Name of the COBOL program (e.g. ACCTBAL)"
            }
          },
          "required": ["program_name"]
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public IdentifyCopybooksTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Identifies all copybooks used by a COBOL program and returns their field definitions " +
                "(level numbers, names, PIC clauses).")
            .inputSchema(jsonMapper, INPUT_SCHEMA)
            .build();

        return new McpServerFeatures.AsyncToolSpecification(tool, (exchange, request) -> {
            String programName = (String) request.arguments().get("program_name");
            log.info("Tool {}: program_name={}", TOOL_NAME, programName);
            return Mono.fromCallable(() -> execute(programName))
                .map(text -> McpSchema.CallToolResult.builder().addTextContent(text).build());
        });
    }

    private String execute(String programName) throws Exception {
        Optional<CobolProgram> opt = graph.findProgram(programName);
        if (opt.isEmpty()) {
            ObjectNode err = jackson.createObjectNode();
            err.put("error", "Program not found: " + programName.toUpperCase());
            return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(err);
        }

        CobolProgram program = opt.get();
        ObjectNode result = jackson.createObjectNode();
        result.put("program", program.getName());

        ArrayNode copybooksArray = jackson.createArrayNode();
        for (String copybookName : program.getCopybooks()) {
            ObjectNode cbNode = jackson.createObjectNode();
            cbNode.put("name", copybookName);

            Optional<Copybook> cbOpt = graph.findCopybook(copybookName);
            if (cbOpt.isPresent()) {
                Copybook cb = cbOpt.get();
                cbNode.put("path", cb.getFilePath());
                cbNode.set("fields", jackson.valueToTree(cb.getFields()));
            } else {
                cbNode.put("path", "not indexed");
                cbNode.set("fields", jackson.createArrayNode());
            }
            copybooksArray.add(cbNode);
        }
        result.set("copybooks", copybooksArray);
        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
