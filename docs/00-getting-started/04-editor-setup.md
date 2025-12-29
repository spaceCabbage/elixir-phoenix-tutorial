# Editor Setup

Get your editor configured for the best Elixir development experience.

---

## VSCode (Recommended)

Visual Studio Code with ElixirLS provides excellent Elixir support.

### Step 1: Install VSCode

Download from [code.visualstudio.com](https://code.visualstudio.com/)

### Step 2: Install Extensions

Open VSCode and install these extensions (Ctrl+Shift+X / Cmd+Shift+X):

| Extension             | ID                         | Purpose                                                       |
|-----------------------|----------------------------|---------------------------------------------------------------|
| **ElixirLS**          | `JakeBecker.elixir-ls`     | Language server (autocomplete, go-to-definition, diagnostics) |
| **Phoenix Framework** | `phoenixframework.phoenix` | HEEx syntax highlighting, snippets                            |

**Optional but useful:**
| Extension                     | ID                           | Purpose                                    |
|-------------------------------|------------------------------|--------------------------------------------|
| **Tailwind CSS IntelliSense** | `bradlc.vscode-tailwindcss`  | Tailwind class autocomplete, hover preview |
| **Elixir Test**               | `samuel-pordeus.elixir-test` | Run tests from editor                      |
| **HTML CSS Support**          | `ecmel.vscode-html-css`      | CSS class autocomplete in HEEx             |

### Step 3: Configure Settings

Open settings (Ctrl+, / Cmd+,) and add to `settings.json`:

```json
{
  // Elixir formatting
  "[elixir]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "JakeBecker.elixir-ls"
  },

  // HEEx formatting
  "[html-eex]": {
    "editor.formatOnSave": true
  },
  "[phoenix-heex]": {
    "editor.formatOnSave": true
  },

  // ElixirLS settings
  "elixirLS.dialyzerEnabled": true,
  "elixirLS.suggestSpecs": true,
  "elixirLS.fetchDeps": true,

  // File associations
  "files.associations": {
    "*.heex": "phoenix-heex",
    "*.leex": "phoenix-heex"
  },

  // Emmet for HEEx
  "emmet.includeLanguages": {
    "phoenix-heex": "html",
    "html-eex": "html"
  },

  // Tailwind CSS IntelliSense (for Tailwind v4)
  "tailwindCSS.includeLanguages": {
    "elixir": "html",
    "phoenix-heex": "html"
  }
}
```

### Step 4: Workspace Settings (Optional)

Create `.vscode/settings.json` in your project for project-specific settings:

```json
{
  "elixirLS.projectDir": ".",
  "search.exclude": {
    "**/_build": true,
    "**/deps": true,
    "**/node_modules": true
  }
}
```

---

## Key Features After Setup

### IntelliSense / Autocomplete

- Function signatures and docs on hover
- Auto-import suggestions
- Module and function completion

### Go to Definition

- `F12` or `Ctrl+Click` to jump to function definitions
- Works across your code and dependencies

### Diagnostics

- Real-time error highlighting
- Warnings from the compiler
- Dialyzer type checking (if enabled)

### Formatting

- Automatically formats on save using `mix format`
- Consistent code style

### Code Actions

- Quick fixes for common issues
- Add missing aliases
- Extract to variable/function

---

## Debugging with ElixirLS

### Step 1: Create Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "mix_task",
      "name": "mix phx.server",
      "request": "launch",
      "task": "phx.server",
      "projectDir": "${workspaceRoot}"
    },
    {
      "type": "mix_task",
      "name": "mix test",
      "request": "launch",
      "task": "test",
      "projectDir": "${workspaceRoot}",
      "requireFiles": ["test/**/test_helper.exs", "test/**/*_test.exs"]
    }
  ]
}
```

### Step 2: Set Breakpoints

Click in the gutter (left of line numbers) to set breakpoints.

### Step 3: Start Debugging

Press `F5` or use Run > Start Debugging.

### Debug Features

- Step over (`F10`)
- Step into (`F11`)
- Step out (`Shift+F11`)
- Continue (`F5`)
- Inspect variables in sidebar

---

## IEx Integration

### Integrated Terminal

Open integrated terminal (`Ctrl+`` `) and run:

```bash
iex -S mix phx.server
```

Now you have:

- Running Phoenix server
- Interactive shell for testing
- Hot code reloading

### Useful IEx Commands

```elixir
# Recompile a module after editing
r MyModule

# Get help on a function
h Enum.map

# Inspect a value
i %{foo: "bar"}

# See all defined aliases
alias

# Reload all code
recompile()
```

---

## Alternative Editors

### Neovim

Use [elixir-tools.nvim](https://github.com/elixir-tools/elixir-tools.nvim) or configure with:

- `nvim-lspconfig` + ElixirLS
- `nvim-treesitter` for syntax highlighting

### Emacs

Use [elixir-mode](https://github.com/elixir-editors/emacs-elixir) with:

- `lsp-mode` or `eglot` for LSP support
- `mix.el` for Mix integration

### JetBrains (IntelliJ/RubyMine)

Install the [Elixir plugin](https://plugins.jetbrains.com/plugin/7522-elixir).

---

## Troubleshooting

### ElixirLS Not Starting

1. Ensure Elixir is in PATH:

   ```bash
   which elixir
   ```

2. Check ElixirLS output:
   - View > Output > ElixirLS

3. Delete `.elixir_ls` folder and restart VSCode

### Slow Autocomplete

1. Disable Dialyzer (if too slow):

   ```json
   "elixirLS.dialyzerEnabled": false
   ```

2. Ensure project compiles cleanly:
   ```bash
   mix compile
   ```

### HEEx Not Highlighting

1. Install Phoenix Framework extension
2. Check file association in settings
3. Ensure file has `.heex` extension

---

**Next:** [IEx Introduction →](./05-iex-intro.md)
