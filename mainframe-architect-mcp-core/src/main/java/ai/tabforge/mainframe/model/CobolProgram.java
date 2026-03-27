package ai.tabforge.mainframe.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Domain model for a parsed COBOL program.
 */
public class CobolProgram {

    private String name;
    private String filePath;
    private List<String> workingStorageFields = new ArrayList<>();
    private List<String> fileSection = new ArrayList<>();
    private List<String> calls = new ArrayList<>();
    private List<String> paragraphs = new ArrayList<>();
    private List<String> copybooks = new ArrayList<>();
    private int linesOfCode;

    public CobolProgram() {}

    public CobolProgram(String name, String filePath) {
        this.name = name;
        this.filePath = filePath;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public List<String> getWorkingStorageFields() { return workingStorageFields; }
    public void setWorkingStorageFields(List<String> workingStorageFields) {
        this.workingStorageFields = workingStorageFields;
    }

    public List<String> getFileSection() { return fileSection; }
    public void setFileSection(List<String> fileSection) { this.fileSection = fileSection; }

    public List<String> getCalls() { return calls; }
    public void setCalls(List<String> calls) { this.calls = calls; }

    public List<String> getParagraphs() { return paragraphs; }
    public void setParagraphs(List<String> paragraphs) { this.paragraphs = paragraphs; }

    public List<String> getCopybooks() { return copybooks; }
    public void setCopybooks(List<String> copybooks) { this.copybooks = copybooks; }

    public int getLinesOfCode() { return linesOfCode; }
    public void setLinesOfCode(int linesOfCode) { this.linesOfCode = linesOfCode; }

    @Override
    public String toString() {
        return "CobolProgram{name='" + name + "', loc=" + linesOfCode +
               ", calls=" + calls.size() + ", paragraphs=" + paragraphs.size() + "}";
    }
}
