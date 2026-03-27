package ai.tabforge.mainframe;

import ai.tabforge.mainframe.model.DependencyGraph;
import ai.tabforge.mainframe.parser.RepositoryIndexer;
import ai.tabforge.mainframe.server.MainframeArchitectServer;
import ai.tabforge.mainframe.spi.EnterpriseToolsPlugin;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ServiceLoader;

/**
 * Entry point for the Mainframe Architect MCP Server.
 *
 * Usage (Community):
 *   java -jar mainframe-architect-mcp.jar --source-root /path/to/cobol/repo
 *
 * Usage (Enterprise):
 *   java -jar mainframe-architect-mcp.jar \
 *        --source-root /path/to/cobol/repo \
 *        --enterprise-jar /opt/mainframe-architect-enterprise.jar \
 *        --license-key XXXXX-XXXXX-XXXXX
 */
public class Main {

    private static final Logger log = LoggerFactory.getLogger(Main.class);

    public static void main(String[] args) throws Exception {
        Path sourceRoot     = parseArg(args, "--source-root");
        String enterpriseJar = parseArgValue(args, "--enterprise-jar");
        String licenseKey    = parseArgValue(args, "--license-key");

        log.info("Mainframe Architect MCP Server starting...");
        log.info("Source root: {}", sourceRoot);

        // Index the entire repository on startup
        RepositoryIndexer indexer = new RepositoryIndexer();
        DependencyGraph graph = indexer.index(sourceRoot);

        log.info("Repository indexed: {} programs, {} copybooks, {} jobs, {} CICS transactions",
            graph.programCount(), graph.copybookCount(),
            graph.jobCount(), graph.transactionCount());

        // Optionally load Enterprise plugin
        EnterpriseToolsPlugin enterprisePlugin = loadEnterprisePlugin(enterpriseJar, licenseKey);

        // Start MCP server (blocks until shutdown)
        MainframeArchitectServer server = new MainframeArchitectServer(graph, enterprisePlugin);
        server.start();
    }

    // -------------------------------------------------------------------------
    // Enterprise plugin loading
    // -------------------------------------------------------------------------

    private static EnterpriseToolsPlugin loadEnterprisePlugin(
            String enterpriseJarPath, String licenseKey) {

        ServiceLoader<EnterpriseToolsPlugin> loader;

        if (enterpriseJarPath != null) {
            // Load from explicitly provided JAR path
            File jarFile = new File(enterpriseJarPath);
            if (!jarFile.exists()) {
                log.warn("Enterprise JAR not found: {} — starting in Community Edition.", enterpriseJarPath);
                return null;
            }
            try {
                URL jarUrl = jarFile.toURI().toURL();
                URLClassLoader classLoader = new URLClassLoader(
                    new URL[]{jarUrl}, Main.class.getClassLoader());
                loader = ServiceLoader.load(EnterpriseToolsPlugin.class, classLoader);
                log.info("Loading Enterprise plugin from: {}", enterpriseJarPath);
            } catch (Exception e) {
                log.warn("Failed to load Enterprise JAR: {} — Community Edition only.", e.getMessage());
                return null;
            }
        } else {
            // Try classpath (for development: enterprise module on classpath)
            loader = ServiceLoader.load(EnterpriseToolsPlugin.class);
        }

        if (!loader.iterator().hasNext()) {
            log.info("Community Edition — Enterprise plugin not found.");
            return null;
        }

        EnterpriseToolsPlugin plugin = loader.iterator().next();

        if (licenseKey == null || licenseKey.isBlank()) {
            log.warn("Enterprise plugin found but no --license-key provided — Community Edition only.");
            return null;
        }

        if (!plugin.validateLicense(licenseKey)) {
            log.warn("Invalid license key — Community Edition only.");
            return null;
        }

        log.info("Enterprise Edition activated: {}", plugin.pluginName());
        return plugin;
    }

    // -------------------------------------------------------------------------
    // Argument parsing
    // -------------------------------------------------------------------------

    private static Path parseArg(String[] args, String argName) {
        String value = parseArgValue(args, argName);
        if (value == null) {
            System.err.println("Usage: mainframe-architect-mcp.jar --source-root <path> " +
                               "[--enterprise-jar <path>] [--license-key <key>]");
            System.exit(1);
        }
        Path path = Paths.get(value);
        if (!Files.isDirectory(path)) {
            System.err.println("ERROR: " + argName + " is not a directory: " + path);
            System.exit(1);
        }
        return path;
    }

    private static String parseArgValue(String[] args, String argName) {
        for (int i = 0; i < args.length - 1; i++) {
            if (argName.equals(args[i])) return args[i + 1];
        }
        return null;
    }
}
