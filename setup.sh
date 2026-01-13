#!/bin/bash

if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    # This will prompt for `sudo` password and install Xcode CLI tools before installing Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update

# Installing bun via Brewfile doesn't work
brew tap oven-sh/bun
brew install bun

GIT_REPO="https://github.com/sixsat/dev-setup.git"
TARGET_DIR="$HOME/Documents/personal/dev-setup"
if [ ! -d "$TARGET_DIR" ]; then
    echo "📥 Cloning repo..."
    # Git should be installed with Xcode CLI tools
    git clone "$GIT_REPO" "$TARGET_DIR"
else
    echo "📂 Repo already exist. Updating..."
    git -C "$TARGET_DIR" pull
fi

# ⌛️ This step might take some time to run and may require additional `sudo` password
echo "📦 Installing packages from Brewfile..."
if [ -f "$TARGET_DIR/Brewfile" ]; then
    brew bundle --file="$TARGET_DIR/Brewfile"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🪄 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "🎨 Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

echo "⚙️ Copying configurations..."
KARABINER_CFG_DIR="$HOME/.config/karabiner"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
GHOSTTY_CFG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
cp -f "$TARGET_DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"
cp -f "$TARGET_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
cp -f "$TARGET_DIR/dotfiles/.zprofile" "$HOME/.zprofile"
cp -f "$TARGET_DIR/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
mkdir -p "$KARABINER_CFG_DIR"
cp -f "$TARGET_DIR/dotfiles/.config/karabiner/karabiner.json" "$KARABINER_CFG_DIR/karabiner.json"
mkdir -p "$VSCODE_USER_DIR"
cp -f "$TARGET_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
cp -f "$TARGET_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
mkdir -p "$GHOSTTY_CFG_DIR"
cp -f "$TARGET_DIR/ghostty/config" "$GHOSTTY_CFG_DIR/config"

echo "✅ Setup Complete"
echo "Run: source ~/.zshrc in ghostty"
echo "⚠️ If got exit code 1, try run kiro-cli doctor and fix the issue until you get ✔ Everything looks good"
echo "also open kiro-cli setting to set it up."
