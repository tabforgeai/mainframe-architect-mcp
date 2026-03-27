package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.CicsTransaction;
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

/**
 * Tool 5: map_cics_transactions
 */
public class MapCicsTransactionsTool {

    private static final Logger log = LoggerFactory.getLogger(MapCicsTransactionsTool.class);
    private static final String TOOL_NAME = "map_cics_transactions";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {
            "program_filter": {
              "type": "string",
              "description": "Optional: filter transactions by backing program name"
            }
          }
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public MapCicsTransactionsTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Maps all CICS transactions from indexed CSD/RDO files: transaction IDs, " +
                "backing programs, descriptions, and user roles.")
            .inputSchema(jsonMapper, INPUT_SCHEMA)
            .build();

        return new McpServerFeatures.AsyncToolSpecification(tool, (exchange, request) -> {
            String programFilter = (String) request.arguments().get("program_filter");
            log.info("Tool {}: program_filter={}", TOOL_NAME, programFilter);
            return Mono.fromCallable(() -> execute(programFilter))
                .map(text -> McpSchema.CallToolResult.builder().addTextContent(text).build());
        });
    }

    private String execute(String programFilter) throws Exception {
        ObjectNode result = jackson.createObjectNode();
        ArrayNode txArray = jackson.createArrayNode();

        for (CicsTransaction tx : graph.allTransactions()) {
            if (programFilter != null && tx.getProgram() != null &&
                !tx.getProgram().equalsIgnoreCase(programFilter)) {
                continue;
            }
            ObjectNode txNode = jackson.createObjectNode();
            txNode.put("transid", tx.getTransid());
            txNode.put("program", tx.getProgram() != null ? tx.getProgram() : "unknown");
            txNode.put("description", tx.getDescription() != null ? tx.getDescription() : "");
            txNode.set("user_roles", jackson.valueToTree(tx.getUserRoles()));
            txArray.add(txNode);
        }

        result.set("transactions", txArray);
        result.put("total_count", txArray.size());
        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
