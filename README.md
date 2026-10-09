# openEHR AI spec setup

AI-assistant setup for openEHR specification work, with clinical-modelling skills included. Claude Code
is the reference host; Cursor, Codex, Gemini CLI, OpenCode and Mistral Vibe are covered too. One folder,
`openehr-spec/`, holds all 18 `specifications-XX` repos side by side, the two skill plugins, and
the MCP servers they use. Claude Code is always started in that folder, so every skill finds every
sibling repo.

This is the glue, not the source: the skills live in [openEHR/ai-plugins](https://github.com/openEHR/ai-plugins) and the forum server in [openEHR/discourse-mcp](https://github.com/openEHR/discourse-mcp); this repo pins them as submodules and adds the setup steps, MCP config and workspace layout to use them together.

| What | Source | Here |
|------|--------|------|
| `openehr-specs` skills: author, review, govern spec documents, regenerate class tables from BMM, publish HTML | [openEHR/ai-plugins](https://github.com/openEHR/ai-plugins) (Sebastian Iancu) | `external/openEHR-ai-plugins/` |
| `openehr-assistant` skills + MCP: archetypes, templates, compositions, AQL, CKM search, spec lookup | [Cadasto/openehr-assistant-plugin](https://github.com/Cadasto/openehr-assistant-plugin) | `external/cadasto-openehr-assistant-plugin/` |
| Discourse MCP for discourse.openehr.org (Dockerised `@discourse/mcp`) | [openEHR/discourse-mcp](https://github.com/openEHR/discourse-mcp) | `external/discourse-mcp/` |
| Jira / Confluence MCP | Atlassian remote MCP | `.mcp.json` |
| 18 spec repos | [github.com/openEHR](https://github.com/openEHR) | `scripts/clone-spec-repos.*` |

The upstream repos are git submodules, pinned to tested versions. `scripts/pull-skills.sh --latest`
moves them to upstream HEAD. Full tool list: [docs/skills-inventory.md](docs/skills-inventory.md).
Worked example: [docs/example-is-blue.md](docs/example-is-blue.md).

## Setup

Needs: an AI host (Claude Code shown; others in [Hosts and models](#hosts-and-models)), git, Docker, GNU make, python3. Both MCP servers ask you to log in; follow the prompt.

### 0. One folder, clone recursively

```sh
mkdir openehr-spec && cd openehr-spec
git clone --recurse-submodules https://github.com/openEHR/ai-spec-setup.git ai-spec-setup
# already cloned without submodules?  git -C ai-spec-setup submodule update --init --recursive
```

### 1. Discourse MCP

```sh
cd ai-spec-setup/external/discourse-mcp
make build
docker run -it --rm -v "$HOME/.config:/out" node:24-alpine \
  npx -y @discourse/mcp@latest generate-user-api-key \
  --site https://discourse.openehr.org --save-to /out/discourse-openehr-org.profile.json
make test        # OK: server starts and profile loads
cd ../../..
```

Login: open the URL it prints, authorize, paste the code back. Windows: if `${HOME}` in `.mcp.json`
does not resolve, put the absolute profile path there.

Check, in Claude Code (after step 5):

```text
Using the discourse MCP, show the last 10 posts on discourse.openehr.org (title, author, date).
```

### 2. Jira MCP

Nothing to install. In Claude Code: `/mcp` → `atlassian` → Authenticate → browser login.

Check:

```text
Using the Atlassian MCP (not the public API), show the last 10 SPECPR tickets: key, summary, status, created.
```

### 3. Skills

In Claude Code, then restart it:

```text
/plugin marketplace add openEHR/ai-plugins
/plugin install openehr-specs@openehr
/plugin marketplace add Cadasto/plugin-marketplace
/plugin install openehr-assistant@cadasto
```

### 4. Spec repos

```sh
ai-spec-setup/scripts/clone-spec-repos.sh     # 18 specifications-XX repos into openehr-spec/
```

### 5. Run the AI in `openehr-spec/`

Pick your host; the script copies its MCP config, `AGENTS.md`, and (for non-Claude hosts) the skills
into `.agents/skills/`:

```sh
ai-spec-setup/scripts/install-host.sh claude      # or: cursor | codex | gemini | vibe | opencode
claude                                            # or: cursor . | codex | gemini | vibe | opencode
```

Always start the assistant here: the skills expect all `specifications-XX` folders as siblings.
Host differences: [Hosts and models](#hosts-and-models).

### 6. Smoke test

Run the two MCP checks above, then:

```text
In specifications-RM on a throwaway branch try/is-blue: use the openehr-specs skills to add an optional
Boolean property is_blue to COMPOSITION in computable/BMM/openehr_rm_1.2.0.bmm.json,
regenerate the class tables (/openehr-specs:regen-classes openehr_rm_1.2.0 -d openehr_base_1.3.0),
build the HTML (/openehr-specs:publish RM) and show me where is_blue appears. Do not commit.
```

Expected: `is_blue: Boolean` in `docs/UML/classes/org.openehr.rm.composition.composition.adoc` and in
`docs/ehr.html`. Then discard the exercise and delete the branch:

```sh
git -C specifications-RM restore . && git -C specifications-RM clean -fd out
git -C specifications-RM switch - && git -C specifications-RM branch -D try/is-blue
```

Step by step: [docs/example-is-blue.md](docs/example-is-blue.md).

## Hosts and models

Skills are `SKILL.md` ([Agent Skills](https://agentskills.io), an open format) and the servers are
MCP, so the setup is not tied to Claude. What differs per host is the config file and how much of
the plugins carries over. `.mcp.json` is the single source; `scripts/gen-host-configs.py` writes
the per-host files into `hosts/`, and `scripts/install-host.sh <host>` copies them to the root.

| Tier | Hosts | You get | Config written to root |
|------|-------|---------|------------------------|
| Full | Claude Code, Cursor | all skills via the plugin marketplaces, subagents (`spec-reviewer`, `xref-auditor`, `identifier-grounding`, `clinical-modeler`, `ckm-scout`), Docker action skills `/openehr-specs:publish`, `regen-classes`, `scaffold`, hooks | `.mcp.json` + `.claude/settings.json`; `.cursor/mcp.json` |
| Skills + MCP | Codex CLI, Gemini CLI, GitHub Copilot, OpenCode, Mistral Vibe | the 15 skills from `.agents/skills/`, all MCP tools, `AGENTS.md`. No subagents; run the Docker steps by hand (commands in [docs/example-is-blue.md](docs/example-is-blue.md)) | `.codex/config.toml`; `.gemini/settings.json`; `opencode.json`; `.vibe/config.toml`; Copilot reads `.agents/skills/` + VS Code MCP settings |
| Open models | any host above, pointed at a local or open model | same as the host's tier; quality depends on the model | see below |

Login prompts are the same everywhere: Discourse via the API-key step, Atlassian via OAuth on first use.

**Open models with Claude Code.** Ollama 0.14+ speaks the Anthropic Messages API, so this exact setup
runs on a local model with two env vars (LM Studio 0.4.1+ and llama.cpp work the same way):

```sh
ollama pull qwen3-coder                      # or devstral, gpt-oss:20b, glm-4.7-flash
export ANTHROPIC_BASE_URL=http://localhost:11434 ANTHROPIC_AUTH_TOKEN=ollama
claude --model qwen3-coder
```

Use a model with tool calling and at least 32K context; the spec skills are long and the BMM files are
large. Codex pairs with GPT, Vibe with Mistral (Devstral), OpenCode with any provider including Ollama
and Mistral. Known gaps that need upstream changes are listed in
[docs/upstream-portability.md](docs/upstream-portability.md).

## Layout

```
openehr-spec/
├── AGENTS.md, CLAUDE.md                  shared instructions (copied from this repo)
├── .mcp.json, .claude/, .cursor/, ...    MCP config for the host(s) you installed
├── .agents/skills/                       skills for non-Claude hosts
├── ai-spec-setup/                        this repo: docs/, scripts/, hosts/, external/ (submodules)
├── specifications-AA_GLOBAL/
├── specifications-RM/
└── ... (18 specifications-XX repos)
```
