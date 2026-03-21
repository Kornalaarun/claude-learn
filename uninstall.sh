#!/usr/bin/env bash
# Uninstall script for claude-learn

set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/learn"
LEARNING_DIR="$HOME/.claude/learning"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

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
echo -e "${BOLD}claude-learn uninstaller${NC}"
echo "======================="
echo ""

# --- Remove scheduled task ---
case "$OS" in
  macos)
    PLIST_PATH="$HOME/Library/LaunchAgents/com.claude.daily-reading.plist"
    if [ -f "$PLIST_PATH" ]; then
      launchctl unload "$PLIST_PATH" 2>/dev/null || true
      rm "$PLIST_PATH"
      info "Removed launchd job"
    fi
    ;;
  linux)
    if crontab -l 2>/dev/null | grep -q "daily-reading.sh"; then
      (crontab -l 2>/dev/null | grep -v "claude-learn daily email" | grep -v "daily-reading.sh") | crontab -
      info "Removed cron job"
    fi
    ;;
  windows)
    schtasks //Delete //TN "ClaudeDailyReading" //F 2>/dev/null && info "Removed scheduled task" || true
    ;;
esac

# --- Remove skill ---
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  rm "$SKILL_DIR/SKILL.md"
  rmdir "$SKILL_DIR" 2>/dev/null || true
  info "Removed /learn skill"
fi

# --- Remove daily email files ---
for f in daily-reading.sh daily-reading.bat .env daily-reading.log; do
  if [ -f "$LEARNING_DIR/$f" ]; then
    rm "$LEARNING_DIR/$f"
    info "Removed $f"
  fi
done

echo ""
warn "Learning data (goals, progress, profile) was NOT removed."
warn "To delete all learning data: rm -rf $LEARNING_DIR"
echo ""
info "Uninstall complete."
