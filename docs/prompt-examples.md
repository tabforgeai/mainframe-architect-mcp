# Prompt Examples — Mainframe Architect MCP

Real-world prompts that work well with the 6 Community Edition tools.
Copy, adapt, and use them directly in Claude Desktop, Cursor, or Windsurf.

---

## `analyze_cobol_program`

**Basic structure**
```
Analyze PYMT001 and give me an overview of what this program does.
```

**Paragraph walkthrough**
```
Walk me through every paragraph in LOANPROC in execution order.
```

**Working storage**
```
List all working storage fields in ACCTBAL that look like they hold monetary amounts.
```

**CALL chain**
```
Which programs does VALCUST call, directly or indirectly?
```

**Conditional logic**
```
Show me all the IF and EVALUATE branches in ORDPROC. What are the main decision points?
```

**Data flow within a program**
```
In PYMT001, trace ACCOUNT-NUMBER from where it is received to where it is written or passed to another program.
```

---

## `identify_copybooks`

**Dependencies for a program**
```
Which copybooks does LOANPROC depend on? List every field they define.
```

**Field origin**
```
Where is CUSTOMER-STATUS defined? Which copybook, and which programs include it?
```

**Shared data structures**
```
Which copybooks are included by more than 5 programs? These are my most critical shared structures.
```

**Copybook content**
```
Show me the full record layout defined in CUSTMAST.
```

**Cross-copybook field search**
```
Search all copybooks for any field with "BALANCE" in the name. Where are they defined?
```

---

## `trace_job_flow`

**Job overview**
```
Walk me through every step of the NIGHTLY job. What does each step do?
```

**Dataset dependencies**
```
What datasets does INTRUN read? What does it produce? Are any of those outputs consumed by another job?
```

**Failure impact**
```
What happens if STEP020 in LOANRPT fails? Which downstream steps or jobs would be affected?
```

**Conditional execution**
```
Are there any steps in NIGHTLY that run only under certain conditions? What triggers them?
```

**Program-to-job mapping**
```
Which jobs invoke PYMT001? In which step, and with what parameters?
```

**Full batch chain**
```
Starting from NIGHTLY, show me the complete chain of jobs — any job that consumes output from NIGHTLY, and any job that consumes their output.
```

---

## `get_data_lineage`

**Field tracing**
```
Trace CUSTOMER-BALANCE across the entire codebase — where is it defined, which programs read it, which programs update it?
```

**Dataset lineage**
```
Which programs read from CUSTMAST? Which jobs populate it? Which programs write to it?
```

**Impact of a field change**
```
I need to extend ACCOUNT-NUMBER from 10 to 12 characters. Which programs and copybooks would I need to change?
```

**Critical data paths**
```
Show me the full data path from when a payment is received (PYMT001) to when the account balance is updated in the database.
```

**Shared field risk**
```
TRANSACTION-CODE is used in many places. Show me every program that reads or sets it.
```

---

## `find_dead_code`

**Unreferenced programs**
```
Are there any COBOL programs that no other program calls and no JCL job invokes?
```

**Unused copybooks**
```
Which copybooks are never included by any program? Are they safe to archive?
```

**Unreachable paragraphs**
```
In LOANPROC, are there any paragraphs that are never performed — either directly or via THRU?
```

**Candidates for retirement**
```
Give me a prioritized list of dead code candidates — programs, copybooks, and JCL jobs that appear to be unused.
```

**Dead code in a specific area**
```
Focus only on programs in the LOANS folder. Which ones look like they are no longer active?
```

---

## `map_cics_transactions`

**Full transaction inventory**
```
List all CICS transactions defined in this codebase and the program that handles each one.
```

**Transaction detail**
```
Which program handles the LOAN transaction? Walk me through what it does.
```

**COMMAREA usage**
```
Which CICS programs use COMMAREA to pass data? What fields are exchanged?
```

**Screen flow**
```
Map the screen flow for the account inquiry transaction — which programs are involved and in what order?
```

**CICS command inventory**
```
Which programs issue CICS WRITE or CICS REWRITE commands? These are my update-path programs.
```

---

## Multi-tool scenarios

These prompts naturally combine several tools in a single conversation.

**Change impact analysis**
```
I need to add a new field to the CUSTMAST copybook. Before I do:
1. Which programs include CUSTMAST?
2. Which jobs invoke those programs?
3. Are any of those programs dead code that I can ignore?
```

**Program onboarding**
```
I'm new to this codebase and need to understand PYMT001 end to end:
- What does it do at a high level?
- Which copybooks does it use?
- Which jobs call it, and in which step?
- Does it call any other programs?
```

**Batch job audit**
```
Audit the NIGHTLY job for me:
- Walk me through each step
- Identify any programs that are called but appear to be dead code
- List all datasets that flow between steps
```

**Retirement candidate review**
```
We're planning to decommission the LOANS module. Help me understand the blast radius:
- Which programs in LOANS are still called by active jobs?
- Which copybooks are shared with other modules?
- What would break if we removed everything in the LOANS folder?
```

**Data quality investigation**
```
CUSTOMER-BALANCE is showing incorrect values in production. Help me trace the problem:
- Which programs write to CUSTOMER-BALANCE?
- Which jobs invoke those programs, and in what order?
- Are there any programs that modify it unexpectedly?
```

---

## Tips for better results

- **Name the artifact** — use the actual program, job, or field name rather than generic descriptions. `Analyze PYMT001` works better than `Analyze the payment program`.
- **Ask follow-ups** — Claude remembers the context of the conversation. After `Analyze LOANPROC`, you can ask `Now show me just the paragraphs that touch CUSTOMER-BALANCE` without repeating the program name.
- **Combine questions** — you can ask multiple things at once. `Which programs call VALCUST, and are any of them dead code?` will use both `get_data_lineage` and `find_dead_code` in one response.
- **Scope your question** — for large codebases, narrowing to a folder, module, or job produces faster and more focused results.
