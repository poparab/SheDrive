# SheDrive User Stories

Use this skill for backlog refinement, story writing, acceptance criteria, validation tables, scope boundaries, and INVEST checks.

## Workflow

1. Start from `docs/backlog/mvp-user-stories.md` and the root `MVP-BACKLOG.md`.
2. Confirm the module, persona, business value, and release priority.
3. Write the story using the project story format.
4. Add:
   - form validation table when forms exist
   - grid specification when lists or tables exist
   - scope boundary note when part of a multi-step flow
   - UX notes when the story drives mockups
   - Azure DevOps HTML formatting when the destination is a work item
5. Run a no-repeat pass.
6. Run an INVEST pass.

## Guardrails

- Plain English only.
- No implementation details.
- No vague field categories.

## Azure DevOps Formatting Rules

When the story or acceptance criteria will be created or updated in Azure DevOps:

- Use HTML for `System.Description` and `Microsoft.VSTS.Common.AcceptanceCriteria`.
- Use real HTML lists for numbered and bulleted content:
  - numbered: `<ol><li>...</li></ol>`
  - bulleted: `<ul><li>...</li></ul>`
- Do not use Markdown tables in Azure DevOps fields.
- For tables, use an HTML table with explicit borders and padding.
- Use this baseline pattern:

```html
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse; border:1px solid #000;">
  <thead>
    <tr>
      <th align="left" style="border:1px solid #000; padding:6px;">Column A</th>
      <th align="left" style="border:1px solid #000; padding:6px;">Column B</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border:1px solid #000; padding:6px;">Value A1</td>
      <td style="border:1px solid #000; padding:6px;">Value B1</td>
    </tr>
  </tbody>
</table>
```

- Keep table content short enough to avoid visual collapse in the Azure DevOps editor.
- If a table is still visually unreliable, prefer a short list or a plain text grid over a borderless table.
