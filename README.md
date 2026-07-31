# Wisp

## TODO

- [ ] Separate the system messages from the rest of the Conversation struct.
- [ ] Parse JSON properly in a reusable way.

## A fast, compact, terminal-native coding harness for thinking through code with you.

- Own your AI agent loop — no opaque agent runtime; conversation, context, providers, tools, and policy remain inspectable.
- Learning first — default output is guidance, reasoning, locations, and checks; edits happen only when explicitly requested.
- Instant terminal flow — built around shell, editor, multiplexer, and quickfix handoffs; low latency beats agent spectacle.
- Small codebase — minimal dependencies, clear ownership, few abstractions, predictable memory behavior.
- Provider is replaceable — Copilot first, others later; no provider owns Wisp’s conversation or workflow.
- Not an edit bot — autonomy is a capability to earn, not the default product behavior.
- Great codebase exploratin is must — the agent needs to be exceptional at finding things.

### Status:

- Early work in progress. Full-screen terminal chat works. Conversation state is owned and rendered locally. Experimental Copilot device authorization can request a browser login code.

### Current interaction:

- Enter submits text. Ctrl+X exits.

### Direction:

- Finish Copilot streaming, add tool execution, then add further providers without changing core conversation behavior.

- Not production-ready. Authentication and Copilot gateway integration are experimental.
