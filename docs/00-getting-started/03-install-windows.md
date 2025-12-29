# Installing on Windows

Three options: Native installer, Chocolatey, or WSL2 (recommended for best experience).

---

## Option 1: WSL2 (Recommended)

Best development experience - run Linux inside Windows.

### Step 1: Enable WSL2

Open PowerShell as Administrator:

```powershell
wsl --install
```

Restart your computer, then open "Ubuntu" from Start menu.

### Step 2: Follow Linux Instructions

Once in WSL2 Ubuntu terminal, follow the [Linux installation guide](./01-install-linux.md) (Ubuntu section).

### Why WSL2?

- Full Linux compatibility
- Better performance for Elixir tooling
- inotify support (live reloading works)
- Same environment as production servers

---

## Option 2: Chocolatey

Native Windows installation using package manager.

### Step 1: Install Chocolatey

Open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Close and reopen PowerShell as Administrator.

### Step 2: Install Erlang and Elixir

```powershell
choco install erlang elixir -y
```

### Step 3: Refresh Environment

```powershell
refreshenv
# Or close and reopen terminal
```

### Step 4: Verify

```powershell
elixir --version
```

---

## Option 3: Native Installers

Download and install directly.

### Step 1: Install Erlang

1. Download from [erlang.org/downloads](https://www.erlang.org/downloads)
2. Run the installer
3. Add to PATH: `C:\Program Files\Erlang OTP\bin`

### Step 2: Install Elixir

1. Download from [elixir-lang.org/install](https://elixir-lang.org/install.html#windows)
2. Run the installer
3. Add to PATH if needed

### Step 3: Verify

Open new Command Prompt:

```cmd
elixir --version
```

---

## Install Phoenix

In PowerShell or Command Prompt:

```powershell
# Install Hex
mix local.hex --force

# Install Phoenix
mix archive.install hex phx_new --force

# Verify
mix phx.new --version
```

---

## Install Node.js

### Using Chocolatey

```powershell
choco install nodejs-lts -y
refreshenv
```

### Using Installer

Download from [nodejs.org](https://nodejs.org/) and run installer.

---

## Windows-Specific Notes

### File Watching Issues

Phoenix live reloading may not work perfectly on native Windows. Solutions:

1. **Use WSL2** (recommended)
2. **Use polling mode** - add to `config/dev.exs`:
   ```elixir
   config :chatroom, ChatroomWeb.Endpoint,
     live_reload: [
       patterns: [...],
       notify: [backend: :fs_poll, interval: 500]
     ]
   ```

### Path Length Issues

Windows has a 260-character path limit. Enable long paths:

1. Run `gpedit.msc`
2. Navigate to: Computer Configuration > Administrative Templates > System > Filesystem
3. Enable "Enable Win32 long paths"

Or in PowerShell as Administrator:

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

### Line Endings

Configure Git to handle line endings:

```powershell
git config --global core.autocrlf input
```

---

## Verify Everything

```powershell
elixir --version
mix --version
mix phx.new --version
node --version
```

---

**Next:** [Editor Setup →](./04-editor-setup.md) or [First Run →](./06-first-run.md)
