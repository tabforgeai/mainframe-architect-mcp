package ai.tabforge.mainframe.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Domain model for a CICS transaction definition (from CSD/RDO file).
 */
public class CicsTransaction {

    private String transid;
    private String program;
    private String description;
    private List<String> userRoles = new ArrayList<>();

    public CicsTransaction() {}

    public CicsTransaction(String transid, String program) {
        this.transid = transid;
        this.program = program;
    }

    public String getTransid() { return transid; }
    public void setTransid(String transid) { this.transid = transid; }

    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<String> getUserRoles() { return userRoles; }
    public void setUserRoles(List<String> userRoles) { this.userRoles = userRoles; }

    @Override
    public String toString() {
        return "CicsTransaction{transid='" + transid + "', program='" + program + "'}";
    }
}
