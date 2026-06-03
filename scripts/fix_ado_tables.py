#!/usr/bin/env python3
"""
Fix table formatting in Azure DevOps work items for the SheDrive project.
Adds borders and full-width layout to every table in every work item description.

Usage:
    python fix_ado_tables.py

Set ORG_URL and PAT below before running.
"""

import urllib.request
import json
import base64
import re

# ── Configure these ──────────────────────────────────────────────────────────
ORG_URL = "https://dev.azure.com/YOUR_ORG"  # e.g. https://dev.azure.com/acme
PAT     = "YOUR_PAT_HERE"                    # Azure DevOps Personal Access Token
PROJECT = "SheDrive"
API_VER = "7.0"
# ─────────────────────────────────────────────────────────────────────────────

# Styles applied to each element
TABLE_STYLE = (
    "border-collapse:collapse;"
    "width:100%;"
)
TH_STYLE = (
    "border:1px solid #d0d0d0;"
    "padding:8px 14px;"
    "background:#f3f4f6;"
    "text-align:left;"
    "font-weight:600;"
    "white-space:nowrap;"
)
TD_STYLE = (
    "border:1px solid #d0d0d0;"
    "padding:8px 14px;"
    "vertical-align:top;"
)


# ── HTTP helpers ──────────────────────────────────────────────────────────────

def _auth_headers(content_type="application/json"):
    token = base64.b64encode(f":{PAT}".encode()).decode()
    return {
        "Authorization": f"Basic {token}",
        "Content-Type": content_type,
        "Accept": "application/json",
    }


def _get(url):
    req = urllib.request.Request(url, headers=_auth_headers())
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode())


def _post(url, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers=_auth_headers(), method="POST")
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode())


def _patch(url, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        url, data=data,
        headers=_auth_headers("application/json-patch+json"),
        method="PATCH",
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode())


# ── HTML patching ─────────────────────────────────────────────────────────────

def _inject_style(tag_text, extra_style):
    """Merge extra_style into an HTML opening tag's style attribute."""
    existing = re.search(r'style="([^"]*)"', tag_text, re.IGNORECASE)
    if existing:
        merged = existing.group(1).rstrip(";") + ";" + extra_style
        return tag_text[: existing.start()] + f'style="{merged}"' + tag_text[existing.end() :]
    # No style attribute — add one just before the closing >
    return re.sub(r"\s*/?>$", f' style="{extra_style}">', tag_text)


def fix_tables(html):
    """
    Add border / width styles to <table>, <th>, and <td> tags.
    Returns (new_html, changed: bool).
    Already-styled elements get their styles merged, not replaced.
    """
    if "<table" not in html.lower():
        return html, False

    original = html

    html = re.sub(
        r"<table(?:\s[^>]*)?>",
        lambda m: _inject_style(m.group(0), TABLE_STYLE),
        html, flags=re.IGNORECASE,
    )
    html = re.sub(
        r"<th(?:\s[^>]*)?>",
        lambda m: _inject_style(m.group(0), TH_STYLE),
        html, flags=re.IGNORECASE,
    )
    html = re.sub(
        r"<td(?:\s[^>]*)?>",
        lambda m: _inject_style(m.group(0), TD_STYLE),
        html, flags=re.IGNORECASE,
    )

    return html, html != original


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    base = f"{ORG_URL}/{PROJECT}/_apis"

    # 1. Fetch all work item IDs via WIQL
    print(f"Querying all work items in '{PROJECT}'...")
    wiql_result = _post(
        f"{base}/wit/wiql?api-version={API_VER}",
        {"query": f"SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = '{PROJECT}' ORDER BY [System.Id]"},
    )
    ids = [wi["id"] for wi in wiql_result.get("workItems", [])]
    print(f"Found {len(ids)} work items\n")

    updated = skipped = errors = 0

    # 2. Process in batches of 200 (ADO API limit)
    batch_size = 200
    for i in range(0, len(ids), batch_size):
        chunk = ids[i : i + batch_size]
        ids_str = ",".join(str(x) for x in chunk)

        items = _get(
            f"{base}/wit/workitems"
            f"?ids={ids_str}"
            f"&fields=System.Id,System.Description"
            f"&api-version={API_VER}"
        ).get("value", [])

        for item in items:
            wid = item["id"]
            desc = (item.get("fields") or {}).get("System.Description") or ""

            new_desc, changed = fix_tables(desc)

            if not changed:
                skipped += 1
                continue

            try:
                _patch(
                    f"{ORG_URL}/{PROJECT}/_apis/wit/workitems/{wid}?api-version={API_VER}",
                    [{"op": "add", "path": "/fields/System.Description", "value": new_desc}],
                )
                print(f"  ✓ #{wid}")
                updated += 1
            except Exception as exc:
                print(f"  ✗ #{wid}: {exc}")
                errors += 1

    print(f"\nDone — updated: {updated}  skipped (no tables): {skipped}  errors: {errors}")


if __name__ == "__main__":
    main()
