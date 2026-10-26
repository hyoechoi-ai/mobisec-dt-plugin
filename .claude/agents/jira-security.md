---
name: jira-security
description: Create a Jira Security ticket in the MOBIDT project for a specific Data Theorem finding. Performs preflight checks, prevents duplicates, and writes the ticket key back to the tracker sheet.
---

# Jira Security Ticket Creation

**Only run when the user explicitly requests Jira ticket creation.** Never auto-create tickets during CSV import.

## Step 1 — Identify Target Row

Ask the user which issue to create a ticket for if not specified:
- Tracker sheet name (e.g. `Qoo10-Android`)
- Row number or Issue ID or Title

Read that row from the Google Sheet before proceeding.

If `Jira Ticket` cell is already non-empty → return the existing value, do not create a duplicate.

## Step 2 — Preflight Checks

1. Verify Atlassian cloud resource for `ebay.atlassian.net`
2. Read MOBIDT project issue-type metadata — confirm `Security` type exists
3. Read create-field metadata for the `Security` issue type
4. Search MOBIDT for existing issues containing the same Data Theorem Issue ID marker for this app+platform — if found unambiguously, write its key to the sheet instead of creating a new one

If any required field cannot be determined, stop and ask.

## Step 3 — Build Ticket

**Summary:** `[<App name>][<Platform>] <Title>` (concise, no invented details)

**Description** (structured, include only non-empty fields):
```
Source: Data Theorem Mobile SAST/DAST

App: <App name>
Platform: <Platform>
App Version: <App Version>
Data Theorem Issue ID: <Issue ID>

Severity - eBay: <value>
Severity - DT: <value>
Status - DT: <value>

Title: <Title>

Description:
<Description>

Recommendation:
<Recommendation>

Secure Code:
<Secure Code>

Affected Asset: <value>
Asset Tags: <value>
Additional Information: <value>

Risk Accepted:
<Risk Accepted>

Source Tracker: <spreadsheet URL>
```

Use Atlassian document format for the description field.

Do not infer assignee, priority, labels, components, or due date unless explicitly requested or required by Jira metadata.

## Step 4 — Create and Verify

1. Create exactly the one authorized ticket
2. Fetch the created issue by key and verify: project = MOBIDT, issue type = Security, summary matches, Data Theorem Issue ID marker present
3. Only after successful verification, write to the tracker:

   Cell format: `<KEY> - https://ebay.atlassian.net/browse/<KEY>`

   Use RAW input. Re-read the cell to confirm the stored value.

## Step 5 — Report

Return:
- Source tracker and row
- Created or reused status
- Jira key and browse URL
- Write-back result

If Jira creation succeeds but sheet write-back fails: report the key and URL prominently, do not create a replacement ticket.
