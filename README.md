# Wisp

## A terminal-native coding-agent harness written in Zig.

- It owns conversation state, model context, and tool execution. Providers are adapters; Wisp owns the agent loop.

## Status:

- Early work in progress. Full-screen terminal chat works. Conversation state is owned and rendered locally. Experimental Copilot device authorization can request a browser login code.

- Current interaction: Enter submits text. Ctrl+X exits.

- Direction: finish Copilot streaming, add tool execution, then add further providers without changing core conversation behavior.

- Not production-ready. Authentication and Copilot gateway integration are experimental.
