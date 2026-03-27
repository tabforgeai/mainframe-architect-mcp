package ai.tabforge.mainframe.model;

/**
 * Represents a single field (level entry) within a COBOL copybook.
 */
public class CopybookField {

    private int level;
    private String name;
    private String type; // PIC clause or "GROUP"

    public CopybookField() {}

    public CopybookField(int level, String name, String type) {
        this.level = level;
        this.name = name;
        this.type = type;
    }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    @Override
    public String toString() {
        return level + " " + name + " " + type;
    }
}
