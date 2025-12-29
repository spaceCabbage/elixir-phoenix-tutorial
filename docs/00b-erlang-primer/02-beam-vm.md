# The BEAM VM: The Magic Runtime

The BEAM (Bogdan's Erlang Abstract Machine) is the virtual machine that runs Erlang and Elixir code. Understanding it explains why Elixir can do things other languages can't.

---

## What Makes BEAM Special

| Feature                        | What It Means                    | Why It Matters           |
| ------------------------------ | -------------------------------- | ------------------------ |
| Lightweight processes          | Not OS threads; managed by BEAM  | Create millions of them  |
| Preemptive scheduling          | BEAM controls execution time     | No process can hog CPU   |
| Isolated memory                | Each process has its own heap    | Crashes don't spread     |
| Garbage collection per process | GC only affects one process      | No stop-the-world pauses |
| Message passing                | Processes communicate by copying | No shared state bugs     |
| Hot code loading               | Replace code while running       | Zero downtime deploys    |

---

## BEAM Processes vs OS Threads

This is the most important thing to understand.

### OS Threads (Java, Python, etc.)

- **Heavy**: Each thread uses ~1MB of stack space
- **Limited**: Creating thousands causes problems
- **Shared memory**: Must use locks to avoid race conditions
- **OS-scheduled**: Operating system decides who runs when

### BEAM Processes

- **Light**: Each process uses ~2KB initially
- **Unlimited**: Create millions without issues
- **Isolated memory**: No shared state, no locks needed
- **BEAM-scheduled**: VM ensures fairness

```elixir
# Create 1 million processes (try this in IEx!)
iex> for _ <- 1..1_000_000, do: spawn(fn -> :timer.sleep(10_000) end)
# This actually works! Try doing this with OS threads.
```

---

## Preemptive Scheduling

BEAM uses **reduction counting** to ensure fairness. Each process gets ~4000 "reductions" (roughly, function calls) before being paused.

```elixir
# This infinite loop won't freeze your system
spawn(fn ->
  loop = fn loop_fn -> loop_fn.(loop_fn) end
  loop.(loop)
end)

# Other processes continue running normally
IO.puts("This still prints!")
```

In most languages, an infinite loop freezes the thread. In BEAM, it just uses one process's time slice while everything else continues.

---

## Memory Model

Each process has:

- Its own **heap** (for data)
- Its own **stack** (for function calls)
- Its own **mailbox** (for messages)

```
┌─────────────────────────────────────────────────────────────┐
│                        BEAM VM                               │
├─────────────┬─────────────┬─────────────┬─────────────┬─────┤
│  Process 1  │  Process 2  │  Process 3  │  Process 4  │ ... │
├─────────────┼─────────────┼─────────────┼─────────────┼─────┤
│ [Heap]      │ [Heap]      │ [Heap]      │ [Heap]      │     │
│ [Stack]     │ [Stack]     │ [Stack]     │ [Stack]     │     │
│ [Mailbox]   │ [Mailbox]   │ [Mailbox]   │ [Mailbox]   │     │
└─────────────┴─────────────┴─────────────┴─────────────┴─────┘
```

When Process 1 sends a message to Process 2, the data is **copied** into Process 2's mailbox. This seems inefficient, but it means:

1. No locks needed
2. No race conditions possible
3. If Process 1 crashes, Process 2's data is fine
4. Garbage collection in Process 1 doesn't affect Process 2

---

## Garbage Collection

Most VMs (JVM, V8) do **stop-the-world** garbage collection - all execution pauses while memory is cleaned up.

BEAM does **per-process GC**:

- Each process is garbage collected independently
- Only that one process pauses (microseconds)
- Other processes continue running
- GC of a busy process doesn't affect response times

This is why Phoenix can handle millions of connections with consistent low latency.

---

## Schedulers

BEAM runs one **scheduler** per CPU core. Each scheduler manages many processes.

```
┌─────────────────────────────────────────────────────────────┐
│                        BEAM VM                               │
├──────────────────┬──────────────────┬──────────────────┬────┤
│   Scheduler 1    │   Scheduler 2    │   Scheduler 3    │... │
│   (CPU Core 1)   │   (CPU Core 2)   │   (CPU Core 3)   │    │
├──────────────────┼──────────────────┼──────────────────┼────┤
│ P1, P4, P7, P10  │ P2, P5, P8, P11  │ P3, P6, P9, P12  │    │
│     ...          │     ...          │     ...          │    │
└──────────────────┴──────────────────┴──────────────────┴────┘
```

Work is automatically balanced across cores. You don't have to think about threads or parallelism - it just works.

---

## Try It: Exploring the Runtime

```elixir
# How many schedulers (cores) do you have?
iex> :erlang.system_info(:schedulers)
4

# How many processes exist right now?
iex> length(Process.list())
72

# Memory usage
iex> :erlang.memory()
[total: 31_234_567, processes: 5_678_901, ...]

# Create a process and inspect it
iex> pid = spawn(fn -> :timer.sleep(60_000) end)
#PID<0.123.0>

iex> Process.info(pid)
[
  current_function: {:timer, :sleep, 1},
  initial_call: {:erlang, :apply, 2},
  status: :waiting,
  heap_size: 233,
  stack_size: 3,
  ...
]
```

---

## The Observer

BEAM includes a visual tool for inspecting the runtime:

```elixir
iex> :observer.start()
```

This opens a GUI showing:

- All running processes
- Memory usage per process
- Message queue sizes
- Application supervision trees
- System performance metrics

It's like `top` but for BEAM processes.

---

## Why This Matters for Phoenix

When you run a Phoenix app:

1. Each **WebSocket connection** is a separate process
2. Each **HTTP request** can spawn processes
3. Each **LiveView** is a process
4. **PubSub** broadcasts use process messaging

If one user's request crashes, only their process dies. Everyone else is unaffected. The supervisor restarts the process, and the user can retry.

This is why Phoenix can handle:

- 2 million WebSocket connections (WhatsApp numbers)
- Consistent sub-millisecond latencies
- Zero-downtime deploys
- Graceful degradation under load

---

## Key Takeaways

1. **BEAM processes are NOT OS threads** - they're much lighter and safer
2. **Memory is isolated** - no shared state, no locks, no race conditions
3. **Per-process GC** - no stop-the-world pauses
4. **Preemptive scheduling** - no process can hog resources
5. **Automatic distribution** - work spreads across cores automatically

When you hear "Elixir handles concurrency well," this is why. The BEAM was designed from day one for massively concurrent systems.

---

**Next:** [OTP Explained →](./03-otp-explained.md)
