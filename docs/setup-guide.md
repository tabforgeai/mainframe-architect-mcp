# Mainframe Architect MCP — Setup Guide

## Table of Contents

1. [System Requirements](#1-system-requirements)
2. [Installation](#2-installation)
3. [Configuring Claude Desktop](#3-configuring-claude-desktop)
4. [Configuring Other AI Clients](#4-configuring-other-ai-clients)
5. [Log Files](#5-log-files)
6. [Verifying the Installation](#6-verifying-the-installation)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. System Requirements

| Component        | Minimum                                         |
|------------------|-------------------------------------------------|
| Operating System | Windows 10/11, Ubuntu 20.04+, RHEL/Rocky 8+    |
| Java             | Not required — bundled with the native installer |
| Source files     | `.cbl` / `.cob`, `.cpy`, `.jcl`, `.csd` / `.rdo` |
| AI Client        | Claude Desktop, Cursor, Windsurf, or any MCP-compatible client |

---

## 2. Installation

### Windows

1. Download `MainframeArchitectMCP-1.0.0.exe` from the [Releases page](../../releases)
2. Run the installer — installs to `C:\Program Files\MainframeArchitectMCP\` by default
3. After installation:

```
C:\Program Files\MainframeArchitectMCP\
├── app\
│   └── mainframe-architect-mcp.jar   ← application JAR
├── runtime\                           ← bundled Java 21 (no JDK needed)
├── logs\                              ← log files written here automatically
└── MainframeArchitectMCP.exe          ← launcher
```

### Linux — Debian / Ubuntu

```bash
sudo dpkg -i mainframe-architect-mcp_1.0.0_amd64.deb
```

Installed to:
```
/opt/mainframe-architect-mcp/
├── bin/
│   └── mainframe-architect-mcp    ← launcher
└── lib/
    ├── app/
    │   └── mainframe-architect-mcp.jar
    └── runtime/                   ← bundled Java 21 (no JDK needed)
```

### Linux — RHEL / Rocky Linux / Fedora

```bash
sudo rpm -i mainframe-architect-mcp-1.0.0-1.x86_64.rpm
```

Installed to the same structure as Debian above (`/opt/mainframe-architect-mcp/`).

### Any platform — JAR (requires Java 21+)

```bash
java -jar mainframe-architect-mcp.jar --source-root /path/to/your/cobol
```

---

## 3. Configuring Claude Desktop

Claude Desktop uses a JSON configuration file to register MCP servers.

### Location of claude_desktop_config.json

| OS      | Path |
|---------|------|
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| macOS   | `~/Library/Application Support/Claude/claude_desktop_config.json` |

### Windows — installed via .exe

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

### Linux — installed via .deb or .rpm

```json
{
  "mcpServers": {
    "mainframe-architect": {
      "command": "/opt/mainframe-architect-mcp/bin/mainframe-architect-mcp",
      "args": ["--source-root", "/repos/your-cobol-project"]
    }
  }
}
```

### JAR (any platform, requires Java 21+)

```json
{
  "mcpServers": {
    "mainframe-architect": {
      "command": "java",
      "args": ["-jar", "/path/to/mainframe-architect-mcp.jar",
               "--source-root", "/repos/your-cobol-project"]
    }
  }
}
```

After editing the file, **restart Claude Desktop**. A hammer icon (🔨) or plug icon in the Claude chat window confirms the MCP server is active.

---

## 4. Configuring Other AI Clients

The server communicates over **stdio** using the Model Context Protocol — any MCP-compatible client works.

### Cursor

Add to `.cursor/mcp.json` in your project root, or the global Cursor MCP config file:

**Windows:**
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

**Linux:**
```json
{
  "mcpServers": {
    "mainframe-architect": {
      "command": "/opt/mainframe-architect-mcp/bin/mainframe-architect-mcp",
      "args": ["--source-root", "/repos/your-cobol-project"]
    }
  }
}
```

### Windsurf / Codeium

Open **Settings → MCP Servers** and add:

**Windows:**
```json
{
  "mainframe-architect": {
    "command": "C:\\Program Files\\MainframeArchitectMCP\\MainframeArchitectMCP.exe",
    "args": ["--source-root", "C:\\repos\\your-cobol-project"],
    "transport": "stdio"
  }
}
```

**Linux:**
```json
{
  "mainframe-architect": {
    "command": "/opt/mainframe-architect-mcp/bin/mainframe-architect-mcp",
    "args": ["--source-root", "/repos/your-cobol-project"],
    "transport": "stdio"
  }
}
```

### Enterprise Edition

To activate Enterprise tools, add `--enterprise-jar` and `--license-key` to the `args` list:

```json
{
  "mcpServers": {
    "mainframe-architect": {
      "command": "C:\\Program Files\\MainframeArchitectMCP\\MainframeArchitectMCP.exe",
      "args": [
        "--source-root",   "C:\\repos\\your-cobol-project",
        "--enterprise-jar", "C:\\path\\to\\mainframe-architect-mcp-enterprise.jar",
        "--license-key",    "MAMP-ENT-XXXXXXXXXX"
      ]
    }
  }
}
```

Contact [tabforge.ai](https://tabforge.ai) for Enterprise licensing.

---

## 5. Log Files

| Scenario                        | Log location |
|---------------------------------|-------------|
| Installed via Windows .exe      | `logs\` folder in the installation directory (e.g. `C:\Program Files\MainframeArchitectMCP\logs\`) |
| Installed via Linux .deb / .rpm | `logs/` in the current working directory (typically the directory from which the MCP client was launched) |
| Run directly from JAR           | `logs/` in the current working directory |

Log file name: `mainframe-architect-mcp.log`, rolled daily, 7 days retention.

> **Important:** All diagnostic output is written to STDERR and the log file. STDOUT is reserved for MCP protocol communication — do not redirect it.

---

## 6. Verifying the Installation

After configuring your AI client:

1. Start a new conversation
2. Ask:

   > **"List all tools you have available."**

   The server exposes 6 Community tools (or 11 with Enterprise):
   `analyze_cobol_program`, `identify_copybooks`, `trace_job_flow`,
   `get_data_lineage`, `find_dead_code`, `map_cics_transactions`

3. Try a first real question:

   > **"Are there any dead code candidates in this repository?"**

If no tools appear:
- Verify the path in your config file points to the correct executable
- Check that `--source-root` points to a directory that exists
- Check the log file for error details

---

## 7. Troubleshooting

### No tools appear in the AI client

- Verify the path in the MCP config is correct and the file exists
- On Windows, use double backslashes (`\\`) in JSON paths
- Restart the AI client after any config change
- Check the log file for startup errors

### "Source root is not a directory" error

- The path in `--source-root` must exist and be a directory, not a file
- On Windows, avoid trailing backslashes in the path

### Server starts but finds 0 programs

- Verify your files use the recognized extensions: `.cbl`, `.cob`, `.cpy`, `.jcl`, `.csd`, `.rdo`
- The server scans recursively — subdirectory structure doesn't matter

### Server starts but AI gives generic answers (tools not called)

- The MCP connection may not be active — look for the tool/hammer icon in the client UI
- Restart the AI client

### Log file not found (Windows)

- With the native installer, logs are in the `logs\` folder next to the `app\` folder in the install directory
- With the JAR, logs go to `./logs` relative to where the JAR was launched from

### Linux: permission denied on `/opt/mainframe-architect-mcp/`

```bash
sudo chmod 755 /opt/mainframe-architect-mcp/bin/mainframe-architect-mcp
```
