# Build from Source

If you prefer not to use the pre-built installers, you can build Mainframe Architect MCP yourself from source. The build requires only Docker (for Linux packages) or JDK 21 + Maven (for Windows).

---

## Prerequisites

**For Linux packages (DEB / RPM):**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — no JDK or Maven needed locally

**For Windows installer:**
- [JDK 21](https://adoptium.net/) (Temurin recommended)
- [Apache Maven 3.9+](https://maven.apache.org/download.cgi)

---

## 1. Clone the repository

```bash
git clone https://github.com/tabforgeai/mainframe-architect-mcp.git
cd mainframe-architect-mcp
```

---

## 2. Build — Linux DEB (Debian / Ubuntu)

Docker pulls the build environment automatically. No local JDK or Maven needed.

**Linux / macOS:**
```bash
docker run --rm \
  -v "$(pwd):/project" \
  -v "$HOME/.m2:/root/.m2" \
  -w /project \
  maven:3.9-eclipse-temurin-21 \
  bash -c "apt-get update -q && apt-get install -y -q fakeroot && mvn clean package -P linux-deb -DskipTests -pl mainframe-architect-mcp-server -am"
```

**Windows (CMD):**
```
docker run --rm -v "%cd%:/project" -v "%USERPROFILE%\.m2:/root/.m2" -w /project maven:3.9-eclipse-temurin-21 bash -c "apt-get update -q && apt-get install -y -q fakeroot && mvn clean package -P linux-deb -DskipTests -pl mainframe-architect-mcp-server -am"
```

**Windows (PowerShell):**
```powershell
docker run --rm -v "${PWD}:/project" -v "$env:USERPROFILE\.m2:/root/.m2" -w /project maven:3.9-eclipse-temurin-21 bash -c "apt-get update -q && apt-get install -y -q fakeroot && mvn clean package -P linux-deb -DskipTests -pl mainframe-architect-mcp-server -am"
```

Output: `mainframe-architect-mcp-server/target/jpackage/mainframe-architect-mcp_1.0.0_amd64.deb`

---

## 3. Build — Linux RPM (RHEL / Rocky Linux / Fedora)

**Linux / macOS:**
```bash
docker run --rm \
  -v "$(pwd):/project" \
  -v "$HOME/.m2:/root/.m2" \
  -w /project \
  maven:3.9-eclipse-temurin-21 \
  bash -c "apt-get update -q && apt-get install -y -q fakeroot rpm && mvn clean package -P linux-rpm -DskipTests -pl mainframe-architect-mcp-server -am"
```

**Windows (CMD):**
```
docker run --rm -v "%cd%:/project" -v "%USERPROFILE%\.m2:/root/.m2" -w /project maven:3.9-eclipse-temurin-21 bash -c "apt-get update -q && apt-get install -y -q fakeroot rpm && mvn clean package -P linux-rpm -DskipTests -pl mainframe-architect-mcp-server -am"
```

**Windows (PowerShell):**
```powershell
docker run --rm -v "${PWD}:/project" -v "$env:USERPROFILE\.m2:/root/.m2" -w /project maven:3.9-eclipse-temurin-21 bash -c "apt-get update -q && apt-get install -y -q fakeroot rpm && mvn clean package -P linux-rpm -DskipTests -pl mainframe-architect-mcp-server -am"
```

Output: `mainframe-architect-mcp-server/target/jpackage/mainframe-architect-mcp-1.0.0-1.x86_64.rpm`

---

## 4. Build — Windows EXE

The Windows installer must be built on a Windows machine (jpackage requirement).
Requires JDK 21 and Maven 3.9+ installed locally.

```
mvn clean package -P windows-exe -DskipTests -pl mainframe-architect-mcp-server -am
```

Output: `mainframe-architect-mcp-server\target\jpackage\MainframeArchitectMCP-1.0.0.exe`

---

## 5. Verify the build

**DEB:**
```bash
docker run --rm \
  -v "$(pwd)/mainframe-architect-mcp-server/target/jpackage:/pkg" \
  ubuntu:22.04 \
  bash -c "dpkg -i /pkg/*.deb && /opt/mainframe-architect-mcp/bin/mainframe-architect-mcp --help"
```

**RPM:**
```bash
docker run --rm \
  -v "$(pwd)/mainframe-architect-mcp-server/target/jpackage:/pkg" \
  rockylinux:9 \
  bash -c "rpm -i /pkg/*.rpm && /opt/mainframe-architect-mcp/bin/mainframe-architect-mcp --help"
```

Expected output:
```
Usage: mainframe-architect-mcp.jar --source-root <path> [--enterprise-jar <path>] [--license-key <key>]
```

---

## Maven cache note

The `-v "$HOME/.m2:/root/.m2"` flag mounts your local Maven cache into the container. This speeds up subsequent builds significantly — dependencies are downloaded only on the first build.
