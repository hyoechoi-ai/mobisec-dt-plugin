---
name: dt-import
description: Import a Data Theorem policy violations CSV into the cumulative Google Sheets tracker for a specific app and platform. Handles dedup, Risk Acceptance matching, Korean translation (Qoo10), Status lifecycle, and formatting.
---

# Data Theorem CSV Import

## Step 0 — Collect Inputs

Ask for any missing input before proceeding. Required:
- **CSV file path** (local path to the Data Theorem `policy_violations-*.csv`)
- **App name** (e.g. `Qoo10`, `eBay`)
- **Platform** (`Android` or `iOS` — canonicalize case-insensitively)
- **Version** (e.g. `5.6.5`)

Never infer missing inputs. If more than one CSV is supplied, ask which to use.

## Step 1 — Parse CSV

Read the CSV with proper quoting/escape handling. Locate headers `Issue ID` and `Title` by trimmed, case-insensitive match — both are required, stop if missing.

Rename source columns:
- `Severity` → `Severity - DT`
- `Status` → `Status - DT`

Preserve all values and row order exactly.

## Step 2 — Load Risk Acceptance Master

Select the platform-specific master:
- Android: spreadsheet `1P04a3-BiDotay_jx2rFDimLxfhBjgjaO-WO5doPBZPA`
- iOS: spreadsheet `1JZt8AQ5wUnh6jQhiFOZZTjZomIOeehZp33j0K43crhE`

Read complete used range. Match only rows where `Status` = `Risk Accepted` (case-insensitive).

For each uploaded issue, find matching master records by:
1. Non-empty Issue ID → exact Issue ID match
2. Empty Issue ID → exact normalized Title match against rows with empty Issue ID

Build `Risk Accepted` cell value:
- No match: `None`
- One match: `Affected Asset: <val> | Date Created: <val> | Issue ID: <val>`
- Multiple: one record per line, newest Date Created first

## Step 3 — Find or Create Tracker

Search for spreadsheet titled exactly `<App name>-<Platform>`:
- 0 matches → create new spreadsheet with that title
- 1 match → use it
- 2+ matches → stop, return links for user to choose

## Step 4 — Read Existing Tracker

Read the complete current used range. Build a dedup index:
- Non-empty Issue ID → keyed by normalized Issue ID (trimmed, lowercased)
- Empty Issue ID → keyed by normalized Title

Detect conflicts: multiple existing rows with same non-empty Issue ID → stop and report row numbers.

## Step 5 — Plan All Changes (no writes yet)

For each uploaded issue:

**If matched (existing issue):**
- Add current Version to App Version if not already present (prepend)
- Do NOT touch any other field

**If new (no match):**
- Prepare full canonical row (see schema below)
- For Qoo10: translate Description to Korean before appending
- Status - eBay = `New`
- App Version = current Version only

Also plan: all pre-existing rows with Status - eBay = `New` → change to `Open`

Validate for upload duplicates (same non-empty Issue ID appearing twice in CSV) — stop if found.

## Step 6 — Apply Canonical Schema

Column order for every tracker:

| # | Column |
|---|--------|
| 1 | Jira Ticket |
| 2 | Severity - eBay |
| 3 | Status - eBay |
| 4 | Risk Accepted |
| 5 | `<App name>` Team's feedback |
| 6 | MobiSec Feedback |
| 7 | App Version |
| 8 | Issue ID |
| 9 | Title |
| 10 | Description |
| 11 | Description (Korean) — **Qoo10 only**, immediately after Description |
| 12+ | Remaining source columns in original order |

New rows: leave Jira Ticket and Severity - eBay empty.

## Step 7 — Write to Sheets

For new/migrated tracker: write full range from A1 with RAW input.

For existing tracker:
1. Batch-update `New → Open` transitions (only those cells)
2. Batch-update App Version cells for matched issues (only those cells)
3. Append new rows at bottom with INSERT_ROWS + RAW

Never overwrite: Jira Ticket, Severity - eBay, Status - eBay, feedback columns, existing Korean translations.

## Step 8 — Apply Formatting

Resolve all column positions from the live header after writing. Never use hard-coded column letters.

**Column widths (pixels):**
Jira Ticket: 100 | Severity - eBay: 100 | Status - eBay: 100 | Risk Accepted: 200
`<App>` Team's feedback: 100 | MobiSec Feedback: 100 | App Version: 100
Issue ID: 85 | Title: 260 | Description: 440 | Description (Korean): 440
Severity - DT: 70 | Status - DT: 100 | Recommendation: 600 | Secure Code: 600
Affected Asset: 100 | Asset Tags: 230 | Additional Information: 600 | Date Created: 100

**Text wrap:** columns A through Description (Korean) if present, else through Description.

**Severity - DT colors (body rows):**
- High → bg `#D93025`, text `#FFFFFF`, bold
- Medium → bg `#F9AB00`, text `#3C2A00`, bold
- Low → bg `#34A853`, text `#FFFFFF`, bold

**Status - eBay colors (body rows, center-aligned):**
- New → bg `#D93025`, text `#FFFFFF`, bold
- Open → bg `#F4C7C3`, text `#7A1C16`, bold
- In Progress → bg `#F9AB00`, text `#3C2A00`, bold
- Done → bg `#34A853`, text `#FFFFFF`, bold
- Blank/other → bg `#E0E0E0`, text `#333333`, bold

**Severity - eBay colors (body rows, center-aligned):**
- P1 → bg `#D93025`, text `#FFFFFF`, bold
- P2 → bg `#F9AB00`, text `#3C2A00`, bold
- P3 → bg `#34A853`, text `#FFFFFF`, bold
- Blank/other → bg `#FFFFFF`, text `#333333`, bold

**Header row (last formatting step):** bg `#3665F3`, white bold text, center-aligned, WRAP, full used width only.

Freeze row 1. Auto-resize row heights for data rows and row 1 separately (never auto-resize columns).

## Step 9 — Report

Return:
- Tracker title and link
- App, Platform, Version
- Counts: uploaded / new / matched
- New→Open transitions
- Version updates
- Risk Accepted matches for new issues
- Korean translations (Qoo10)
- Severity - DT distribution
- Any warnings (unexpected Status - eBay values, etc.)

## Qoo10 Korean Translation Rules

Translate Description into natural Korean. Preserve exactly:
- Code, API names, class/method names, package paths
- URLs, commands, keys, vulnerability identifiers
- Inline code, code blocks, paragraphs, bullet structure

Translate explanatory prose accurately without summarizing, omitting detail, or adding remediation content. Leave Description (Korean) empty when Description is empty.
