# aeo-sdk-swift

Swift SDK for the [AEO Protocol v0.1](https://github.com/mizcausevic-dev/aeo-protocol-spec) — parse, build, validate, and fetch AEO declaration documents. Foundation-only, no third-party dependencies.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20Linux-blue.svg)](https://swift.org)

Completes the AEO SDK family at **five languages** alongside the Python, TypeScript, Rust, and Go SDKs.

## Install

In your `Package.swift`:

```swift
.package(url: "https://github.com/mizcausevic-dev/aeo-sdk-swift", from: "0.1.0")
```

Then add `"AEOProtocol"` to your target dependencies.

## Quickstart

```swift
import AEOProtocol

// Fetch and parse from a live well-known URL
let doc = try await fetchWellKnown(origin: "https://mizcausevic-dev.github.io")
print(doc.entity.name)               // "Miz Causevic"
print(doc.claimIDs())                // ["current-role", "location", ...]

if let claim = doc.findClaim(id: "years-experience"),
   case .number(let yrs) = claim.value {
    print("years: \(yrs)")           // years: 30.0
}

// Parse from a JSON string
let parsed = try AEODocument.from(json: rawString)

// Build programmatically
let built = AEODocument(
    entity: Entity(
        id: "https://example.com/#org",
        type: .organization,
        name: "Example Org",
        canonicalURL: "https://example.com/"
    ),
    authority: Authority(primarySources: ["https://example.com/"]),
    claims: [
        Claim(id: "tagline", predicate: "description", value: .string("Example"))
    ]
)
let json = try built.toJSON()
```

## What it does

- **Parse** — `AEODocument.from(json:)` / `from(data:)` returns a strongly-typed document
- **Build** — `Codable` model types for `Entity`, `Authority`, `Claim`, `Verification`, `CitationPreferences`, `AnswerConstraints`, `Audit`, plus a `JSONValue` enum for the polymorphic claim value
- **Serialize** — `doc.toJSON(prettyPrinted:)` returns canonical JSON
- **Fetch** — `fetchWellKnown(origin:session:)` performs HTTP discovery via `URLSession` with `Accept: application/aeo+json, application/json`
- **Query** — `doc.claimIDs()` and `doc.findClaim(id:)` helpers

## Conformance

Supports the AEO Protocol at **conformance Level 1 (Declare)**. Signature verification (L2) and audit-endpoint posting (L3) deferred to v0.2.

## Platforms

- macOS 13+
- iOS / iPadOS 16+
- tvOS 16+
- watchOS 9+
- Linux (Swift 5.9+)
- Windows (with appropriate Visual Studio Build Tools)

## Dependencies

Foundation. Nothing else.

## Development

```bash
swift build
swift test
```

CI builds and tests on both macOS and Linux.

## Specification

Full spec at [github.com/mizcausevic-dev/aeo-protocol-spec](https://github.com/mizcausevic-dev/aeo-protocol-spec).

## License

AGPL-3.0.

## Kinetic Gain Protocol Suite

| Spec | Implementation |
|---|---|
| [AEO Protocol](https://github.com/mizcausevic-dev/aeo-protocol-spec) | [aeo-sdk-python](https://github.com/mizcausevic-dev/aeo-sdk-python) · [aeo-sdk-typescript](https://github.com/mizcausevic-dev/aeo-sdk-typescript) · [aeo-sdk-rust](https://github.com/mizcausevic-dev/aeo-sdk-rust) · [aeo-sdk-go](https://github.com/mizcausevic-dev/aeo-sdk-go) · **aeo-sdk-swift** (this) · [aeo-cli](https://github.com/mizcausevic-dev/aeo-cli) · [aeo-crawler](https://github.com/mizcausevic-dev/aeo-crawler) |
| [Prompt Provenance](https://github.com/mizcausevic-dev/prompt-provenance-spec) | — |
| [Agent Cards](https://github.com/mizcausevic-dev/agent-cards-spec) | — |
| [AI Evidence Format](https://github.com/mizcausevic-dev/ai-evidence-format-spec) | — |
| [MCP Tool Cards](https://github.com/mizcausevic-dev/mcp-tool-card-spec) | — |

---

**Connect:** [LinkedIn](https://www.linkedin.com/in/mirzacausevic/) · [Kinetic Gain](https://kineticgain.com) · [Medium](https://medium.com/@mizcausevic/) · [Skills](https://mizcausevic.com/skills/)
