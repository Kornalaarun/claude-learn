#!/usr/bin/env bash
# Standalone daily email setup for claude-learn
# Run this anytime to set up or reconfigure the daily learning email.
# Also called by install.sh during initial setup.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
echo -e "${BOLD}claude-learn — daily email setup${NC}"
echo "================================="
echo ""
echo "Get a curated daily reading recommendation emailed to you."
echo "Requires a free Resend account (https://resend.com)."
echo ""

# --- Ensure learning dir exists ---
mkdir -p "$LEARNING_DIR"

# --- Collect email config ---
if [ -f "$ENV_FILE" ]; then
  warn "Existing .env found at $ENV_FILE"
  read -p "Overwrite? (y/N) " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    info "Keeping existing .env"
    source "$ENV_FILE"
  fi
fi

if [ -z "${RESEND_API_KEY:-}" ]; then
  read -p "Resend API key: " RESEND_API_KEY
fi
if [ -z "${LEARNING_EMAIL:-}" ]; then
  read -p "Email address to receive recommendations: " LEARNING_EMAIL
fi

# Write .env
cat > "$ENV_FILE" <<EOF
RESEND_API_KEY=$RESEND_API_KEY
LEARNING_EMAIL=$LEARNING_EMAIL
EOF
chmod 600 "$ENV_FILE"
info "Config saved to $ENV_FILE"

# --- Install the daily script ---
cp "$SCRIPT_DIR/daily-email/daily-reading.sh" "$DAILY_SCRIPT"
chmod +x "$DAILY_SCRIPT"
info "Daily script installed to $DAILY_SCRIPT"

# --- Schedule based on OS ---
echo ""
read -p "What time should the daily email arrive? (HH:MM, 24h format, default 09:00) " SEND_TIME
SEND_TIME="${SEND_TIME:-09:00}"
HOUR="${SEND_TIME%%:*}"
MINUTE="${SEND_TIME##*:}"

case "$OS" in
  macos)
    PLIST_NAME="com.claude.daily-reading"
    PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"

    info "Setting up launchd schedule (macOS)..."

    cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$DAILY_SCRIPT</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$HOUR</integer>
        <key>Minute</key>
        <integer>$MINUTE</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$LEARNING_DIR/daily-reading.log</string>
    <key>StandardErrorPath</key>
    <string>$LEARNING_DIR/daily-reading.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$HOME/.npm-global/bin</string>
    </dict>
</dict>
</plist>
EOF

    # Unload if already loaded, then load
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    launchctl load "$PLIST_PATH"
    info "launchd job loaded: $PLIST_NAME"
    info "Runs daily at $SEND_TIME"
    ;;

  linux)
    info "Setting up cron schedule (Linux)..."

    CRON_ENTRY="$MINUTE $HOUR * * * /bin/bash $DAILY_SCRIPT >> $LEARNING_DIR/daily-reading.log 2>&1"
    CRON_MARKER="# claude-learn daily email"

    # Remove old entry if present, then add new one
    (crontab -l 2>/dev/null | grep -v "$CRON_MARKER" | grep -v "daily-reading.sh"; echo "$CRON_ENTRY $CRON_MARKER") | crontab -
    info "Cron job installed"
    info "Runs daily at $SEND_TIME"
    ;;

  windows)
    info "Setting up Windows Task Scheduler..."

    # Create the .bat wrapper
    BAT_FILE="$LEARNING_DIR/daily-reading.bat"
    # Find Git Bash
    GIT_BASH=""
    if [ -f "/c/Program Files/Git/usr/bin/bash.exe" ]; then
      GIT_BASH="C:\\Program Files\\Git\\usr\\bin\\bash.exe"
    elif [ -f "/c/Program Files (x86)/Git/usr/bin/bash.exe" ]; then
      GIT_BASH="C:\\Program Files (x86)\\Git\\usr\\bin\\bash.exe"
    else
      error "Git Bash not found. Please install Git for Windows."
      exit 1
    fi

    # Write .bat wrapper — convert path for Windows
    WIN_SCRIPT=$(cygpath -w "$DAILY_SCRIPT")
    cat > "$BAT_FILE" <<EOF
"$GIT_BASH" -l -c "$WIN_SCRIPT"
EOF

    WIN_BAT=$(cygpath -w "$BAT_FILE")

    # Create scheduled task — allow running on battery
    schtasks //Create //F \
      //TN "ClaudeDailyReading" \
      //TR "\"$WIN_BAT\"" \
      //SC DAILY \
      //ST "$SEND_TIME" \
      //RL HIGHEST 2>&1 | grep -i "success" || warn "Task creation may need admin rights"

    # Allow running on battery
    powershell.exe -Command '
      $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
      Set-ScheduledTask -TaskName "ClaudeDailyReading" -Settings $settings
    ' 2>/dev/null || warn "Could not update battery settings — task may not run on battery"

    info "Scheduled task 'ClaudeDailyReading' created"
    info "Runs daily at $SEND_TIME (even on battery)"
    ;;

  *)
    warn "Unknown OS. You'll need to schedule $DAILY_SCRIPT manually."
    warn "It should run once daily via bash."
    ;;
esac

# --- Send test email ---
echo ""
read -p "Send a test email now? (Y/n) " SEND_TEST
SEND_TEST="${SEND_TEST:-Y}"

if [[ "$SEND_TEST" =~ ^[Yy]$ ]]; then
  info "Sending test email to $LEARNING_EMAIL..."
  TEST_BODY='<div style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;"><h3>Setup complete!</h3><p>Your daily learning emails are configured and working.</p><p style="color: #999; font-size: 11px;">Sent by claude-learn installer</p></div>'

  PYTHON_CMD="python3"
  if ! command -v python3 &>/dev/null; then
    PYTHON_CMD="python"
  fi
  EMAIL_JSON=$(printf '%s' "$TEST_BODY" | "$PYTHON_CMD" -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST 'https://api.resend.com/emails' \
    -H "Authorization: Bearer $RESEND_API_KEY" \
    -H 'Content-Type: application/json' \
    -d "{
      \"from\": \"onboarding@resend.dev\",
      \"to\": [\"$LEARNING_EMAIL\"],
      \"subject\": \"claude-learn — setup complete\",
      \"html\": $EMAIL_JSON
    }" 2>&1)

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  if [ "$HTTP_CODE" = "200" ]; then
    info "Test email sent! Check your inbox."
  else
    error "Email failed (HTTP $HTTP_CODE). Check your Resend API key."
    echo "$RESPONSE" | head -1
  fi
fi

echo ""
info "Daily email setup complete!"
