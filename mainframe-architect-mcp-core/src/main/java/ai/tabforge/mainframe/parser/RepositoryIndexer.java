package ai.tabforge.mainframe.parser;

import ai.tabforge.mainframe.model.CicsTransaction;
import ai.tabforge.mainframe.model.Copybook;
import ai.tabforge.mainframe.model.CopybookField;
import ai.tabforge.mainframe.model.CobolProgram;
import ai.tabforge.mainframe.model.DependencyGraph;
import ai.tabforge.mainframe.model.JclJob;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;

/**
 * Walks a source root directory and indexes all COBOL, copybook, JCL, and CICS files
 * into a single {@link DependencyGraph}.
 *
 * File type detection by extension:
 *   .cbl, .cob, .cobol  → COBOL program
 *   .cpy, .copy         → Copybook
 *   .jcl, .jcl          → JCL job
 *   .csd, .rdo          → CICS CSD/RDO file
 */
public class RepositoryIndexer {

    private static final Logger log = LoggerFactory.getLogger(RepositoryIndexer.class);

    private final CobolParser cobolParser = new CobolParser();
    private final JclParser jclParser = new JclParser();
    private final CicsResourceParser cicsParser = new CicsResourceParser();
    private final CopybookParser copybookParser = new CopybookParser();

    public DependencyGraph index(Path sourceRoot) throws IOException {
        log.info("Indexing repository: {}", sourceRoot);
        DependencyGraph graph = new DependencyGraph();

        try (Stream<Path> walk = Files.walk(sourceRoot)) {
            walk.filter(Files::isRegularFile).forEach(file -> {
                try {
                    processFile(file, graph);
                } catch (Exception e) {
                    log.warn("Failed to parse {}: {}", file, e.getMessage());
                }
            });
        }

        log.info("Indexing complete: {}", graph);
        return graph;
    }

    private void processFile(Path file, DependencyGraph graph) throws IOException {
        String name = file.getFileName().toString().toLowerCase();

        if (name.endsWith(".cbl") || name.endsWith(".cob") || name.endsWith(".cobol")) {
            CobolProgram program = cobolParser.parse(file);
            graph.addProgram(program);

        } else if (name.endsWith(".cpy") || name.endsWith(".copy")) {
            Copybook copybook = copybookParser.parse(file);
            graph.addCopybook(copybook);

        } else if (name.endsWith(".jcl")) {
            JclJob job = jclParser.parse(file);
            graph.addJob(job);

        } else if (name.endsWith(".csd") || name.endsWith(".rdo")) {
            List<CicsTransaction> txList = cicsParser.parse(file);
            txList.forEach(graph::addTransaction);
        }
    }
}
