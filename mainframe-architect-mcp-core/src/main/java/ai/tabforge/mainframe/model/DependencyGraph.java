package ai.tabforge.mainframe.model;

import java.util.*;

/**
 * In-memory dependency graph of all indexed mainframe artifacts.
 * Central registry used by all tools for cross-artifact analysis.
 */
public class DependencyGraph {

    private final Map<String, CobolProgram> programs = new LinkedHashMap<>();
    private final Map<String, Copybook> copybooks = new LinkedHashMap<>();
    private final Map<String, JclJob> jobs = new LinkedHashMap<>();
    private final Map<String, CicsTransaction> transactions = new LinkedHashMap<>();

    // -------------------------------------------------------------------------
    // Registration
    // -------------------------------------------------------------------------

    public void addProgram(CobolProgram program) {
        programs.put(program.getName().toUpperCase(), program);
    }

    public void addCopybook(Copybook copybook) {
        copybooks.put(copybook.getName().toUpperCase(), copybook);
    }

    public void addJob(JclJob job) {
        jobs.put(job.getName().toUpperCase(), job);
    }

    public void addTransaction(CicsTransaction tx) {
        transactions.put(tx.getTransid().toUpperCase(), tx);
    }

    // -------------------------------------------------------------------------
    // Lookup
    // -------------------------------------------------------------------------

    public Optional<CobolProgram> findProgram(String name) {
        return Optional.ofNullable(programs.get(name.toUpperCase()));
    }

    public Optional<Copybook> findCopybook(String name) {
        return Optional.ofNullable(copybooks.get(name.toUpperCase()));
    }

    public Optional<JclJob> findJob(String name) {
        return Optional.ofNullable(jobs.get(name.toUpperCase()));
    }

    public Collection<CobolProgram> allPrograms() { return programs.values(); }
    public Collection<Copybook> allCopybooks() { return copybooks.values(); }
    public Collection<JclJob> allJobs() { return jobs.values(); }
    public Collection<CicsTransaction> allTransactions() { return transactions.values(); }

    // -------------------------------------------------------------------------
    // Cross-artifact queries
    // -------------------------------------------------------------------------

    /** Returns all programs that COPY the given copybook name. */
    public List<CobolProgram> programsUsing(String copybookName) {
        String key = copybookName.toUpperCase();
        List<CobolProgram> result = new ArrayList<>();
        for (CobolProgram p : programs.values()) {
            if (p.getCopybooks().stream().anyMatch(c -> c.toUpperCase().equals(key))) {
                result.add(p);
            }
        }
        return result;
    }

    /** Returns all programs that CALL the given program name. */
    public List<CobolProgram> callers(String programName) {
        String key = programName.toUpperCase();
        List<CobolProgram> result = new ArrayList<>();
        for (CobolProgram p : programs.values()) {
            if (p.getCalls().stream().anyMatch(c -> c.toUpperCase().equals(key))) {
                result.add(p);
            }
        }
        return result;
    }

    /** Returns all JCL jobs that invoke the given program in any step. */
    public List<JclJob> jobsCallingProgram(String programName) {
        String key = programName.toUpperCase();
        List<JclJob> result = new ArrayList<>();
        for (JclJob job : jobs.values()) {
            boolean found = job.getSteps().stream()
                .anyMatch(s -> s.getProgramName() != null &&
                               s.getProgramName().toUpperCase().equals(key));
            if (found) result.add(job);
        }
        return result;
    }

    /** Returns all CICS transactions backed by the given program. */
    public List<CicsTransaction> transactionsForProgram(String programName) {
        String key = programName.toUpperCase();
        List<CicsTransaction> result = new ArrayList<>();
        for (CicsTransaction tx : transactions.values()) {
            if (tx.getProgram() != null && tx.getProgram().toUpperCase().equals(key)) {
                result.add(tx);
            }
        }
        return result;
    }

    /** Returns all programs that read or write the given field name (by scanning working storage). */
    public List<CobolProgram> programsWithField(String fieldName) {
        String key = fieldName.toUpperCase();
        List<CobolProgram> result = new ArrayList<>();
        for (CobolProgram p : programs.values()) {
            if (p.getWorkingStorageFields().stream().anyMatch(f -> f.toUpperCase().contains(key))) {
                result.add(p);
            }
        }
        return result;
    }

    // -------------------------------------------------------------------------
    // Stats
    // -------------------------------------------------------------------------

    public int programCount()     { return programs.size(); }
    public int copybookCount()    { return copybooks.size(); }
    public int jobCount()         { return jobs.size(); }
    public int transactionCount() { return transactions.size(); }

    @Override
    public String toString() {
        return "DependencyGraph{programs=" + programs.size() +
               ", copybooks=" + copybooks.size() +
               ", jobs=" + jobs.size() +
               ", transactions=" + transactions.size() + "}";
    }
}
