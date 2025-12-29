# Erlang Primer: Understanding the Foundation

Before diving into Elixir, you need to understand Erlang - the language and platform that Elixir is built on. This isn't just history; it's essential context that will make you a better Elixir developer.

---

## Why This Matters

Elixir compiles to Erlang bytecode and runs on the Erlang VM (called BEAM). Everything that makes Elixir powerful - lightweight processes, fault tolerance, hot code reloading, distributed computing - comes from Erlang.

Understanding Erlang helps you:

- **Debug better** - Error messages sometimes show Erlang syntax
- **Use libraries** - Many powerful libraries are written in Erlang
- **Think correctly** - Elixir's design philosophy comes from Erlang
- **Interview well** - "What's the BEAM?" is a common question

---

## What You'll Learn

| Section                                  | Topic                              | Why It Matters                                  |
| ---------------------------------------- | ---------------------------------- | ----------------------------------------------- |
| [History](./01-history.md)               | Where Erlang came from             | Understand the "why" behind design decisions    |
| [BEAM VM](./02-beam-vm.md)               | The runtime that powers everything | Know what makes Elixir special                  |
| [OTP Explained](./03-otp-explained.md)   | The "secret sauce"                 | Understand GenServer, Supervisors, Applications |
| [Elixir Interop](./04-elixir-interop.md) | Calling Erlang from Elixir         | Use the full ecosystem                          |

---

## The 30-Second Version

If you're in a hurry, here's what you need to know:

1. **Erlang was created at Ericsson in 1986** for telephone switches that could never go down
2. **The BEAM VM** runs your code in millions of tiny, isolated processes (not OS processes)
3. **OTP** is a set of battle-tested patterns for building reliable systems
4. **Elixir** is a modern syntax on top of this 35+ year-old, production-proven foundation

That's it. Everything else is details.

---

## Quick Comparison

| Feature         | Erlang            | Elixir             |
| --------------- | ----------------- | ------------------ |
| First appeared  | 1986              | 2011               |
| Syntax style    | Prolog-like       | Ruby-like          |
| Metaprogramming | Limited           | Powerful macros    |
| Documentation   | `@doc` equivalent | First-class `@doc` |
| Package manager | None (uses rebar) | Hex + Mix          |
| Web framework   | -                 | Phoenix            |
| **Runtime**     | BEAM              | BEAM               |
| **Processes**   | Same              | Same               |
| **OTP**         | Same              | Same               |

The right side of the table is the same because Elixir IS Erlang (with better syntax).

---

## Try It

If you have Elixir installed, you already have Erlang. Try this:

```bash
# Check Erlang version
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell

# Start the Erlang shell
erl
# You'll see "Eshell" - type halt(). to exit
```

In IEx, you can call Erlang directly:

```elixir
iex> :erlang.system_info(:otp_release)
~c"27"

iex> :os.timestamp()
{1735, 123456, 789012}

iex> :crypto.strong_rand_bytes(16)
<<123, 45, 67, ...>>
```

The colon prefix (`:erlang`, `:os`, `:crypto`) is how Elixir references Erlang modules.

---

## Navigation

**This section:**

1. [History & Philosophy](./01-history.md)
2. [The BEAM VM](./02-beam-vm.md)
3. [OTP Explained](./03-otp-explained.md)
4. [Elixir Interop](./04-elixir-interop.md)

**Next section:** [Elixir Fundamentals](../01-elixir-fundamentals/)
