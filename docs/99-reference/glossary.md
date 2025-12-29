# Glossary

Key terms you'll encounter in Elixir and Phoenix.

---

## A

**Assigns**
The state stored in a LiveView socket. Accessed with `@variable` in templates.

**Atom**
A constant whose name is its value. Examples: `:ok`, `:error`, `true`, `nil`.

---

## B

**BEAM**
The Erlang virtual machine that runs Elixir code. Stands for Bogdan/Bjorn's Erlang Abstract Machine. Known for fault tolerance and concurrency.

---

## C

**Changeset**
An Ecto structure that tracks changes to data and validates them before database operations.

**Conn**
Short for connection. The `Plug.Conn` struct that represents an HTTP request/response cycle in Phoenix controllers.

**Context**
A Phoenix design pattern that groups related functionality. Acts as a public API for a domain (e.g., `Accounts`, `Chat`).

---

## E

**Ecto**
The database library for Elixir. Handles schemas, queries, changesets, and migrations.

**Endpoint**
The entry point for web requests in Phoenix. Handles HTTP parsing, sessions, and routes to the router.

---

## G

**GenServer**
Generic Server. An OTP behavior for implementing a stateful server process with a standard interface.

**Guard**
A condition in a function clause that restricts when that clause matches. Example: `def foo(x) when is_integer(x)`.

---

## H

**HEEx**
HTML + EEx. Phoenix's template format that combines HTML with Elixir expressions. Used in LiveView with `~H` sigil.

**Handle Functions**
LiveView callbacks like `handle_event/3`, `handle_info/2`, `handle_params/3` that respond to different types of messages.

---

## I

**IEx**
Interactive Elixir. The REPL for running Elixir code interactively.

**Immutable**
Data that cannot be changed after creation. All Elixir data is immutable - you create new values instead of modifying existing ones.

---

## L

**LiveView**
Phoenix library for building real-time, server-rendered UI over WebSockets.

---

## M

**Migration**
A file that describes database schema changes. Run with `mix ecto.migrate`.

**Mix**
Elixir's build tool. Handles compilation, dependencies, testing, and custom tasks.

**Module**
A collection of functions grouped together. Defined with `defmodule`.

**Mount**
The `mount/3` callback in LiveView, called when a user first connects.

---

## O

**OTP**
Open Telecom Platform. A set of Erlang libraries and design patterns for building concurrent, fault-tolerant systems.

---

## P

**Pattern Matching**
Elixir's primary mechanism for binding variables and destructuring data. Uses the `=` operator.

**Pipe Operator**
The `|>` operator that passes the result of one expression as the first argument to the next function.

**Plug**
A specification for composable web middleware. Phoenix is built on Plug.

**Process**
A lightweight, isolated unit of execution in the BEAM. Not an OS process - millions can run concurrently.

**PubSub**
Publish/Subscribe. Phoenix's system for broadcasting messages to multiple subscribers.

---

## R

**Repo**
The Ecto module that connects to the database. Handles queries, inserts, updates, deletes.

**Router**
Phoenix module that maps URLs to controllers or LiveViews.

---

## S

**Schema**
An Ecto module that maps a database table to an Elixir struct.

**Socket**
In LiveView, the state container passed through all callbacks. Contains assigns and connection metadata.

**Struct**
A map with a defined structure and default values. Created with `defstruct`.

**Supervisor**
An OTP process that monitors and restarts child processes when they crash.

---

## T

**Telemetry**
Elixir's library for metrics and instrumentation.

**Tuple**
A fixed-size collection stored contiguously in memory. Common for return values: `{:ok, result}`, `{:error, reason}`.

---

## W

**WebSocket**
A persistent, bidirectional connection between browser and server. Used by LiveView for real-time updates.

**With Expression**
The `with` special form for chaining pattern matches with short-circuit failure handling.
