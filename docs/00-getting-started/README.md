# Getting Started

Get your development environment set up and running in about 30 minutes.

---

## In This Section

1. [Install on Linux](./01-install-linux.md) - Arch, Ubuntu/Debian, Fedora
2. [Install on macOS](./02-install-macos.md) - Homebrew + asdf
3. [Install on Windows](./03-install-windows.md) - Native, WSL2, or Chocolatey
4. [Editor Setup](./04-editor-setup.md) - VSCode with ElixirLS, HEEx support
5. [IEx Introduction](./05-iex-intro.md) - The interactive shell
6. [First Run](./06-first-run.md) - Running this chat application

---

## What You'll Install

| Tool           | Purpose                                  |
| -------------- | ---------------------------------------- |
| **Erlang/OTP** | The runtime (BEAM VM)                    |
| **Elixir**     | The language                             |
| **Phoenix**    | The web framework                        |
| **Node.js**    | For asset compilation (esbuild/tailwind) |
| **SQLite**     | Database (lightweight, no setup)         |

---

## Recommended: Use asdf

We recommend [asdf](https://asdf-vm.com/) for managing Erlang and Elixir versions. It:

- Lets you switch versions per-project
- Keeps your system clean
- Makes upgrades painless

Each platform guide shows both asdf and native installation options.

---

## Quick Check

After installation, verify everything works:

```bash
# Check versions
elixir --version
# Should show: Elixir 1.15+ and Erlang/OTP 25+

mix --version
# Should show: Mix 1.15+

node --version
# Should show: v18+ (needed for assets)
```

---

**Choose your platform:**

- [Linux →](./01-install-linux.md)
- [macOS →](./02-install-macos.md)
- [Windows →](./03-install-windows.md)
