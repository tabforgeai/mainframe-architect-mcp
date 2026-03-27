package ai.tabforge.mainframe.parser;

import ai.tabforge.mainframe.model.CicsTransaction;
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
 * Parses a CICS CSD/RDO export file into a list of {@link CicsTransaction} objects.
 *
 * CSD export format (DFHCSDUP LIST output):
 *
 *   DEFINE TRANSACTION(ACT1)
 *     GROUP(BANKING)
 *     PROGRAM(ACCTINQ)
 *     DESCRIPTION(Account Inquiry)
 */
public class CicsResourceParser {

    private static final Logger log = LoggerFactory.getLogger(CicsResourceParser.class);

    private static final Pattern DEFINE_TX   = Pattern.compile(
        "DEFINE\\s+TRANSACTION\\(([A-Z0-9@#$]{1,4})\\)", Pattern.CASE_INSENSITIVE);

    private static final Pattern PROGRAM_DEF = Pattern.compile(
        "PROGRAM\\(([A-Z0-9@#$-]{1,8})\\)", Pattern.CASE_INSENSITIVE);

    private static final Pattern DESC_DEF    = Pattern.compile(
        "DESCRIPTION\\(([^)]+)\\)", Pattern.CASE_INSENSITIVE);

    // RACF or CICS security — USERID or USERID pattern in CSD rarely present,
    // but some exports include USERID( ) for transaction-level security.
    // We also check for custom GROUP names to approximate roles.
    private static final Pattern GROUP_DEF   = Pattern.compile(
        "GROUP\\(([A-Z0-9@#$-]+)\\)", Pattern.CASE_INSENSITIVE);

    public List<CicsTransaction> parse(Path filePath) throws IOException {
        log.debug("Parsing CICS CSD file: {}", filePath);

        String content = Files.readString(filePath);
        List<CicsTransaction> result = new ArrayList<>();

        // Split on DEFINE TRANSACTION blocks ((?i) = case-insensitive inline flag)
        String[] blocks = content.split("(?i)(?=DEFINE\\s+TRANSACTION)");

        for (String block : blocks) {
            Matcher txMatcher = DEFINE_TX.matcher(block);
            if (!txMatcher.find()) continue;

            String transid = txMatcher.group(1).toUpperCase();
            CicsTransaction tx = new CicsTransaction();
            tx.setTransid(transid);

            Matcher pgmMatcher = PROGRAM_DEF.matcher(block);
            if (pgmMatcher.find()) {
                tx.setProgram(pgmMatcher.group(1).toUpperCase());
            }

            Matcher descMatcher = DESC_DEF.matcher(block);
            if (descMatcher.find()) {
                tx.setDescription(descMatcher.group(1).trim());
            }

            // Use GROUP as a proxy for user roles when no explicit role info present
            List<String> roles = new ArrayList<>();
            Matcher groupMatcher = GROUP_DEF.matcher(block);
            while (groupMatcher.find()) {
                roles.add(groupMatcher.group(1).toUpperCase());
            }
            tx.setUserRoles(roles);

            result.add(tx);
            log.debug("Found CICS transaction: {}", tx);
        }

        log.info("Parsed {} CICS transactions from {}", result.size(), filePath.getFileName());
        return result;
    }
}
