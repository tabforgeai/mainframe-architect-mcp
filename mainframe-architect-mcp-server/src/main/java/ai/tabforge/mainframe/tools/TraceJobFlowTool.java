package ai.tabforge.mainframe.tools;

import ai.tabforge.mainframe.model.DependencyGraph;
import ai.tabforge.mainframe.model.JclJob;
import ai.tabforge.mainframe.model.JclStep;
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
 * Tool 3: trace_job_flow
 */
public class TraceJobFlowTool {

    private static final Logger log = LoggerFactory.getLogger(TraceJobFlowTool.class);
    private static final String TOOL_NAME = "trace_job_flow";

    private static final String INPUT_SCHEMA = """
        {
          "type": "object",
          "properties": {
            "jcl_name": {
              "type": "string",
              "description": "Name of the JCL job to trace (e.g. NIGHTLY)"
            }
          },
          "required": ["jcl_name"]
        }
        """;

    private final DependencyGraph graph;
    private final ObjectMapper jackson = new ObjectMapper();

    public TraceJobFlowTool(DependencyGraph graph) {
        this.graph = graph;
    }

    public McpServerFeatures.AsyncToolSpecification toolSpecification(McpJsonMapper jsonMapper) {
        McpSchema.Tool tool = McpSchema.Tool.builder()
            .name(TOOL_NAME)
            .description("Traces the execution flow of a JCL job: all steps, programs executed, " +
                "input/output datasets, and execution conditions.")
            .inputSchema(jsonMapper, INPUT_SCHEMA)
            .build();

        return new McpServerFeatures.AsyncToolSpecification(tool, (exchange, request) -> {
            String jclName = (String) request.arguments().get("jcl_name");
            log.info("Tool {}: jcl_name={}", TOOL_NAME, jclName);
            return Mono.fromCallable(() -> execute(jclName))
                .map(text -> McpSchema.CallToolResult.builder().addTextContent(text).build());
        });
    }

    private String execute(String jclName) throws Exception {
        Optional<JclJob> opt = graph.findJob(jclName);
        if (opt.isEmpty()) {
            ObjectNode err = jackson.createObjectNode();
            err.put("error", "JCL job not found: " + jclName.toUpperCase());
            err.put("available_count", graph.jobCount());
            return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(err);
        }

        JclJob job = opt.get();
        ObjectNode result = jackson.createObjectNode();
        result.put("job", job.getName());
        result.put("file_path", job.getFilePath());

        ArrayNode stepsArray = jackson.createArrayNode();
        for (JclStep step : job.getSteps()) {
            ObjectNode stepNode = jackson.createObjectNode();
            stepNode.put("step", step.getStepName());
            stepNode.put("program", step.getProgramName());
            stepNode.set("input_datasets", jackson.valueToTree(step.getInputDatasets()));
            stepNode.set("output_datasets", jackson.valueToTree(step.getOutputDatasets()));
            stepNode.put("condition", step.getCondition() != null ? step.getCondition() : "RUN ALWAYS");
            stepsArray.add(stepNode);
        }
        result.set("steps", stepsArray);
        return jackson.writerWithDefaultPrettyPrinter().writeValueAsString(result);
    }
}
