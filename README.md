# Beamline

An Elixir-based, streaming-first, OpenAI-compatible LLM gateway.

Beamline routes requests to local, self-hosted, and OpenAI-compatible model backends with correct streaming behavior, upstream cancellation, virtual keys, and usage tracking. Built on Elixir and OTP for reliability under load.

> **Early-stage project.** This is an initial design document and work-in-progress. Features described below are planned, not yet implemented.

## Why Beamline?

When a downstream client disconnects mid-request, most gateways let the upstream provider continue doing unnecessary inference work. This wastes compute, increases latency for other clients, and inflates costs.

Beamline's core differentiator is **upstream cancellation**: when a client disconnects, the cancellation signal propagates upstream so the provider stops generating tokens immediately. This matters during:

- **Prefill / pre-first-token processing** — expensive context encoding that may be abandoned
- **Active streaming generation** — ongoing token-by-token inference

This is paired with a focused feature set: virtual keys, usage accounting, and ephemeral model discovery — without the complexity of full provider-agnostic schema conversion.

## Goals

- Correct streaming and cancellation semantics as a first-class concern
- OpenAI-compatible API surface for drop-in client compatibility
- Virtual keys with per-key usage tracking and limits
- Simple, durable configuration for providers and models
- Multi-node ready via Erlang clustering with PubSub-backed cache invalidation
- Small, readable codebase over broad provider coverage

## MVP Scope

The initial release targets a focused subset of gateway features:

- OpenAI-compatible HTTP endpoints (see below)
- Single upstream protocol: HTTP with SSE streaming via Mint
- OpenAI-compatible providers only (see Providers)
- Virtual key authentication and usage tracking
- PostgreSQL-backed durable state
- Ephemeral caching for upstream model discovery

## Architecture

```
Client
  │
  ▼
┌─────────────────────────────────────────────┐
│              Beamline Gateway                │
│                                             │
│  ┌──────────┐    ┌──────────┐               │
│  │ Phoenix   │    │ Gateway  │               │
│  │ / Bandit  │───▶│ Layer    │               │
│  │ (inbound) │    └────┬─────┘               │
│  └──────────┘         │                      │
│                       ▼                      │
│              ┌────────────────┐              │
│              │ Upstream Layer │              │
│              │ (Mint client)  │              │
│              └────────┬───────┘              │
│                       │                      │
│              ┌────────▼────────┐             │
│              │ PostgreSQL /     │             │
│              │ Ecto (durable)   │             │
│              └─────────────────┘             │
│                                             │
│              ┌────────────────┐             │
│              │ Nebulex +      │             │
│              │ Cachex (cache) │             │
│              └────────────────┘             │
└─────────────────────────────────────────────┘
  │
  ▼
Upstream Provider (LM Studio, vLLM, Ollama, etc.)
```

1. **Phoenix / Bandit** handles inbound client requests
2. **Gateway layer** performs OpenAI-compatible request handling, model resolution, authentication, policy checks, and usage lifecycle orchestration
3. **Upstream layer** (Mint-based) owns outbound HTTP connections and cancellation behavior
4. **PostgreSQL / Ecto** stores durable configuration and request accounting
5. **Nebulex + Cachex** provides ephemeral caches, particularly for upstream model discovery
6. **Phoenix.PubSub** enables cache invalidation across a multi-node Erlang cluster

## OpenAI-Compatible Endpoints

Planned MVP endpoints:

| Method | Path                        | Description              |
|--------|-----------------------------|--------------------------|
| POST   | `/v1/chat/completions`      | Chat completion requests |
| POST   | `/v1/completions`           | Legacy completion requests |
| POST   | `/v1/responses`             | Responses API            |
| POST   | `/v1/embeddings`            | Embedding generation     |
| GET    | `/v1/models`                | List available models    |

These endpoints follow the OpenAI API specification for request and response formats, enabling drop-in compatibility with existing clients and SDKs.

## Providers

MVP support is limited to OpenAI-compatible backends:

- OpenAI-compatible cloud APIs
- LM Studio
- vLLM
- Ollama (OpenAI-compatible endpoint)
- llama.cpp server
- Other OpenAI-compatible local/self-hosted endpoints

Native schema conversion for Anthropic, Gemini, Bedrock, and other non-OpenAI-compatible providers is not planned for the MVP.

## Model Routing

Beamline supports both explicit and unqualified model references:

- **Explicit:** `provider/model`, e.g. `lmstudio/qwen/qwen3.6-27b`
- **Unqualified:** `model`, e.g. `qwen/qwen3.6-27b`

Resolution order (planned):

