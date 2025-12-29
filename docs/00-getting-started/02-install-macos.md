# Installing on macOS

Two options: Homebrew (quick) or asdf (recommended for version management).

---

## Option 1: Using asdf (Recommended)

Best for professional development - manage multiple versions per project.

### Step 1: Install Homebrew (if needed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Install asdf

```bash
# Install asdf via Homebrew
brew install asdf

# Add to shell (zsh - default on macOS)
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.zshrc

# If using bash
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.bash_profile

# Reload shell
source ~/.zshrc  # or ~/.bash_profile
```

### Step 3: Install Erlang Dependencies

```bash
# Required for building Erlang
brew install autoconf openssl wxwidgets libxslt fop
```

### Step 4: Install Erlang

```bash
# Add plugin and install
asdf plugin add erlang

# Set compile options for macOS
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"

# Install (this takes a while - compiling from source)
asdf install erlang 27.0
asdf global erlang 27.0
```

### Step 5: Install Elixir

```bash
asdf plugin add elixir
asdf install elixir 1.17.0-otp-27
asdf global elixir 1.17.0-otp-27
```

### Step 6: Verify

```bash
elixir --version
# Elixir 1.17.0 (compiled with Erlang/OTP 27)
```

---

## Option 2: Homebrew Only (Simpler)

Faster to set up, but harder to manage multiple versions.

```bash
# Install Erlang and Elixir
brew install erlang elixir

# Verify
elixir --version
```

---

## Install Phoenix

```bash
# Install Hex (package manager)
mix local.hex --force

# Install Phoenix generator
mix archive.install hex phx_new --force

# Verify
mix phx.new --version
```

---

## Install Node.js

Phoenix needs Node.js for asset compilation.

### Using asdf (Recommended)

```bash
asdf plugin add nodejs
asdf install nodejs 20.10.0
asdf global nodejs 20.10.0
```

### Using Homebrew

```bash
brew install node@20
```

### Using nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.zshrc
nvm install 20
nvm use 20
```

---

## Install fswatch (Optional but Recommended)

Enables live code reloading during development:

```bash
brew install fswatch
```

---

## Verify Everything

```bash
# All should work
elixir --version
mix --version
mix phx.new --version
node --version
```

---

## Apple Silicon (M1/M2/M3) Notes

If you encounter issues on Apple Silicon:

```bash
# Set architecture for Homebrew
arch -arm64 brew install erlang elixir

# If using asdf with Rosetta issues
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --disable-sctp"
```

---

**Next:** [Editor Setup →](./04-editor-setup.md) or [First Run →](./06-first-run.md)
