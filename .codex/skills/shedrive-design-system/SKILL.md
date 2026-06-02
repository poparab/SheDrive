# SheDrive Design System

Use this skill for CSS and component governance in the static web mockup.

## Workflow

1. Check `shared/styles/tokens.css` before adding new styling.
2. Reuse `.btn`, `.input`, shared layout classes, and shared components where possible.
3. Replace hardcoded values with tokens unless an approved exception applies.
4. Watch for inline styles and one-off component drift.

## Guardrails

- No build step.
- No framework runtime.
- No screen-specific behavior inside shared files.