1. Exact public model alias match
2. Explicit `provider/model` parse
3. Unqualified model name if uniquely resolvable
4. Configured priority or default provider
5. Ambiguity error if multiple candidates exist

Upstream `/v1/models` discovery is used for ephemeral caching only — the durable `models` table is the source of truth for the gateway's configured catalog.

## Virtual Keys

Virtual keys allow you to expose a unified authentication layer in front of multiple upstream providers. Each virtual key can be scoped to specific models or providers, with per-key usage tracking and optional rate limits.

Planned features:

- Key generation and revocation
- Per-key model access restrictions
- Usage tracking against key quotas
- Prefix-based key identification (e.g. `bl-...`)

## Usage Tracking

Every proxied request is logged with token counts, latency, model, and virtual key. Planned accounting:

- Per-request logs (`llm_requests`)
- Daily rollups (`usage_daily`)
- Prompt, completion, and total token counts
- Cost tracking based on per-model pricing configuration

## Streaming and Cancellation Semantics

This is the primary design differentiator:

- Upstream responses are streamed to clients via Server-Sent Events (SSE)
- If a client disconnects, Beamline cancels the upstream Mint connection
- This stops the provider from continuing inference, saving compute and reducing queue time for other requests
- Cancellation applies to both prefill (pre-first-token) and active generation phases

## Storage and Caching

### Durable State (PostgreSQL / Ecto)

| Table               | Purpose                                      |
|---------------------|----------------------------------------------|
| `providers`         | Upstream provider configuration              |
| `models`            | Model catalog, routing, capabilities, pricing|
| `virtual_keys`      | Key management and scoping                   |
| `users`             | User accounts                                |
| `teams`             | Team organization                            |
| `team_memberships`  | User-team associations                       |
| `llm_requests`      | Per-request audit log                        |
| `usage_daily`       | Daily aggregated usage rollups               |

### Ephemeral Cache (Nebulex + Cachex)

- Upstream `/v1/models` discovery results
- Provider health/status checks
- Resolved model routing lookups

Cache invalidation across cluster nodes via Phoenix.PubSub.

## Application Contexts

Planned module organization:

| Context              | Responsibility                                    |
|----------------------|---------------------------------------------------|
| `Beamline.Accounts`  | Users, teams, team memberships                    |
| `Beamline.Auth`      | Virtual keys, key generation, verification        |
| `Beamline.Providers` | Providers, models, upstream model discovery/cache |
| `Beamline.Usage`     | Request logs, daily rollups, token/cost accounting|
| `Beamline.Gateway`   | Request orchestration, model resolution, policies |
| `Beamline.Upstream`  | Mint client, streaming, SSE, cancellation         |

## Example Configuration

A provider and model might be configured as:

```elixir
# Provider
%Provider{
  name: "lmstudio",
  base_url: "http://localhost:1234",
  api_key: nil,
  timeout_ms: 300_000
}

# Model
%Model{
  provider_id: provider.id,
  public_name: "qwen3.6-27b",
  upstream_name: "qwen/qwen3.6-27b",
  capabilities: [:chat, :completion],
  prompt_price_per_1m: 0.0,
  completion_price_per_1m: 0.0,
  max_tokens: 32_768
}
```

## Example Request

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer bl-your-virtual-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.6-27b",
    "messages": [
      {"role": "user", "content": "Say hello briefly."}
    ],
    "stream": true
  }'
```

Response: SSE stream of chat completion chunks, following the OpenAI streaming format.

## Development Status

Beamline is in early development. The project structure, database schema, and API surface are defined but not yet implemented.

To run locally:

```bash
mix deps.get
mix ecto.setup
mix phx.server
```

## Roadmap

- [ ] Provider and model configuration via database
- [ ] Virtual key authentication
- [ ] OpenAI-compatible endpoint handlers
- [ ] Mint-based upstream client with SSE streaming
- [ ] Upstream cancellation on client disconnect
- [ ] Request logging and usage accounting
- [ ] Nebulex + Cachex model discovery cache
- [ ] Multi-node PubSub cache invalidation
- [ ] Daily usage rollup aggregation
- [ ] Per-key rate limiting and quotas
- [ ] Additional OpenAI-compatible provider testing

## Non-Goals (MVP)

- Supporting every provider schema — OpenAI-compatible only initially
- Native Anthropic, Gemini, or Bedrock schema conversion
- Web-based administration UI
- Billing or payment processing
- Complex fallback or routing graphs
- HTTP/2 upstream connection pooling (until cancellation semantics are proven)
- Being a full Bifrost or LiteLLM clone

## License

TBD
