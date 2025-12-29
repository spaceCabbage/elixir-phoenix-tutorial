# Elixir Fundamentals

This section teaches you the Elixir language itself. Work through each file in order - concepts build on each other.

---

## What You'll Learn

| File                                             | Topic                              | Key Concepts                         |
| ------------------------------------------------ | ---------------------------------- | ------------------------------------ |
| [01. Basic Types](./01-basic-types.md)           | Numbers, atoms, strings, booleans  | Immutability, atoms, binary strings  |
| [02. Collections](./02-collections.md)           | Lists, tuples, maps, keyword lists | When to use each                     |
| [03. Pattern Matching](./03-pattern-matching.md) | The `=` operator                   | Destructuring, matching in functions |
| [04. Functions](./04-functions.md)               | Anonymous & named functions        | Clauses, guards, arity               |
| [05. Pipe Operator](./05-pipe-operator.md)       | Data transformation                | `\|>` operator, composition          |
| [06. Control Flow](./06-control-flow.md)         | Conditionals                       | `case`, `cond`, `if`, `with`         |
| [07. Modules & Structs](./07-modules-structs.md) | Code organization                  | Modules, structs, protocols          |
| [08. Enum & Recursion](./08-enum-recursion.md)   | Collection processing              | Map, filter, reduce, recursion       |
| [09. Processes](./09-processes.md)               | Concurrency basics                 | Spawn, send, receive                 |

---

## Prerequisites

Before starting:

1. Elixir installed ([Getting Started](../00-getting-started/))
2. IEx shell working (`iex` command)
3. Read the [Erlang Primer](../00b-erlang-primer/) (optional but helpful)

---

## How to Learn

### 1. Use IEx Constantly

Every code example should be tried in IEx:

```bash
iex
```

Don't just read - type the code yourself.

### 2. Experiment

After each example, try variations:

- What if I change this value?
- What error do I get if I do X?
- Can I combine this with something I learned before?

### 3. Check Understanding

At the end of each file, you should be able to:

- Explain the concept to someone else
- Write similar code from memory
- Predict what code will return

---

## The Elixir Mindset

Coming from other languages, adjust your thinking:

| Instead of...          | Think...                                   |
| ---------------------- | ------------------------------------------ |
| Variables hold values  | Bindings point to immutable values         |
| `if/else` everywhere   | Pattern matching in functions              |
| Objects with methods   | Data + functions that transform it         |
| Loops (`for`, `while`) | Recursion and `Enum` functions             |
| `try/catch` for errors | `{:ok, value}` / `{:error, reason}` tuples |
| Null/nil checks        | Pattern match on expected shapes           |

---

## Time Estimate

- **Quick pass**: 1-2 hours (skim, try key examples)
- **Thorough study**: 3-4 hours (every example, experimentation)
- **Mastery**: Multiple sessions over days

No rush. Understanding fundamentals well makes everything else easier.

---

## Example Files in This Repo

See these concepts in action:

- [lib/chatroom/examples/elixir_basics.ex](../../lib/chatroom/examples/elixir_basics.ex) - Pattern matching, pipes, recursion

---

**Start:** [Basic Types →](./01-basic-types.md)
