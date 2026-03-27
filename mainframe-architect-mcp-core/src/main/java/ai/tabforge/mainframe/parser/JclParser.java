package ai.tabforge.mainframe.parser;

import ai.tabforge.mainframe.model.JclJob;
import ai.tabforge.mainframe.model.JclStep;
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
 * Parses a JCL file into a {@link JclJob} domain object.
 *
 * JCL structure:
 *   //JOBNAME  JOB  ...
 *   //STEPNAME EXEC PGM=PROGRAM
 *   //DDNAME   DD   DSN=dataset,...
 */
public class JclParser {

    private static final Logger log = LoggerFactory.getLogger(JclParser.class);

    // JCL statement: //name keyword parameters
    private static final Pattern JOB_STMT  = Pattern.compile(
        "^//([A-Z0-9@#$]{1,8})\\s+JOB\\b", Pattern.CASE_INSENSITIVE);

    private static final Pattern EXEC_STMT = Pattern.compile(
        "^//([A-Z0-9@#$]{1,8})\\s+EXEC\\s+PGM=([A-Z0-9@#$-]+)",
        Pattern.CASE_INSENSITIVE);

    private static final Pattern DD_STMT   = Pattern.compile(
        "^//([A-Z0-9@#$]{1,8})\\s+DD\\b", Pattern.CASE_INSENSITIVE);

    private static final Pattern DSN_PARAM = Pattern.compile(
        "DSN=([A-Z0-9.@#$()-]+)", Pattern.CASE_INSENSITIVE);

    private static final Pattern DISP_PARAM = Pattern.compile(
        "DISP=\\(?\\s*([A-Z,]+)", Pattern.CASE_INSENSITIVE);

    private static final Pattern COND_PARAM = Pattern.compile(
        "COND=\\(?([^,)]+(?:,[^)]+)?)", Pattern.CASE_INSENSITIVE);

    public JclJob parse(Path filePath) throws IOException {
        log.debug("Parsing JCL file: {}", filePath);

        List<String> lines = Files.readAllLines(filePath);
        // JCL continuation: lines starting with // followed by space, then parameters
        List<String> logicalLines = joinContinuations(lines);

        JclJob job = new JclJob();
        job.setFilePath(filePath.toString());

        JclStep currentStep = null;

        for (String line : logicalLines) {
            if (line.startsWith("//*") || line.startsWith("//") == false) continue;

            Matcher jobMatcher = JOB_STMT.matcher(line);
            if (jobMatcher.find()) {
                job.setName(jobMatcher.group(1).toUpperCase());
                continue;
            }

            Matcher execMatcher = EXEC_STMT.matcher(line);
            if (execMatcher.find()) {
                if (currentStep != null) {
                    job.getSteps().add(currentStep);
                }
                currentStep = new JclStep(
                    execMatcher.group(1).toUpperCase(),
                    execMatcher.group(2).toUpperCase()
                );

                // Extract COND parameter
                Matcher condMatcher = COND_PARAM.matcher(line);
                if (condMatcher.find()) {
                    currentStep.setCondition(condMatcher.group(1).trim());
                } else {
                    currentStep.setCondition("RUN ALWAYS");
                }
                continue;
            }

            // DD statements — classify as input or output by DISP
            if (currentStep != null) {
                Matcher ddMatcher = DD_STMT.matcher(line);
                if (ddMatcher.find()) {
                    Matcher dsnMatcher = DSN_PARAM.matcher(line);
                    if (dsnMatcher.find()) {
                        String dsn = dsnMatcher.group(1).toUpperCase();
                        String disp = extractDisp(line);
                        if (isOutput(disp)) {
                            currentStep.getOutputDatasets().add(dsn);
                        } else {
                            currentStep.getInputDatasets().add(dsn);
                        }
                    }
                }
            }
        }

        if (currentStep != null) {
            job.getSteps().add(currentStep);
        }

        // Fallback name from filename if JOB statement not found
        if (job.getName() == null) {
            String fileName = filePath.getFileName().toString();
            job.setName(fileName.replaceAll("\\.[^.]+$", "").toUpperCase());
        }

        log.debug("Parsed: {}", job);
        return job;
    }

    /**
     * Joins JCL continuation lines (lines 2+ starting with // followed by spaces/params,
     * continuing the previous statement).
     */
    private List<String> joinContinuations(List<String> lines) {
        List<String> result = new ArrayList<>();
        StringBuilder current = null;

        for (String line : lines) {
            if (line.startsWith("//") && !line.startsWith("//*")) {
                // Check if this is a new statement or continuation
                // Continuation: //               (columns 3-16 are blank, parameters at col 16+)
                boolean isContinuation = line.length() > 2 &&
                    line.substring(2).startsWith("            "); // 12 spaces = continuation

                if (isContinuation && current != null) {
                    current.append(" ").append(line.substring(14).trim());
                } else {
                    if (current != null) result.add(current.toString());
                    current = new StringBuilder(line);
                }
            } else {
                if (current != null) result.add(current.toString());
                current = null;
                result.add(line);
            }
        }
        if (current != null) result.add(current.toString());
        return result;
    }

    private String extractDisp(String line) {
        Matcher m = DISP_PARAM.matcher(line);
        if (m.find()) return m.group(1).toUpperCase();
        return "SHR"; // default
    }

    private boolean isOutput(String disp) {
        // NEW or MOD means output
        return disp.contains("NEW") || disp.contains("MOD") || disp.startsWith("(NEW") || disp.startsWith("(MOD");
    }
}
