package ai.tabforge.mainframe.parser;

import ai.tabforge.mainframe.model.Copybook;
import ai.tabforge.mainframe.model.CopybookField;
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
 * Parses a COBOL copybook (.cpy) file into a {@link Copybook} domain object.
 */
public class CopybookParser {

    private static final Logger log = LoggerFactory.getLogger(CopybookParser.class);

    // Level number + data name + optional PIC clause
    private static final Pattern FIELD_WITH_PIC = Pattern.compile(
        "^.{0,6}\\s*(\\d{1,2})\\s+([A-Z0-9][A-Z0-9-]*)\\s+PIC(?:TURE)?\\s+(?:IS\\s+)?([A-Z9()X/BVS.+-]+)",
        Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    private static final Pattern GROUP_FIELD = Pattern.compile(
        "^.{0,6}\\s*(\\d{1,2})\\s+([A-Z0-9][A-Z0-9-]*)\\s*\\.\\s*$",
        Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    public Copybook parse(Path filePath) throws IOException {
        log.debug("Parsing copybook: {}", filePath);
        String source = Files.readString(filePath);

        String fileName = filePath.getFileName().toString();
        String name = fileName.replaceAll("\\.[^.]+$", "").toUpperCase();

        Copybook copybook = new Copybook(name, filePath.toString());
        List<CopybookField> fields = new ArrayList<>();

        // PIC fields
        Matcher m = FIELD_WITH_PIC.matcher(source);
        while (m.find()) {
            int level = Integer.parseInt(m.group(1));
            String fieldName = m.group(2).toUpperCase();
            String pic = "PIC " + m.group(3).toUpperCase();
            fields.add(new CopybookField(level, fieldName, pic));
        }

        // Group fields (no PIC — just level + name + period)
        m = GROUP_FIELD.matcher(source);
        while (m.find()) {
            int level = Integer.parseInt(m.group(1));
            String fieldName = m.group(2).toUpperCase();
            // Only add if not already captured as PIC field
            boolean alreadyAdded = fields.stream().anyMatch(f -> f.getName().equals(fieldName));
            if (!alreadyAdded) {
                fields.add(new CopybookField(level, fieldName, "GROUP"));
            }
        }

        // Sort by appearance order (regex finds in source order already)
        copybook.setFields(fields);
        log.debug("Parsed copybook {} with {} fields", name, fields.size());
        return copybook;
    }
}
