# MobiSec DT Plugin

eBay Mobile Security — Data Theorem vulnerability tracker automation for Claude Code.

Automates importing Data Theorem CSV findings into cumulative Google Sheets trackers, with Risk Acceptance matching, Korean translation (Qoo10), and Jira Security ticket creation.

## Quick Start

```bash
git clone https://github.com/hyoechoi-ai/mobisec-dt-plugin.git
cd mobisec-dt-plugin
chmod +x setup.sh
./setup.sh
```

Then from any directory:

```bash
claude
```

## Available Commands

| Command | Description |
|---------|-------------|
| `/dt-import` | Import Data Theorem CSV → Google Sheets tracker |
| `/jira-security` | Create Jira Security ticket for a finding |

## Usage Example

```
> /dt-import

CSV path: ~/Downloads/policy_violations-2026-10-26.csv
App name: Qoo10
Platform: Android
Version: 5.6.5

→ Finds or creates "Qoo10-Android" tracker
→ Deduplicates against existing issues
→ Matches Risk Acceptance history
→ Translates new descriptions to Korean
→ Updates Google Sheet with formatting
→ Reports: 95 uploaded / 12 new / 83 matched
```

## Prerequisites

- Claude Code installed
- eBay network access (VPN or office)
- eBay SSO account
- Node.js (for `@ebay/claude-code-token`)

## What setup.sh Does

1. Configures Claude Code to use eBay HubGPT (`platformgateway2.vip.ebay.com`)
2. Connects 6 MCP backends via eBay AI Gateway (`mcp.aigateway.vip.ebay.com`):
   - `atlassian` — Jira/Confluence
   - `jira` — Jira (direct)
   - `google-sheets` — Google Sheets read/write
   - `google-drive` — Google Drive file management
   - `glean` — Internal search
   - `wiki` — Internal wiki

Auth for each MCP backend is handled automatically via your eBay SSO session.

## Tracker Schema

Each app gets one cumulative Google Sheet: `<App name>-<Platform>`

19 columns: Jira Ticket | Severity - eBay | Status - eBay | Risk Accepted | `<App>` Team's feedback | MobiSec Feedback | App Version | Issue ID | Title | Description | Description (Korean)* | Severity - DT | Status - DT | Recommendation | Secure Code | Affected Asset | Asset Tags | Additional Information | Date Created

*Korean column is Qoo10-only.

## Support

Internal: `#ebaymobilesec` Slack channel
