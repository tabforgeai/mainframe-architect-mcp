package ai.tabforge.mainframe.parser;

import ai.tabforge.mainframe.model.CobolProgram;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Parses a COBOL source file into a {@link CobolProgram} domain object.
 *
 * Phase 1 implementation: regex-based extraction of key structural elements.
 * This is sufficient for Tools 1-6 and avoids the proleap AST overhead during
 * the initial indexing pass. A full AST pass via proleap can be added later
 * for advanced analysis (McCabe complexity, etc.).
 */
public class CobolParser {

    private static final Logger log = LoggerFactory.getLogger(CobolParser.class);

    // Fixed-format COBOL: columns 7-72 are code area, 1-6 = sequence, 73-80 = ident
    // We strip sequence numbers and work with the code area content.

    private static final Pattern PROGRAM_ID   = Pattern.compile(
        "^.{6}\\s+PROGRAM-ID\\.\\s+(\\S+)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    private static final Pattern COPY_STMT    = Pattern.compile(
        "^.{6}\\s+COPY\\s+(\\S+)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    private static final Pattern CALL_STMT    = Pattern.compile(
        "CALL\\s+['\"]([A-Z0-9#@$-]+)['\"]", Pattern.CASE_INSENSITIVE);

    // Paragraph names appear in Area A (col 8+).
    // Pattern handles both: no-sequence files (7 leading spaces) and
    // sequence-numbered files (6 digits + 1 indicator space).
    // Requires name >= 3 chars starting with a letter to avoid matching
    // level numbers (01, 77) and single-char labels.
    // Paragraph names appear in Area A (col 8+), min 3 chars so level numbers
    // (01, 05, 77 — max 2 chars) are never matched as paragraphs.
    private static final Pattern PARAGRAPH    = Pattern.compile(
        "^[ \\d]{0,7}([A-Z0-9][A-Z0-9-]{2,})\\.", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    private static final Pattern SELECT_FILE  = Pattern.compile(
        "SELECT\\s+(\\S+)\\s+ASSIGN", Pattern.CASE_INSENSITIVE);

    private static final Pattern WS_FIELD     = Pattern.compile(
        "^.{6}\\s+(0?[1-9]|[1-4][0-9]|49)\\s+([A-Z0-9][A-Z0-9-]*)\\s+PIC",
        Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    public CobolProgram parse(Path filePath) throws IOException {
        log.debug("Parsing COBOL file: {}", filePath);
        String source = Files.readString(filePath);

        CobolProgram program = new CobolProgram();
        program.setFilePath(filePath.toString());
        program.setLinesOfCode(countNonBlankLines(source));

        // Program name from PROGRAM-ID
        Matcher m = PROGRAM_ID.matcher(source);
        if (m.find()) {
            String id = m.group(1).replaceAll("\\.$", "").trim();
            program.setName(id.toUpperCase());
        } else {
            // Fallback: use filename without extension
            String fileName = filePath.getFileName().toString();
            program.setName(fileName.replaceAll("\\.[^.]+$", "").toUpperCase());
        }

        // COPY statements → copybooks
        List<String> copybooks = new ArrayList<>();
        m = COPY_STMT.matcher(source);
        while (m.find()) {
            String name = m.group(1).replaceAll("\\.$", "").trim().toUpperCase();
            if (!copybooks.contains(name)) copybooks.add(name);
        }
        program.setCopybooks(copybooks);

        // CALL statements → called programs
        List<String> calls = new ArrayList<>();
        m = CALL_STMT.matcher(source);
        while (m.find()) {
            String name = m.group(1).trim().toUpperCase();
            if (!calls.contains(name)) calls.add(name);
        }
        program.setCalls(calls);

        // SELECT ... ASSIGN → file section
        List<String> fileSection = new ArrayList<>();
        m = SELECT_FILE.matcher(source);
        while (m.find()) {
            String name = m.group(1).trim().toUpperCase();
            if (!fileSection.contains(name)) fileSection.add(name);
        }
        program.setFileSection(fileSection);

        // Working storage fields (PIC items)
        List<String> wsFields = new ArrayList<>();
        m = WS_FIELD.matcher(source);
        while (m.find()) {
            String name = m.group(2).trim().toUpperCase();
            if (!wsFields.contains(name)) wsFields.add(name);
        }
        program.setWorkingStorageFields(wsFields);

        // Paragraphs — names ending with period at column 8+
        List<String> paragraphs = new ArrayList<>();
        m = PARAGRAPH.matcher(source);
        while (m.find()) {
            String name = m.group(1).trim().toUpperCase();
            // Filter out division/section keywords and very short names
            if (!isKeyword(name) && name.length() > 1 && !paragraphs.contains(name)) {
                paragraphs.add(name);
            }
        }
        program.setParagraphs(paragraphs);

        log.debug("Parsed: {}", program);
        return program;
    }

    private int countNonBlankLines(String source) {
        int count = 0;
        for (String line : source.split("\n")) {
            if (!line.isBlank()) count++;
        }
        return count;
    }

    private static final java.util.Set<String> KEYWORDS = java.util.Set.of(
        "IDENTIFICATION", "ENVIRONMENT", "DATA", "PROCEDURE",
        "WORKING-STORAGE", "FILE", "LINKAGE", "LOCAL-STORAGE",
        "CONFIGURATION", "INPUT-OUTPUT", "FILE-CONTROL",
        "DIVISION", "SECTION",
        "PROGRAM-ID", "AUTHOR", "DATE-WRITTEN", "DATE-COMPILED",
        "SECURITY", "REMARKS", "SOURCE-COMPUTER", "OBJECT-COMPUTER",
        "SPECIAL-NAMES", "REPOSITORY"
    );

    private boolean isKeyword(String name) {
        return KEYWORDS.contains(name.toUpperCase());
    }
}
