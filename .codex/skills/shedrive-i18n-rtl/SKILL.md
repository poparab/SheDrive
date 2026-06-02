# SheDrive i18n and RTL

Use this skill for Arabic and English content reviews and RTL checks.

## Workflow

1. Scan for `data-i18n`, `data-i18n-placeholder`, `data-i18n-aria-label`, and `data-i18n-value`.
2. Check that new keys exist in both locale files.
3. Verify Arabic fallback text remains in HTML.
4. Check that directional layout still works in RTL and LTR.

## Guardrails

- Never allow hardcoded `aria-label` values without a translation key pair.
- Do not mix Arabic and English in the same visible text node.
