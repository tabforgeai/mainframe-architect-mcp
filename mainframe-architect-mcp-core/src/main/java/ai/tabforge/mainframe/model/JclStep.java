package ai.tabforge.mainframe.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a single step within a JCL job.
 */
public class JclStep {

    private String stepName;
    private String programName;
    private List<String> inputDatasets = new ArrayList<>();
    private List<String> outputDatasets = new ArrayList<>();
    private String condition;

    public JclStep() {}

    public JclStep(String stepName, String programName) {
        this.stepName = stepName;
        this.programName = programName;
    }

    public String getStepName() { return stepName; }
    public void setStepName(String stepName) { this.stepName = stepName; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public List<String> getInputDatasets() { return inputDatasets; }
    public void setInputDatasets(List<String> inputDatasets) { this.inputDatasets = inputDatasets; }

    public List<String> getOutputDatasets() { return outputDatasets; }
    public void setOutputDatasets(List<String> outputDatasets) { this.outputDatasets = outputDatasets; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    @Override
    public String toString() {
        return "JclStep{step='" + stepName + "', program='" + programName + "'}";
    }
}
