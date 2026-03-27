package ai.tabforge.mainframe.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Domain model for a COBOL copybook (.cpy file).
 */
public class Copybook {

    private String name;
    private String filePath;
    private List<CopybookField> fields = new ArrayList<>();

    public Copybook() {}

    public Copybook(String name, String filePath) {
        this.name = name;
        this.filePath = filePath;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public List<CopybookField> getFields() { return fields; }
    public void setFields(List<CopybookField> fields) { this.fields = fields; }

    @Override
    public String toString() {
        return "Copybook{name='" + name + "', fields=" + fields.size() + "}";
    }
}
