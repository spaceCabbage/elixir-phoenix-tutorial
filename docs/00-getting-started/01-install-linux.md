# Installing on Linux

Choose your distribution or use the universal asdf method.

---

## Option 1: Using asdf (Recommended)

Works on any Linux distribution. Manages multiple versions cleanly.

### Step 1: Install asdf

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt install curl git

# Install dependencies (Arch)
sudo pacman -S curl git

# Install dependencies (Fedora)
sudo dnf install curl git

# Clone asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

# Add to shell (bash)
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

# Add to shell (zsh)
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

### Step 2: Install Erlang

```bash
# Install build dependencies (Ubuntu/Debian)
sudo apt install build-essential autoconf m4 libncurses5-dev \
  libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev \
  libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop \
  libxml2-utils libncurses-dev openjdk-11-jdk

# Install build dependencies (Arch)
sudo pacman -S base-devel ncurses glu mesa wxwidgets-gtk3 libpng \
  libssh unixodbc libxslt fop

# Install build dependencies (Fedora)
sudo dnf install @development-tools autoconf m4 ncurses-devel \
  wxGTK3-devel openssl-devel java-11-openjdk-devel libiodbc unixODBC-devel

# Add erlang plugin and install
asdf plugin add erlang
asdf install erlang 27.0
asdf global erlang 27.0
```

### Step 3: Install Elixir

```bash
asdf plugin add elixir
asdf install elixir 1.17.0-otp-27
asdf global elixir 1.17.0-otp-27
```

### Step 4: Verify

```bash
elixir --version
# Elixir 1.17.0 (compiled with Erlang/OTP 27)
```

---

## Option 2: Arch Linux (Native)

```bash
# Install from official repos
sudo pacman -S erlang elixir

# Verify
elixir --version
```

---

## Option 3: Ubuntu/Debian (Native)

```bash
# Add Erlang Solutions repo
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt update

# Install
sudo apt install esl-erlang elixir

# Verify
elixir --version
```

---

## Option 4: Fedora (Native)

```bash
# Install from repos
sudo dnf install erlang elixir

# Verify
elixir --version
```

---

## Install Phoenix

After Elixir is installed:

```bash
# Install Hex (package manager)
mix local.hex --force

# Install Phoenix generator
mix archive.install hex phx_new --force

# Verify
mix phx.new --version
# Phoenix installer v1.7.x
```

---

## Install Node.js

Phoenix uses Node.js for asset compilation.

### Using asdf

```bash
asdf plugin add nodejs
asdf install nodejs 20.10.0
asdf global nodejs 20.10.0
```

### Using nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

### Native (Ubuntu/Debian)

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### Native (Arch)

```bash
sudo pacman -S nodejs npm
```

---

## Install inotify-tools (Optional but Recommended)

Enables live code reloading during development:

```bash
# Ubuntu/Debian
sudo apt install inotify-tools

# Arch
sudo pacman -S inotify-tools

# Fedora
sudo dnf install inotify-tools
```

---

## Verify Everything

```bash
# All of these should work
elixir --version
mix --version
mix phx.new --version
node --version
```

---

**Next:** [Editor Setup →](./04-editor-setup.md) or [First Run →](./06-first-run.md)
