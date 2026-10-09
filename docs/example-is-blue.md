# Worked example: add `is_blue` to `COMPOSITION` (RM)

Goal: in the RM repo, add a new boolean property to the `COMPOSITION` class, regenerate the
BMM-derived class table, rebuild the HTML, inspect, discard. Exercises `openehr-specs`
class-generation, regen-classes and publish end to end. Nothing is committed.

Naming: BMM/RM attributes are `snake_case`, so the property is `is_blue` (not `isBlue`).
The generated table shows it as `is_blue: Boolean`.

## 0. Preconditions

- Steps 0 to 5 of [the README](../README.md) done; Docker running.
- Claude Code started in `openehr-spec/` (the folder holding `specifications-RM/`, `specifications-BASE/` and `specifications-AA_GLOBAL/` side by side).

```sh
git -C specifications-RM switch -c try/is-blue
```

## 1. Edit the BMM

File: `specifications-RM/computable/BMM/openehr_rm_1.2.0.bmm.json`, key
`class_definitions.COMPOSITION.properties`. Add a sibling of `category`:

```json
"is_blue": {
  "_type": "P_BMM_SINGLE_PROPERTY",
  "name": "is_blue",
  "documentation": "True if this Composition is blue. (Exercise property, remove before commit.)",
  "is_mandatory": false,
  "type": "Boolean"
}
```

Prompt that does it for you:

```text
In specifications-RM, add an optional Boolean property is_blue to COMPOSITION in
computable/BMM/openehr_rm_1.2.0.bmm.json, documentation "True if this Composition is blue."
Edit the BMM only; do not touch generated files.
```

Generated files (`docs/UML/classes/*.adoc`) are never hand-edited: change the BMM, regenerate.

## 2. Regenerate the class tables

RM depends on BASE, so pass the BASE schema as a dependency. Run inside `specifications-RM`:

```text
/openehr-specs:regen-classes openehr_rm_1.2.0 -d openehr_base_1.3.0
```

Behind the scenes (what the skill runs):

```sh
docker run --rm --user $(id -u):$(id -g) \
  -v "$PWD/computable/BMM/openehr_rm_1.2.0.bmm.json":/in/openehr_rm_1.2.0.bmm.json:ro \
  -v "$PWD/../specifications-BASE/computable/BMM/openehr_base_1.3.0.bmm.json":/in/openehr_base_1.3.0.bmm.json:ro \
  -v ./out:/app/output \
  ghcr.io/openehr/bmm-publisher legacy-adoc -o /app/output/UML/classes \
  -v /in/openehr_rm_1.2.0.bmm.json -d /in/openehr_base_1.3.0.bmm.json
```

RM uses the `legacy-adoc` layout because its chapters include
`{uml_export_dir}/classes/{pkg}composition.adoc`
(`docs/ehr/master05-composition_package.adoc`, line ~101). Output lands in `./out/UML/classes/`.
Check the new row:

```sh
grep -n is_blue out/UML/classes/org.openehr.rm.composition.composition.adoc
```

Then place it (the skill asks before writing into `docs/UML/`):

```text
Copy the regenerated class tables from out/UML/classes into docs/UML/classes following the
class-generation skill, and show me the diff for org.openehr.rm.composition.composition.adoc.
```

## 3. Rebuild the HTML

From the workspace root (needs the sibling `specifications-AA_GLOBAL/`):

```text
/openehr-specs:publish RM
```

The skill compares `docs/*.html` timestamps before and after and greps the log for `ERROR` /
`include file not found`, because the image exits 0 even on failure. Open
`specifications-RM/docs/ehr.html`, section "COMPOSITION Class", and look for `is_blue`.

## 4. Optional: record it like a real change

```text
/openehr-specs:amendment-record SPECRM-999 - add is_blue to COMPOSITION (exercise, key is made up)
```

For a real change, look the key up via the Jira MCP first (`searchJiraIssuesUsingJql`,
project `SPECRM`) and check the forum thread with `discourse_search`.

## 5. Discard

```sh
git -C specifications-RM restore .
git -C specifications-RM clean -fd out
git -C specifications-RM switch -
git -C specifications-RM branch -D try/is-blue
```
