# Tool Bridge protocol

Rails tools execute **in the customer Rails app**. Eve (on our Vercel project) only sees a proxy tool that HTTP-calls the bridge.

## Customer endpoint

Default (Rails engine route):

```http
POST /rails_agents/bridge
Content-Type: application/json
X-Rails-Agents-Timestamp: <unix_seconds>
X-Rails-Agents-Signature: v1=<hex_hmac_sha256>
X-Rails-Agents-Tenant: <tenant_id>
X-Rails-Agents-Environment: sandbox|production
X-Rails-Agents-App: <app_id>
```

### Body

```json
{
  "invocation_id": "inv_...",
  "agent_id": "lead_qualifier",
  "tool": "search_crm",
  "arguments": { "query": "acme" },
  "session": {
    "id": "ses_...",
    "turn": 3
  }
}
```

### Success response

```json
{
  "ok": true,
  "result": { "companies": [] }
}
```

`result` may be any JSON-serializable value (string, object, array).

### Error response

```json
{
  "ok": false,
  "error": {
    "code": "tool_error",
    "message": "Company search failed"
  }
}
```

HTTP status: `200` for handled tool errors (model sees error payload); `401/403` for auth failures; `500` only for bridge crashes.

## Signature

```text
secret = tool_bridge_secret  # per app+env
payload = "#{timestamp}.#{raw_body}"
signature = HMAC_SHA256(secret, payload)
header = "v1=#{hex(signature)}"
```

Reject if `|now - timestamp| > 300` seconds.

## Eve-side shim (compiled)

Each Ruby tool compiles to a TypeScript `defineTool` whose `execute` POSTs to the control plane internal tool proxy (adds signature, resolves customer webhook URL). The model never sees the customer URL.

## Rails gem responsibilities

1. Mount bridge endpoint (`RailsAgents::Engine`).
2. Verify signature.
3. Resolve `tool` name → `RailsAgents::Tool` class for that `agent_id`.
4. Call `#call(**arguments)` and return JSON.
5. Never log secrets or full PII by default.
