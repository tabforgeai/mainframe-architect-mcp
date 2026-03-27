package ai.tabforge.mainframe.server;

import ai.tabforge.mainframe.model.DependencyGraph;
import ai.tabforge.mainframe.spi.EnterpriseToolsPlugin;
import ai.tabforge.mainframe.tools.*;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.json.jackson3.JacksonMcpJsonMapperSupplier;
import io.modelcontextprotocol.server.McpServer;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.server.transport.StdioServerTransportProvider;
import io.modelcontextprotocol.spec.McpSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * Registers Community + (optionally) Enterprise MCP tools and starts the server
 * communicating over STDIO (required for Claude Desktop integration).
 */
public class MainframeArchitectServer {

    private static final Logger log = LoggerFactory.getLogger(MainframeArchitectServer.class);

    private final DependencyGraph graph;
    private final EnterpriseToolsPlugin enterprisePlugin; // null = Community Edition

    public MainframeArchitectServer(DependencyGraph graph, EnterpriseToolsPlugin enterprisePlugin) {
        this.graph = graph;
        this.enterprisePlugin = enterprisePlugin;
    }

    public void start() {
        McpJsonMapper jsonMapper = new JacksonMcpJsonMapperSupplier().get();

        // --- Community tools (always registered) ---
        List<McpServerFeatures.AsyncToolSpecification> tools = new ArrayList<>();
        tools.add(new AnalyzeCobolProgramTool(graph).toolSpecification(jsonMapper));
        tools.add(new IdentifyCopybooksTool(graph).toolSpecification(jsonMapper));
        tools.add(new TraceJobFlowTool(graph).toolSpecification(jsonMapper));
        tools.add(new GetDataLineageTool(graph).toolSpecification(jsonMapper));
        tools.add(new FindDeadCodeTool(graph).toolSpecification(jsonMapper));
        tools.add(new MapCicsTransactionsTool(graph).toolSpecification(jsonMapper));
        log.info("Community Edition tools registered (6).");

        // --- Enterprise tools (registered only with valid license) ---
        if (enterprisePlugin != null) {
            List<McpServerFeatures.AsyncToolSpecification> enterpriseTools =
                enterprisePlugin.toolSpecifications(graph, jsonMapper);
            tools.addAll(enterpriseTools);
            log.info("Enterprise Edition tools registered ({}).", enterpriseTools.size());
        }

        StdioServerTransportProvider transport = new StdioServerTransportProvider(jsonMapper);

        McpServer.async(transport)
            .serverInfo("mainframe-architect-mcp", "1.0.0")
            .capabilities(McpSchema.ServerCapabilities.builder()
                .tools(true)
                .build())
            .tools(tools)
            .build();

        log.info("Mainframe Architect MCP Server ready — {} tools active (STDIO transport).",
            tools.size());

        try {
            Thread.currentThread().join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
