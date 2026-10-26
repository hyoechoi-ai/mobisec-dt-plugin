#!/bin/bash
# MobiSec DT Plugin - Team Setup Script
# Configures Claude Code with eBay HubGPT + MCP Gateway connections
# Run once per machine: ./setup.sh

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BOLD}MobiSec DT Plugin Setup${NC}"
echo "================================"

# 1. Check Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code is not installed."
    echo "Install it from: https://claude.ai/code"
    exit 1
fi
echo -e "${GREEN}✓ Claude Code found${NC}"

# 2. Configure HubGPT gateway in ~/.claude/settings.json
SETTINGS_FILE="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Merge HubGPT settings using Python
python3 -I - <<'PYEOF'
import json, sys, os

path = os.path.expanduser("~/.claude/settings.json")
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault("apiKeyHelper", "npx @ebay/claude-code-token@latest get_token")
cfg.setdefault("env", {}).update({
    "ANTHROPIC_BASE_URL": "https://platformgateway2.vip.ebay.com/hubgptgatewaysvc/v1/anthropic",
    "ANTHROPIC_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_SUBAGENT_MODEL": "claude-sonnet-4-6",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_API_KEY_HELPER_TTL_MS": "360000000",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
    "DISABLE_TELEMETRY": "1"
})

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)

print("✓ HubGPT gateway configured")
PYEOF

# 3. Add eBay MCP backends
echo ""
echo -e "${YELLOW}Connecting eBay MCP backends...${NC}"
echo "(You may be prompted to authenticate with your eBay SSO account)"
echo ""

MCP_BASE="https://mcp.aigateway.vip.ebay.com/mcp/backends"

add_mcp() {
    local name=$1
    local url="$MCP_BASE/$name"
    echo -n "  Adding $name... "
    claude mcp add "$name" --transport http "$url" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo "(already exists or failed — check manually)"
}

add_mcp "atlassian"
add_mcp "jira"
add_mcp "google-drive"
add_mcp "google-sheets"
add_mcp "glean"
add_mcp "wiki"

echo ""
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo ""
echo "Usage:"
echo "  cd <your-project-directory>"
echo "  claude"
echo ""
echo "Available commands once in Claude Code:"
echo "  /dt-import      — Import Data Theorem CSV to Google Sheets"
echo "  /jira-security  — Create Jira Security ticket for a finding"
