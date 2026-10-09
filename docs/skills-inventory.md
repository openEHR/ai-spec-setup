# Skills inventory

Everything the two plugins and two MCP servers add to Claude Code, with what triggers it.
Versions pinned in `external/` at the time of writing: openehr-specs 0.5.0, openehr-assistant 0.9.2.

## openehr-specs (openEHR/ai-plugins)

Model-invoked skills (describe the task, or type `/openehr-specs:<skill>`):

| Skill | Purpose |
|-------|---------|
| `authoring` | Create and edit AsciiDoc spec documents and `manifest.json` |
| `review` | Pre-release quality and convention review (findings table) |
| `governance` | Releases, change requests, lifecycle states, SEC process |
| `amendment-record` | Amendment record entries; `/openehr-specs:amendment-record <SPECXX-NN> - summary` |
| `content-patterns` | Prose patterns for chapters and sections |
| `its-rest` | ITS-REST OpenAPI YAML and operation descriptions |
| `class-generation` | Class tables and UML diagrams from BMM via `bmm-publisher` (layouts, placement into `docs/UML/`) |

User-only action skills (run only when typed):

| Skill | Argument | Needs |
|-------|----------|-------|
| `/openehr-specs:regen-classes` | `<schema-id> [-d <dep-schema-id> ...]`, e.g. `openehr_rm_1.2.0 -d openehr_base_1.3.0` | Docker, `ghcr.io/openehr/bmm-publisher`, run inside the component repo |
| `/openehr-specs:publish` | `<component>`, e.g. `RM` | Docker, `ghcr.io/openehr/asciidoctor`, run from workspace root with sibling `specifications-AA_GLOBAL` |
| `/openehr-specs:scaffold` | `[component id]` | `python3`; initialises or upgrades a spec repo (AGENTS.md, `.claude/`, manifest, ...) |

Subagents (Claude dispatches them; you can ask for them by name):

| Subagent | Purpose |
|----------|---------|
| `spec-reviewer` | Full review catalog over a whole document or component |
| `xref-auditor` | Verifies `{openehr_*}` attributes and `<<anchor>>` references |
| `identifier-grounding` | Fact-checks RM/AM/BASE class and attribute names against the published specs (uses openehr-assistant MCP or WebFetch) |

## openehr-assistant (Cadasto)

| Skill | Trigger |
|-------|---------|
| `archetype-authoring` | Create, edit, review, translate archetypes (guide-first) |
| `archetype-lint` | 24 normative lint rules, STRICT/PERMISSIVE |
| `template-authoring` | Template design, CGEM framework, narrowing principle |
| `composition-builder` | FLAT / STRUCTURED / CANONICAL compositions |
| `aql-authoring` | Author, explain, optimise AQL |
| `semantic-diff` | Compare two artefacts, version-bump verdict (`/semantic-diff`) |
| `demographic-modeling` | PARTY hierarchy, roles, relationships |
| `openehr-assistant` | Router skill for any openEHR mention |

| Command | Description |
|---------|-------------|
| `/ckm-search [archetype or template] <query>` | Search CKM |
| `/openehr-explain <thing>` | Explain any archetype, template, RM/AM type, ADL idiom, AQL keyword or code |
| `/archetype-impact <archetype-id>` | Find references to an archetype in the workspace |

| Agent | Description |
|-------|-------------|
| `clinical-modeler` | Reads/writes local `.adl`, `.oet`, `.t.json`, `.opt` files |
| `ckm-scout` | Parallel CKM reuse search with ranked recommendation |
| `spec-researcher` | Spec research via llms.txt / `.md` twins / BMM |

Companion MCP server (`openehr-assistant`, streamable-http, registered by the plugin):
`ckm_archetype_search/get`, `ckm_template_search/get`, `guide_search/get`,
`guide_adl_idiom_lookup`, `examples_search/get`, `terminology_resolve`,
`type_specification_search/get`. Resources: `openehr://guides/{category}/{name}`,
`openehr://examples/{aql|flat|structured|archetypes}/{name}`.

## MCP servers registered by this repo (`.mcp.json`)

| Server | Transport | Tools |
|--------|-----------|-------|
| `discourse-openehr-org` | stdio, Docker image `discourse-mcp` | `discourse_search`, `discourse_read_topic`, `discourse_read_post`, `discourse_filter_topics`, `discourse_list_users`, `discourse_get_user`, `discourse_list_user_posts`, `discourse_run_query`, `discourse_get_query`, `discourse_get_draft`, `discourse_get_chat_messages` (read-only) |
| `atlassian` | http, `mcp.atlassian.com` | `getJiraIssue`, `searchJiraIssuesUsingJql`, `createJiraIssue`, `editJiraIssue`, `transitionJiraIssue`, `addOrEditJiraIssueComment`, `searchConfluence`, `getConfluenceContent`, `discover` + `executeRead/Write/Destructive` |

## Which to use when

| Task | Use |
|------|-----|
| Edit or review a `specifications-XX` chapter | `openehr-specs:authoring` / `review`, `spec-reviewer` |
| Change the RM/AM/BASE model | edit `computable/BMM/*.bmm.json`, `/openehr-specs:regen-classes`, `/openehr-specs:publish` |
| Record a change request | Jira MCP for the key, `/openehr-specs:amendment-record`, `governance` |
| Check community discussion on a CR | `discourse_search` on discourse.openehr.org |
| Design an archetype, template, composition or AQL | `openehr-assistant` skills, `/ckm-search`, `clinical-modeler` |
| "What does the spec say about X?" | `/openehr-explain`, `spec-researcher`, `type_specification_get` |
