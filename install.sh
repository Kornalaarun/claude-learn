#!/usr/bin/env bash
# Install script for claude-learn
# Works on macOS, Linux, and Windows (Git Bash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/learn"
LEARNING_DIR="$HOME/.claude/learning"
DAILY_SCRIPT="$LEARNING_DIR/daily-reading.sh"
ENV_FILE="$LEARNING_DIR/.env"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# --- Detect OS ---
detect_os() {
  case "$(uname -s)" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

OS=$(detect_os)

echo ""
echo -e "${BOLD}claude-learn installer${NC}"
echo "====================="
echo ""
echo "This will install:"
echo "  1. /learn skill for Claude Code"
echo "  2. (Optional) Daily learning email via Resend"
echo ""

# --- Pre-flight checks ---
if ! command -v claude &>/dev/null; then
  # Check common install locations
  if [ ! -f "$HOME/AppData/Roaming/npm/claude" ] && [ ! -f "$HOME/.npm-global/bin/claude" ]; then
    error "Claude Code CLI not found. Install it first: npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
fi

# --- Step 1: Install the /learn skill ---
info "Installing /learn skill..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
info "Skill installed to $SKILL_DIR/SKILL.md"

# Create learning state directory
mkdir -p "$LEARNING_DIR"

echo ""
info "Done! You can now use ${BOLD}/learn new${NC} in Claude Code to start a learning goal."

# --- Step 2: Optional daily email setup ---
echo ""
echo -e "${BOLD}Optional: Daily learning email${NC}"
echo "Get a curated daily reading recommendation emailed to you."
echo "Requires a free Resend account (https://resend.com)."
echo ""
read -p "Set up daily email? (y/N) " SETUP_EMAIL

if [[ ! "$SETUP_EMAIL" =~ ^[Yy]$ ]]; then
  echo ""
  info "Skipping email setup. Run ${BOLD}bash setup-email.sh${NC} anytime to set it up later."
  echo ""
  info "All done! Start learning with: ${BOLD}claude${NC} then type ${BOLD}/learn new${NC}"
  exit 0
fi

# --- Delegate to setup-email.sh ---
bash "$SCRIPT_DIR/setup-email.sh"

echo ""
info "All done! Start learning with: ${BOLD}claude${NC} then type ${BOLD}/learn new${NC}"
