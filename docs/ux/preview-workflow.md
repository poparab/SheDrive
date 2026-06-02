# SheDrive Mockup Preview Workflow

## Preferred daily preview path

Use a static preview method that does not depend on Python as your normal workflow.

Recommended order:

1. VS Code Live Server
2. Static hosting preview such as Cloudflare Pages
3. Python static server only as fallback

## Why

The SheDrive mockups use ES modules, locale JSON fetches, and Mapbox assets. That means direct file-open is not reliable for the full experience.

## Working rule

- Treat Python preview as optional fallback, not the default working habit.
- Keep all mockups compatible with normal static hosting.
- Avoid introducing any step that would require Node or a build pipeline.
