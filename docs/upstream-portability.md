# Draft upstream issue for openEHR/ai-plugins

Title: **Make the non-portable parts of `openehr-specs` usable on hosts other than Claude Code and Cursor**

The seven authoring skills (`authoring`, `review`, `governance`, `amendment-record`,
`content-patterns`, `its-rest`, `class-generation`) are plain `SKILL.md` and already load on any
Agent Skills host from `.agents/skills/` (tested path: Codex CLI, Gemini CLI, GitHub Copilot,
OpenCode, Mistral Vibe). The remaining pieces only work on Claude Code (and partly Cursor):

| Piece | Why it does not port | Suggestion |
|-------|----------------------|------------|
| `publish`, `regen-classes`, `scaffold` | Rely on `disable-model-invocation`, `allowed-tools` and `${CLAUDE_SKILL_DIR}`; other hosts ignore the first two and have no equivalent of the third | Ship each as a plain script (`scripts/publish.sh <component>`, `scripts/regen-classes.sh <schema> [-d ...]`, `scripts/scaffold.py`) and let the SKILL.md tell the model to run the script. The Claude frontmatter can stay as a refinement |
| Subagents `spec-reviewer`, `xref-auditor`, `identifier-grounding` | `agents/*.md` is a Claude Code / Cursor concept | Add a `SKILL.md` variant of each (same checklist, run inline), or document the equivalent prompt in `docs/prompting-guide.md` |
| `.claude-plugin/` and `.cursor-plugin/` manifests only | Other hosts install skills with `npx skills add openEHR/ai-plugins -a <host>` or by copying `plugins/openehr-specs/skills/*` | Mention `npx skills add` in `docs/install.md` and confirm the skills live at a path the CLI discovers |
| `AGENTS.md` describes the plugin repo, not the user's workspace | Codex, Vibe, OpenCode and Copilot read `AGENTS.md` as project instructions | Provide a template `AGENTS.md` for a `specifications-XX` workspace (the `scaffold` skill writes one per repo already) |

Context: [openEHR/ai-spec-setup#1](https://github.com/openEHR/ai-spec-setup/issues/1) tracks
the host-agnostic workspace setup; it generates per-host MCP configs and installs the skills into
`.agents/skills/`, but cannot fix the items above from outside.
