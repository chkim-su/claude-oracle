#!/usr/bin/env bash
set -e

echo "🔮 Installing Claude Oracle..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
    *)          PLATFORM="unknown";;
esac

echo "📍 Detected platform: $PLATFORM"

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 is required but not installed."
    echo "   Please install Python 3.8+ and try again."
    exit 1
fi

# Check Python version (need 3.8+)
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 8 ]); then
    echo "❌ Error: Python 3.8+ is required. Found Python $PYTHON_VERSION"
    exit 1
fi

echo "✓ Python $PYTHON_VERSION detected"

# Set installation directory
INSTALL_DIR="$HOME/.oracle"

# Clean up any old installations that might conflict
OLD_LOCATIONS=(
    "$HOME/.local/bin/oracle"
    "$HOME/.local/bin/oracle.py"
    "/usr/local/bin/oracle"
)

for old_loc in "${OLD_LOCATIONS[@]}"; do
    if [ -f "$old_loc" ]; then
        echo "🧹 Removing old installation at $old_loc"
        rm -f "$old_loc"
    fi
done

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy files (convert line endings on the fly for safety)
echo "📦 Copying files..."
for file in oracle.py schemas.py oracle; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        # Use tr to remove any Windows line endings
        tr -d '\r' < "$SCRIPT_DIR/$file" > "$INSTALL_DIR/$file"
    fi
done

# Make oracle executable
chmod +x "$INSTALL_DIR/oracle"

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv "$INSTALL_DIR/venv"

# Install dependencies
echo "📦 Installing dependencies..."
"$INSTALL_DIR/venv/bin/pip" install -q --upgrade pip
"$INSTALL_DIR/venv/bin/pip" install -q google-genai requests Pillow

# Determine shell config file
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
else
    SHELL_RC="$HOME/.profile"
fi

# Add to PATH if not already present
if ! grep -q '\.oracle' "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo '# Claude Oracle' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.oracle:$PATH"' >> "$SHELL_RC"
    echo "✓ Added ~/.oracle to PATH in $SHELL_RC"
else
    echo "✓ PATH already configured in $SHELL_RC"
fi

# Install Claude Code command
CLAUDE_CMD_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_CMD_DIR"
if [ -f "$SCRIPT_DIR/commands/fullauto.md" ]; then
    tr -d '\r' < "$SCRIPT_DIR/commands/fullauto.md" > "$CLAUDE_CMD_DIR/fullauto.md"
    echo "✓ Installed /fullauto command for Claude Code"
fi

echo ""
echo "✅ Installation complete!"
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "⚠️  Set your API key:"
    echo '   echo '\''export GEMINI_API_KEY="your-key-here"'\'' >> '"$SHELL_RC"
    echo ""
    echo "   Get a free API key at: https://aistudio.google.com/apikey"
    echo ""
fi

echo "   Optional (for image generation in geo-restricted regions):"
echo '   echo '\''export VAST_API_KEY="your-vast-key"'\'' >> '"$SHELL_RC"
echo ""
echo "🔄 Restart terminal or run: source $SHELL_RC"
echo ""
echo "🚀 Usage:"
echo '   oracle ask "How should I implement X?"'
echo '   oracle imagine "A logo for my project"'
echo '   oracle quick "What is Python?"'
echo ""
echo "📖 Full documentation: https://github.com/your-repo/claude-oracle"
