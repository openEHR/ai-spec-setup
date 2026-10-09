# openEHR AI skills

One folder, `openehr-spec/`, with everything needed to work on openEHR specifications and clinical
models with Claude Code: all 18 `specifications-XX` repos side by side, the two skill plugins, and
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

Needs: Claude Code, git, Docker, GNU make. Both MCP servers ask you to log in; follow the prompt.

### 0. One folder, clone recursively

```sh
mkdir openehr-spec && cd openehr-spec
git clone --recurse-submodules <this-repo> openehr-ai-skills
# already cloned without submodules?  git -C openehr-ai-skills submodule update --init --recursive
```

### 1. Discourse MCP

```sh
cd openehr-ai-skills/external/discourse-mcp
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
openehr-ai-skills/scripts/clone-spec-repos.sh     # 18 specifications-XX repos into openehr-spec/
```

### 5. Run the AI in `openehr-spec/`

```sh
cp openehr-ai-skills/.mcp.json .
mkdir -p .claude && cp openehr-ai-skills/.claude/settings.json .claude/
claude
```

Always start `claude` here: the skills expect all `specifications-XX` folders as siblings.

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

## Layout

```
openehr-spec/
├── .mcp.json, .claude/settings.json      copied from this repo
├── openehr-ai-skills/           this repo: docs/, scripts/, external/ (submodules)
├── specifications-AA_GLOBAL/
├── specifications-RM/
└── ... (18 specifications-XX repos)
```
