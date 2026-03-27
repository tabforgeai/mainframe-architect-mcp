package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.CobolProgram;
import ai.tabforge.mainframe.model.Copybook;
import ai.tabforge.mainframe.model.DependencyGraph;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Tool 6: find_dead_code
 */
public class FindDeadCodeTool {

    private static final Logger log = LoggerFactory.getLogger(FindDeadCodeTool.class);
    private static final String TOOL_NAME = "find_dead_code";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {}
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public FindDeadCodeTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Finds potentially dead code: programs that are never called by other programs " +
                "or JCL jobs, and copybooks that are never referenced.")
            .inputSchema(jsonMapper, INPUT_SCHEMA)
            .build();

        return new McpServerFeatures.AsyncToolSpecification(tool, (exchange, request) -> {
            log.info("Tool {}", TOOL_NAME);
            return Mono.fromCallable(this::execute)
                .map(text -> McpSchema.CallToolResult.builder().addTextContent(text).build());
        });
    }

    private String execute() throws Exception {
        // Programs called by other programs
        Set<String> calledPrograms = new HashSet<>();
        for (CobolProgram p : graph.allPrograms()) {
            p.getCalls().forEach(c -> calledPrograms.add(c.toUpperCase()));
        }
        // Programs executed from JCL
        for (var job : graph.allJobs()) {
            for (var step : job.getSteps()) {
                if (step.getProgramName() != null) calledPrograms.add(step.getProgramName().toUpperCase());
            }
        }
        // Programs that are CICS entry points are NOT dead code
        for (var tx : graph.allTransactions()) {
            if (tx.getProgram() != null) calledPrograms.add(tx.getProgram().toUpperCase());
        }

        List<String> unusedPrograms = new ArrayList<>();
        for (CobolProgram p : graph.allPrograms()) {
            if (!calledPrograms.contains(p.getName())) unusedPrograms.add(p.getName());
        }

        // Copybooks referenced by any program
        Set<String> usedCopybooks = new HashSet<>();
        for (CobolProgram p : graph.allPrograms()) {
            p.getCopybooks().forEach(c -> usedCopybooks.add(c.toUpperCase()));
        }

        List<String> unusedCopybooks = new ArrayList<>();
        for (Copybook cb : graph.allCopybooks()) {
            if (!usedCopybooks.contains(cb.getName())) unusedCopybooks.add(cb.getName());
        }

        ObjectNode result = jackson.createObjectNode();
        result.put("note", "Programs with no callers may be batch entry points — verify before removal.");
        result.set("unused_programs", jackson.valueToTree(unusedPrograms));
        result.set("never_called_copybooks", jackson.valueToTree(unusedCopybooks));
        result.put("unused_program_count", unusedPrograms.size());
        result.put("unused_copybook_count", unusedCopybooks.size());
        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
