# Quick Start Guide

This guide gets you from zero to your first AI-powered COBOL analysis in under 5 minutes.

---

## Step 1 — Install

### Windows (recommended)

Download and run `MainframeArchitectMCP-1.0.0.exe` from the [Releases page](../../releases).

The installer bundles Java 21 — you do not need Java pre-installed.
Default install location: `C:\Program Files\MainframeArchitectMCP\`

### Linux

```bash
# Debian / Ubuntu
sudo dpkg -i mainframe-architect-mcp-1.0.0.deb

# RHEL / Fedora / CentOS
sudo rpm -i mainframe-architect-mcp-1.0.0.rpm
```

### Any platform — JAR (requires Java 21+)

```bash
java -version   # must be 21 or later

java -jar mainframe-architect-mcp.jar --source-root /path/to/your/cobol
```

---

## Step 2 — Point it at your source files

The `--source-root` argument tells the server where your COBOL repository lives.
It scans recursively — subdirectory structure doesn't matter.

```
your-cobol-repo/
├── cobol/          ← .cbl / .cob files
├── copy/           ← .cpy copybooks
├── jcl/            ← .jcl files
└── cics/           ← .csd / .rdo files
```

Or just dump everything in one folder — both work fine.

**No repository yet?** Use the included sample:

```bash
# Windows (native installer)
"C:\Program Files\MainframeArchitectMCP\MainframeArchitectMCP.exe" ^
    --source-root "C:\Program Files\MainframeArchitectMCP\sample-cobol-repo"

# JAR
java -jar mainframe-architect-mcp.jar --source-root ./sample-cobol-repo
```

You should see output like:

```
Indexing complete: DependencyGraph{programs=14, copybooks=6, jobs=4, transactions=6}
Mainframe Architect MCP Server ready — 6 tools active (STDIO transport).
```

---

## Step 3 — Connect Claude Desktop

Open your Claude Desktop configuration file:

| Platform | Location |
|----------|----------|
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |

If the file doesn't exist yet, create it with this content:

```json
{
  "mcpServers": {
    "mainframe-architect": {
      "command": "C:\\Program Files\\MainframeArchitectMCP\\MainframeArchitectMCP.exe",
      "args": ["--source-root", "C:\\repos\\your-cobol-project"]
    }
  }
}
```

> **Linux / macOS with JAR:**
> ```json
> {
>   "mcpServers": {
>     "mainframe-architect": {
>       "command": "java",
>       "args": ["-jar", "/opt/mainframe-architect-mcp.jar",
>                "--source-root", "/repos/your-cobol-project"]
>     }
>   }
> }
> ```

**Restart Claude Desktop** after saving the file.

You'll know it worked when you see a small 🔌 icon in the Claude chat interface.

---

## Step 4 — Ask your first question

Open a new chat in Claude Desktop and try:

```
Analyze the ACCTBAL program for me.
```

Claude will call the `analyze_cobol_program` tool and return the program's paragraph structure, CALL chain, copybooks, and working storage fields.

---

## The 6 tools — what to ask

### `analyze_cobol_program` — understand any program

```
Analyze PYMT001.
What paragraphs does LOANPROC have?
Show me the full structure of the VALCUST program.
```

### `identify_copybooks` — find all data dependencies

```
Which copybooks does ACCTBAL use? Show me all the fields.
What fields are defined in CUSTMAST?
```

### `trace_job_flow` — understand your batch jobs

```
Walk me through every step of the NIGHTLY job.
What datasets does INTRUN read and write?
What happens if STEP010 fails in LOANRPT?
```

### `get_data_lineage` — follow a field across the system

```
Where is CUSTOMER-BALANCE used across the whole codebase?
Which programs read from CUSTMAST? Which jobs touch it?
Trace ACCOUNT-NUMBER from definition to every consumer.
```

### `find_dead_code` — find what's safe to retire

```
Are there any programs that nothing calls?
Which copybooks are never referenced?
Show me dead code candidates.
```

### `map_cics_transactions` — map your online layer

```
List all CICS transactions and the programs behind them.
Which program handles the LOAN transaction?
```

---

## Troubleshooting

**Claude doesn't show the 🔌 icon after restart**
- Check the JSON in `claude_desktop_config.json` is valid (no trailing commas, correct quotes)
- Make sure the path in `command` or `args` actually exists
- On Windows: use double backslashes `\\` in JSON paths

**"Source root is not a directory" error**
- The path in `--source-root` must exist and be a directory, not a file

**Server starts but finds 0 programs**
- Check your files have the right extensions: `.cbl`, `.cob`, `.cpy`, `.jcl`, `.csd`
- The server scans recursively, but only these extensions are recognized

**Server starts but Claude gives generic answers**
- The MCP connection may not be active — look for the 🔌 icon
- Try restarting Claude Desktop

**Logs** are at `logs/mainframe-architect-mcp.log` next to the executable if you need to dig deeper.

---

## What's next

Once the basic tools are working with your repository, you have a foundation for more complex questions:

- *"Which programs would I need to recompile if I extend this field?"*
- *"Draw me a dependency diagram for this batch job chain."*
- *"Which programs have the most incoming calls — what are my most critical components?"*

These kinds of questions are what the tool is designed for. The larger and more complex your repository, the more value you'll get.

For **change impact analysis, compliance checking, and modernization roadmaps**, see the [Enterprise Edition](README.md#enterprise-edition).
