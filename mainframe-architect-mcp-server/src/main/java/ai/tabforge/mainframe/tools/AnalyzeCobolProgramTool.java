package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.CobolProgram;
import ai.tabforge.mainframe.model.DependencyGraph;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;

import java.util.Optional;

/**
 * Tool 1: analyze_cobol_program
 */
public class AnalyzeCobolProgramTool {

    private static final Logger log = LoggerFactory.getLogger(AnalyzeCobolProgramTool.class);
    private static final String TOOL_NAME = "analyze_cobol_program";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {
            "program_name": {
              "type": "string",
              "description": "Name of the COBOL program to analyze (e.g. ACCTBAL)"
            }
          },
          "required": ["program_name"]
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public AnalyzeCobolProgramTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Analyzes a COBOL program and returns its structure: paragraphs, CALL statements, " +
                "COPY statements, file section entries, working storage fields, and lines of code.")
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
            err.put("available_count", graph.programCount());
            return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(err);
        }

        CobolProgram p = opt.get();
        ObjectNode result = jackson.createObjectNode();
        result.put("name", p.getName());
        result.put("file_path", p.getFilePath());
        result.put("lines_of_code", p.getLinesOfCode());
        result.set("paragraphs", jackson.valueToTree(p.getParagraphs()));
        result.set("calls", jackson.valueToTree(p.getCalls()));
        result.set("copybooks", jackson.valueToTree(p.getCopybooks()));
        result.set("file_section", jackson.valueToTree(p.getFileSection()));
        result.set("working_storage_fields", jackson.valueToTree(p.getWorkingStorageFields()));
        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
