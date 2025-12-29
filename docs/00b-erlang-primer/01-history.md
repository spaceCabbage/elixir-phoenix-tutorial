# Erlang History: Why This Language Exists

Understanding Erlang's origins explains why Elixir works the way it does. This isn't ancient history - it's the reason your Phoenix app can handle 2 million WebSocket connections on a single server.

---

## The Problem: Telephone Switches

In the 1980s, Ericsson (a Swedish telecom company) had a problem: their telephone switches needed to:

1. **Never crash** - A dropped call is unacceptable
2. **Handle millions of concurrent calls** - Each call is independent
3. **Update without downtime** - You can't tell millions of people to hang up
4. **Recover from failures** - Hardware fails; software must continue

No existing language could do this. So they built one.

---

## The Solution: Erlang (1986)

Joe Armstrong, Robert Virding, and Mike Williams created Erlang at Ericsson's Computer Science Laboratory. The name comes from:

- **Erlang** - A unit of telecom traffic (named after mathematician Agner Krarup Erlang)
- **ERicsson LANGuage** - A convenient backronym

### Key Design Decisions

| Decision              | Why                                     | Result                           |
| --------------------- | --------------------------------------- | -------------------------------- |
| Lightweight processes | Each phone call = one process           | Millions of concurrent processes |
| Isolated memory       | Crash in one call doesn't affect others | True fault isolation             |
| Message passing       | No shared state = no locks              | Simple concurrency               |
| "Let it crash"        | Restart is faster than defensive coding | Supervisor trees                 |
| Hot code swapping     | Updates during operation                | Zero downtime deploys            |

---

## The Nine Nines

Erlang's crowning achievement was the **AXD301** telephone switch, which achieved **99.9999999% uptime** (nine nines). That's less than **32 milliseconds of downtime per year**.

This wasn't achieved by writing perfect code. It was achieved by:

1. Isolating failures
2. Detecting failures instantly
3. Restarting failed components automatically
4. Never losing state that matters

This philosophy is called **"Let it crash"** and it's fundamental to Elixir.

---

## Let It Crash

In most languages, you write defensive code:

```javascript
// JavaScript - defensive programming
function divide(a, b) {
  if (b === 0) {
    return { error: "Division by zero" };
  }
  if (typeof a !== "number" || typeof b !== "number") {
    return { error: "Invalid input" };
  }
  return { result: a / b };
}
```

In Erlang/Elixir, you write happy path code and let supervisors handle failures:

```elixir
# Elixir - "let it crash"
def divide(a, b) do
  a / b
end
```

If `b` is zero, the process crashes. A supervisor restarts it. The system continues.

This sounds crazy until you realize:

- Crashes are **isolated** (other processes unaffected)
- Restarts are **fast** (microseconds)
- Supervisors are **always watching**
- Error handling code is **in one place** (the supervisor)

---

## Open Source (1998)

Ericsson tried to ban Erlang internally (long story involving politics). In response, Joe Armstrong and others convinced Ericsson to open-source it. This turned out to be one of the best decisions in tech history.

After open-sourcing:

- **WhatsApp** built their entire backend in Erlang (2 million connections per server)
- **Discord** handles millions of concurrent users
- **RabbitMQ** became the most popular message broker
- **Riak** pioneered distributed databases
- **Elixir** was born

---

## José Valim and Elixir (2011)

José Valim was a Rails core contributor who fell in love with Erlang's concurrency model but found its syntax difficult. He created Elixir to:

1. **Keep everything great about Erlang** - BEAM, OTP, processes, fault tolerance
2. **Modern syntax** - Ruby-inspired, readable, consistent
3. **Better tooling** - Mix build tool, Hex package manager
4. **Metaprogramming** - Powerful macro system
5. **Documentation** - First-class `@doc` attributes

Elixir compiles to the same bytecode as Erlang. They're completely interoperable.

---

## Timeline

| Year  | Event                                                                                 |
| ----- | ------------------------------------------------------------------------------------- |
| 1986  | Erlang created at Ericsson                                                            |
| 1998  | Erlang open-sourced                                                                   |
| 2007  | Erlang paper "Making reliable distributed systems in the presence of software errors" |
| 2009  | WhatsApp founded (Erlang backend)                                                     |
| 2011  | Elixir created by José Valim                                                          |
| 2014  | Phoenix framework released                                                            |
| 2016  | Phoenix LiveView announced                                                            |
| 2020  | LiveView becomes production-ready                                                     |
| Today | Elixir powers Discord, Pinterest, Bleacher Report, PepsiCo, and many more             |

---

## Why This Matters for You

When you write Elixir code, you're standing on 35+ years of battle-tested engineering. The patterns that seem unusual at first (GenServers, Supervisors, message passing) aren't academic exercises - they're solutions to real problems that cost real money when they fail.

Every choice in Elixir - from immutable data to the process model - traces back to keeping telephone switches running. Your chat app benefits from the same engineering that handles emergency calls.

---

## Key Takeaways

1. **Erlang was designed for the hardest problem**: systems that can never fail
2. **"Let it crash"** is a feature, not a bug
3. **Processes are cheap and isolated** - use millions of them
4. **Elixir is Erlang with better syntax** - same runtime, same power
5. **This isn't theory** - WhatsApp, Discord, and telecom systems prove it works

---

**Next:** [The BEAM VM →](./02-beam-vm.md)
