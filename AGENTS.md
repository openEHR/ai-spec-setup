# openEHR spec workspace

This folder is the workspace root for openEHR specification and clinical-modelling work. It holds
the 18 `specifications-XX` repos side by side (plus `specifications-AA_GLOBAL`, whose boilerplate
and reference files the publishing build reads) and the `ai-spec-setup/` repo that configured it.
Always work from this root: build and generation steps resolve sibling repos relative to it.

## Skills

Skills are Agent Skills (`SKILL.md`). Load the matching one before acting:

- `authoring`, `review`, `governance`, `amendment-record`, `content-patterns`, `its-rest`,
  `class-generation`: openEHR specification documents (AsciiDoc, OpenAPI), from
  [openEHR/ai-plugins](https://github.com/openEHR/ai-plugins).
- `archetype-authoring`, `archetype-lint`, `template-authoring`, `composition-builder`,
  `aql-authoring`, `semantic-diff`, `demographic-modeling`, `openehr-assistant`: clinical
  modelling, from [Cadasto/openehr-assistant-plugin](https://github.com/Cadasto/openehr-assistant-plugin).

On Claude Code and Cursor these come from the installed plugins (namespaced `openehr-specs:` and
`openehr-assistant:`), together with subagents and the Docker action skills `publish`,
`regen-classes`, `scaffold`. On other hosts they are plain skills in `.agents/skills/`; the
Docker steps are then run by hand, see `ai-spec-setup/docs/example-is-blue.md`.

## MCP servers

- `discourse-openehr-org`: read-only access to discourse.openehr.org (community review of change requests).
- `atlassian`: Jira (`SPECRM-nnn`, `SPECBASE-nnn`, `SPECPR-nnn` change requests) and Confluence.
- `openehr-assistant` (bundled with the Cadasto plugin, or add `https://openehr-assistant-mcp.apps.cadasto.com/`
  as streamable-http): CKM search, RM/AM type specifications, terminology, guides, examples.

## Conventions

- Never hand-edit generated files (`docs/UML/classes/*.adoc`, `docs/*.html`): change the BMM in
  `computable/BMM/*.bmm.json` and regenerate.
- Do not commit in a `specifications-XX` repo unless asked; commit messages carry the Jira key.
- RM/AM attributes are `snake_case`; class names `UPPER_CASE`.
- Fact-check class and attribute names against the published specifications before writing them.
