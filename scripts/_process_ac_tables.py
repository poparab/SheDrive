"""
Reads the ADO batch result files + inline batch-1 data,
finds every work item whose AcceptanceCriteria contains an un-styled <table>,
applies border/width styling, and writes updates.json.
"""

import json, re, os

TOOL_DIR = r"C:\Users\Abdelrahman.Mamdouh\.claude\projects\D--Claude-SheDrive\6c84740b-9042-47d6-b164-25cbc6fc08fd\tool-results"

# Batch-1 items that have AcceptanceCriteria (others had none)
BATCH1 = [
    {
        "id": 1529,
        "ac": "<p><strong>Acceptance Criteria Rendering Test</strong> </p><p>The following structures should render correctly in Azure DevOps. </p><p><strong>Numbered list</strong> </p><ol><li>The acceptance criteria section displays an ordered list with visible numbering. </li><li>Each numbered item remains on its own line. </li><li>The numbering order is preserved after save and refresh. </li> </ol><p><strong>Bulleted list</strong> </p><ul><li>Bullet markers are visible. </li><li>Nested formatting is preserved. </li><li>Spacing remains readable in the work item form. </li> </ul><p><strong>Validation table</strong> </p><table border=1 cellpadding=6 cellspacing=0 width=\"100%\" style=\"border-collapse:collapse;border:1px solid #000;\"><thead><tr><th align=left style=\"border:1px solid #000;padding:6px;\">Element</th><th align=left style=\"border:1px solid #000;padding:6px;\">Expected Rendering</th><th align=left style=\"border:1px solid #000;padding:6px;\">Status To Verify</th></tr></thead><tbody><tr><td style=\"border:1px solid #000;padding:6px;\">Ordered list </td><td style=\"border:1px solid #000;padding:6px;\">Shows 1, 2, 3 numbering </td><td style=\"border:1px solid #000;padding:6px;\">Pending </td></tr><tr><td style=\"border:1px solid #000;padding:6px;\">Bulleted list </td><td style=\"border:1px solid #000;padding:6px;\">Shows bullet points with line separation </td><td style=\"border:1px solid #000;padding:6px;\">Pending </td></tr><tr><td style=\"border:1px solid #000;padding:6px;\">Table </td><td style=\"border:1px solid #000;padding:6px;\">Shows rows and columns in a readable grid </td><td style=\"border:1px solid #000;padding:6px;\">Pending </td></tr></tbody></table><p><strong>Final check</strong> </p><p>If all three sections render correctly in the Azure DevOps UI, this formatting test passes. </p>"
    },
    {
        "id": 1545,
        "ac": open(os.devnull).read() if False else None  # placeholder, set below
    },
    {
        "id": 1546,
        "ac": None  # placeholder, set below
    },
]

# Set ac values for 1545 and 1546 from the inline data we captured
AC_1545 = '<h3>Background </h3><p>The rider registration flow consists of two screens. Screen 1 collects the rider\'s Egyptian mobile number and, on tapping &quot;إرسال الرمز&quot; (Send Code), triggers OTP dispatch via #1620. Screen 2 collects the 6-digit OTP (auto-submits on the 6th digit entry) and the rider\'s full name, then creates the account via #1621. On success, the rider is taken to the home screen with an active session. If the phone number is already registered, the app displays a message and a link to the login flow. </p><h3>Field Validation </h3><table><thead><tr><th>Field</th><th>Required</th><th>Format</th><th>Min</th><th>Max</th><th>Accepted characters</th><th>Error — empty</th><th>Error — invalid format</th><th>Error — length</th></tr></thead><tbody><tr><td>Phone number </td><td>Yes </td><td>11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped </td><td>11 digits </td><td>11 digits </td><td>Digits only (after prefix stripping) </td><td>أدخل رقم هاتفك </td><td>رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً </td><td>رقم الهاتف يجب أن يكون 11 رقماً </td></tr><tr><td>OTP </td><td>Yes </td><td>6 digits, numeric keyboard </td><td>6 digits </td><td>6 digits </td><td>Digits only </td><td>أدخل رمز التحقق </td><td>رمز التحقق غير صحيح </td><td>رمز التحقق يجب أن يكون 6 أرقام </td></tr><tr><td>Full name </td><td>Yes </td><td>Arabic and/or Latin letters and spaces only; no digits or symbols </td><td>2 chars </td><td>50 chars </td><td>Arabic letters, Latin letters, spaces </td><td>أدخل اسمك الكامل </td><td>الاسم يجب أن يحتوي على حروف فقط </td><td>الاسم يجب أن يكون بين 2 و 50 حرفاً </td></tr></tbody></table><h3>Acceptance Criteria </h3><p><strong>Scenario 1 — Successful registration</strong> </p><ul><li>Given a new rider opens the app and taps &quot;إنشاء حساب&quot; </li><li>When she enters a valid Egyptian mobile number, receives and enters the correct 6-digit OTP, and enters a valid full name </li><li>Then her account is created and she is taken to the home screen with an active session </li></ul>'

