#!/usr/bin/env python3
"""Generate per-host MCP config files from the single source .mcp.json (Claude Code format).

Writes into hosts/<host>/ with the path each host expects at the workspace root, so
`scripts/install-host.sh <host>` can copy the folder over as-is:

  hosts/claude/.mcp.json, .claude/settings.json   (copies)
  hosts/cursor/.cursor/mcp.json
  hosts/gemini/.gemini/settings.json
  hosts/codex/.codex/config.toml
  hosts/vibe/.vibe/config.toml
  hosts/opencode/opencode.json

Re-run after editing .mcp.json. ${HOME} is kept verbatim; install-host.sh substitutes it.
"""
import json
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOSTS = os.path.join(ROOT, "hosts")


def load_servers():
    with open(os.path.join(ROOT, ".mcp.json"), encoding="utf-8") as f:
        return json.load(f)["mcpServers"]


def is_remote(s):
    return s.get("type") in ("http", "sse", "streamable-http") or "url" in s


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text if text.endswith("\n") else text + "\n")
    print("wrote", os.path.relpath(path, ROOT))


def toml_str(v):
    return json.dumps(v)  # JSON string literal is valid TOML for plain strings


def toml_arr(vs):
    return "[" + ", ".join(toml_str(v) for v in vs) + "]"


def toml_inline(d):
    return "{ " + ", ".join(f"{toml_str(k)} = {toml_str(v)}" for k, v in d.items()) + " }"


def gen_claude(servers):
    os.makedirs(os.path.join(HOSTS, "claude", ".claude"), exist_ok=True)
    shutil.copy(os.path.join(ROOT, ".mcp.json"), os.path.join(HOSTS, "claude", ".mcp.json"))
    shutil.copy(os.path.join(ROOT, ".claude", "settings.json"), os.path.join(HOSTS, "claude", ".claude", "settings.json"))
    print("wrote hosts/claude/.mcp.json, hosts/claude/.claude/settings.json")


def gen_cursor(servers):
    out = {}
    for name, s in servers.items():
        out[name] = {"url": s["url"]} if is_remote(s) else {k: s[k] for k in ("command", "args", "env") if k in s}
    write(os.path.join(HOSTS, "cursor", ".cursor", "mcp.json"), json.dumps({"mcpServers": out}, indent=2))


def gen_gemini(servers):
    out = {}
    for name, s in servers.items():
        out[name] = {"httpUrl": s["url"]} if is_remote(s) else {k: s[k] for k in ("command", "args", "env") if k in s}
    cfg = {"context": {"fileName": ["AGENTS.md", "GEMINI.md"]}, "mcpServers": out}
    write(os.path.join(HOSTS, "gemini", ".gemini", "settings.json"), json.dumps(cfg, indent=2))


def gen_codex(servers):
    lines = ["# Codex CLI MCP servers, generated from .mcp.json by scripts/gen-host-configs.py.",
             "# Project-level config; if your Codex version only reads ~/.codex/config.toml, merge this block there.", ""]
    for name, s in servers.items():
        lines.append(f"[mcp_servers.{toml_str(name)}]")
        if is_remote(s):
            lines.append(f"url = {toml_str(s['url'])}")
        else:
            lines.append(f"command = {toml_str(s['command'])}")
            lines.append(f"args = {toml_arr(s.get('args', []))}")
            if s.get("env"):
                lines.append(f"env = {toml_inline(s['env'])}")
        lines.append("")
    write(os.path.join(HOSTS, "codex", ".codex", "config.toml"), "\n".join(lines))


def gen_vibe(servers):
    lines = ["# Mistral Vibe MCP servers, generated from .mcp.json by scripts/gen-host-configs.py.",
             "# Vibe reads ./.vibe/config.toml first, then ~/.vibe/config.toml. Remote servers without auth use OAuth (browser login).", ""]
    for name, s in servers.items():
        lines.append("[[mcp_servers]]")
        lines.append(f"name = {toml_str(name)}")
        if is_remote(s):
            lines.append('transport = "streamable-http"')
            lines.append(f"url = {toml_str(s['url'])}")
        else:
            lines.append('transport = "stdio"')
            lines.append(f"command = {toml_str(s['command'])}")
            lines.append(f"args = {toml_arr(s.get('args', []))}")
            if s.get("env"):
                lines.append(f"env = {toml_inline(s['env'])}")
        lines.append("")
    write(os.path.join(HOSTS, "vibe", ".vibe", "config.toml"), "\n".join(lines))


def gen_opencode(servers):
    out = {}
    for name, s in servers.items():
        if is_remote(s):
            out[name] = {"type": "remote", "url": s["url"], "enabled": True}
        else:
            entry = {"type": "local", "command": [s["command"]] + s.get("args", []), "enabled": True}
            if s.get("env"):
                entry["environment"] = s["env"]
            out[name] = entry
    write(os.path.join(HOSTS, "opencode", "opencode.json"),
          json.dumps({"$schema": "https://opencode.ai/config.json", "mcp": out}, indent=2))


def main():
    servers = load_servers()
    for gen in (gen_claude, gen_cursor, gen_gemini, gen_codex, gen_vibe, gen_opencode):
        gen(servers)
    return 0


if __name__ == "__main__":
    sys.exit(main())
