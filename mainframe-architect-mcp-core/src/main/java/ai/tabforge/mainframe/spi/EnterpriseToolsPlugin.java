package ai.tabforge.mainframe.spi;

import ai.tabforge.mainframe.model.DependencyGraph;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServerFeatures;

import java.util.List;

/**
 * SPI (Service Provider Interface) for the Enterprise Edition plugin.
 *
 * This interface lives in the open source core module so that the server
 * can reference it without depending on the private enterprise module.
 *
 * Enterprise JAR provides the implementation via Java ServiceLoader:
 *   META-INF/services/ai.tabforge.mainframe.spi.EnterpriseToolsPlugin
 *
 * Usage (server startup):
 *   java -jar mainframe-architect-mcp.jar \
 *        --source-root /repo/cobol \
 *        --enterprise-jar /opt/mainframe-architect-enterprise.jar \
 *        --license-key XXXXX-XXXXX-XXXXX
 */
public interface EnterpriseToolsPlugin {

    /**
     * Validates the license key.
     * Returns true if the key is valid and the plugin may register its tools.
     */
    boolean validateLicense(String licenseKey);

    /**
     * Returns all Enterprise tool specifications to be registered with the MCP server.
     * Called only if validateLicense() returned true.
     *
     * @param graph      the indexed dependency graph (shared with community tools)
     * @param jsonMapper the MCP JSON mapper (needed to build tool input schemas)
     */
    List<McpServerFeatures.AsyncToolSpecification> toolSpecifications(
            DependencyGraph graph, McpJsonMapper jsonMapper);

    /**
     * Human-readable name of this plugin, shown in startup log.
     */
    String pluginName();
}
