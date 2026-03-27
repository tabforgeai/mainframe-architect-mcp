package ai.tabforge.mainframe.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Domain model for a JCL job.
 */
public class JclJob {

    private String name;
    private String filePath;
    private List<JclStep> steps = new ArrayList<>();

    public JclJob() {}

    public JclJob(String name, String filePath) {
        this.name = name;
        this.filePath = filePath;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public List<JclStep> getSteps() { return steps; }
    public void setSteps(List<JclStep> steps) { this.steps = steps; }

    @Override
    public String toString() {
        return "JclJob{name='" + name + "', steps=" + steps.size() + "}";
    }
}