AC_1546 = '<h3>Background </h3><p>The rider login flow consists of two screens. Screen 1 collects the rider\'s phone number; tapping &quot;إرسال الرمز&quot; triggers OTP dispatch via #1620. Screen 2 collects only the 6-digit OTP (no name field on login) and auto-submits on the 6th digit. On success, the rider is taken to the home screen with an active session. If the number is not registered, an error is shown. The OTP rules (5-minute expiry, 3-attempt limit, 60-second resend cooldown) are identical to registration. </p><h3>Field Validation </h3><table><thead><tr><th>Field</th><th>Required</th><th>Format</th><th>Min</th><th>Max</th><th>Accepted characters</th><th>Error — empty</th><th>Error — invalid format</th><th>Error — length</th></tr></thead><tbody><tr><td>Phone number </td><td>Yes </td><td>11-digit Egyptian mobile: 01[0125]XXXXXXXX; +20 prefix accepted and stripped </td><td>11 digits </td><td>11 digits </td><td>Digits only (after prefix stripping) </td><td>أدخل رقم هاتفك </td><td>رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً </td><td>رقم الهاتف يجب أن يكون 11 رقماً </td></tr><tr><td>OTP </td><td>Yes </td><td>6 digits, numeric keyboard </td><td>6 digits </td><td>6 digits </td><td>Digits only </td><td>أدخل رمز التحقق </td><td>رمز التحقق غير صحيح </td><td>رمز التحقق يجب أن يكون 6 أرقام </td></tr></tbody></table>'

BATCH1[1]["ac"] = AC_1545
BATCH1[2]["ac"] = AC_1546

# ── Styling constants ──────────────────────────────────────────────────────────
TABLE_STYLE = "border-collapse:collapse;width:100%;"
TH_STYLE    = "border:1px solid #d0d0d0;padding:8px 14px;background:#f3f4f6;text-align:left;font-weight:600;white-space:nowrap;"
TD_STYLE    = "border:1px solid #d0d0d0;padding:8px 14px;vertical-align:top;"


def inject_style(tag_text, extra):
    """Merge extra into a tag's style=, or add one."""
    m = re.search(r'style="([^"]*)"', tag_text, re.I)
    if m:
        merged = m.group(1).rstrip(";") + ";" + extra
        return tag_text[:m.start()] + f'style="{merged}"' + tag_text[m.end():]
    return re.sub(r"\s*/?>$", f' style="{extra}">', tag_text)


def already_styled(tag_text):
    """Return True if the tag already has border styling we don't need to add."""
    m = re.search(r'style="([^"]*)"', tag_text, re.I)
    if not m:
        return False
    style_val = m.group(1).lower()
    return "border:" in style_val or "border-collapse" in style_val


def fix_tables(html):
    if "<table" not in html.lower():
        return html, False
    # Skip entirely if ANY table in this item already has border styling
    for m in re.finditer(r"<table(?:\s[^>]*)?>", html, re.I):
        if already_styled(m.group(0)):
            return html, False
    orig = html
    html = re.sub(r"<table(?:\s[^>]*)?>",  lambda m: inject_style(m.group(0), TABLE_STYLE), html, flags=re.I)
    html = re.sub(r"<th(?:\s[^>]*)?>",     lambda m: inject_style(m.group(0), TH_STYLE),    html, flags=re.I)
    html = re.sub(r"<td(?:\s[^>]*)?>",     lambda m: inject_style(m.group(0), TD_STYLE),    html, flags=re.I)
    return html, html != orig


# ── Collect all items ──────────────────────────────────────────────────────────
all_items = []   # list of {"id": int, "ac": str}

# batch 1 (inline)
for entry in BATCH1:
    if entry["ac"]:
        all_items.append({"id": entry["id"], "ac": entry["ac"]})

# batches 2, 3, 4 from saved files
saved_files = [
    os.path.join(TOOL_DIR, "mcp-azure-devops-wit_get_work_items_batch_by_ids-1780487184328.txt"),
    os.path.join(TOOL_DIR, "toolu_01UX7KLnpjJcREz8WL8qYxRk.json"),
    os.path.join(TOOL_DIR, "mcp-azure-devops-wit_get_work_items_batch_by_ids-1780487190241.txt"),
]

for fpath in saved_files:
    if not os.path.exists(fpath):
        print(f"WARNING: file not found: {fpath}")
        continue
    with open(fpath, encoding="utf-8") as f:
        raw = f.read()
    # The files may be plain-text JSON or wrapped JSON
    # Try parsing directly; if it's the persisted-output JSON wrapper, extract text
    try:
        parsed = json.loads(raw)
        # If it's a list of work item objects
        if isinstance(parsed, list):
            items = parsed
        # If it's the persisted wrapper {"type":"text","text":"[...]"}
        elif isinstance(parsed, dict) and "text" in parsed:
            items = json.loads(parsed["text"])
        elif isinstance(parsed, list) and parsed and "text" in parsed[0]:
            items = json.loads(parsed[0]["text"])
        else:
            items = []
    except json.JSONDecodeError:
        # Plain text JSON array
        try:
            items = json.loads(raw)
        except Exception as e:
            print(f"ERROR parsing {fpath}: {e}")
            items = []

    for item in items:
        ac = item.get("fields", {}).get("Microsoft.VSTS.Common.AcceptanceCriteria")
        if ac:
            all_items.append({"id": item["id"], "ac": ac})

# ── Process and collect updates ────────────────────────────────────────────────
updates = []
for item in all_items:
    new_ac, changed = fix_tables(item["ac"])
    if changed:
        updates.append({"id": item["id"], "new_ac": new_ac})

# ── Write output ──────────────────────────────────────────────────────────────
out_path = r"D:\Claude\SheDrive\_ac_updates.json"
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(updates, f, ensure_ascii=False, indent=2)

print(f"Items scanned : {len(all_items)}")
print(f"Need updating : {len(updates)}")
print(f"IDs to update : {[u['id'] for u in updates]}")
print(f"Output written: {out_path}")
