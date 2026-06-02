# SheDrive BRD and SRS

Use this skill when writing or reviewing BRD, SRS, scope, assumptions, dependencies, or traceability for SheDrive.

## Workflow

1. Read the latest BRD source in the root draft files or the normalized product docs in `docs/product/`.
2. Check `docs/product/open-decisions.md` before assuming any provider, threshold, operating hour, or business rule.
3. Separate:
   - business objective
   - in-scope behavior
   - out-of-scope behavior
   - assumptions
   - open decisions
4. When writing SRS material, make requirements testable and map them back to source artifacts.

## Guardrails

- Do not turn unknowns into facts.
- Keep admin portal requirements separate from rider and driver app requirements.
- Keep bilingual implications visible where they affect user behavior.
