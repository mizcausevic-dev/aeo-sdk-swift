// AEO Protocol v0.1 — Swift Codable models.
//
// Specification: https://github.com/mizcausevic-dev/aeo-protocol-spec
//
// This module mirrors the JSON Schema in the spec repository. Field
// names use the JSON convention (`snake_case`) via CodingKeys so the
// Swift API stays idiomatic (`camelCase`).

import Foundation

public let aeoProtocolVersion: String = "0.1"

public enum EntityType: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case person = "Person"
    case organization = "Organization"
    case product = "Product"
    case place = "Place"
    case concept = "Concept"
}

public enum VerificationType: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case domain
    case dns
    case github
    case linkedin
    case gpg
    case wellKnownURI = "well-known-uri"
}

public enum Confidence: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case high, medium, low
}

public enum AuditMode: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case none, signature, endpoint
}

public struct Entity: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let type: EntityType
    public let name: String
    public let aliases: [String]?
    public let canonicalURL: String

    enum CodingKeys: String, CodingKey {
        case id, type, name, aliases
        case canonicalURL = "canonical_url"
    }

    public init(id: String, type: EntityType, name: String, aliases: [String]? = nil, canonicalURL: String) {
        self.id = id
        self.type = type
        self.name = name
        self.aliases = aliases
        self.canonicalURL = canonicalURL
    }
}

public struct Verification: Codable, Equatable, Hashable, Sendable {
    public let type: VerificationType
    public let value: String
    public let proofURI: String?

    enum CodingKeys: String, CodingKey {
        case type, value
        case proofURI = "proof_uri"
    }

    public init(type: VerificationType, value: String, proofURI: String? = nil) {
        self.type = type
        self.value = value
        self.proofURI = proofURI
    }
}

public struct Authority: Codable, Equatable, Hashable, Sendable {
    public let primarySources: [String]
    public let evidenceLinks: [String]?
    public let verifications: [Verification]?

    enum CodingKeys: String, CodingKey {
        case primarySources = "primary_sources"
        case evidenceLinks = "evidence_links"
        case verifications
    }

    public init(primarySources: [String], evidenceLinks: [String]? = nil, verifications: [Verification]? = nil) {
        self.primarySources = primarySources
        self.evidenceLinks = evidenceLinks
        self.verifications = verifications
    }
}

/// A JSON value of arbitrary shape — corresponds to the `value` field
/// on a Claim, which the spec deliberately leaves untyped.
public enum JSONValue: Codable, Equatable, Hashable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let n = try? container.decode(Double.self) {
            self = .number(n)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let arr = try? container.decode([JSONValue].self) {
            self = .array(arr)
        } else if let obj = try? container.decode([String: JSONValue].self) {
            self = .object(obj)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let b): try container.encode(b)
        case .number(let n): try container.encode(n)
        case .string(let s): try container.encode(s)
        case .array(let a): try container.encode(a)
        case .object(let o): try container.encode(o)
        }
    }
}

public struct Claim: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let predicate: String
    public let value: JSONValue
    public let evidence: [String]?
    public let validFrom: String?
    public let validUntil: String?
    public let confidence: Confidence

    enum CodingKeys: String, CodingKey {
        case id, predicate, value, evidence, confidence
        case validFrom = "valid_from"
        case validUntil = "valid_until"
    }

    public init(id: String, predicate: String, value: JSONValue, evidence: [String]? = nil, validFrom: String? = nil, validUntil: String? = nil, confidence: Confidence = .high) {
        self.id = id
        self.predicate = predicate
        self.value = value
        self.evidence = evidence
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.confidence = confidence
    }

    // Custom init(from:) to provide default for confidence.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        predicate = try c.decode(String.self, forKey: .predicate)
        value = try c.decode(JSONValue.self, forKey: .value)
        evidence = try c.decodeIfPresent([String].self, forKey: .evidence)
        validFrom = try c.decodeIfPresent(String.self, forKey: .validFrom)
        validUntil = try c.decodeIfPresent(String.self, forKey: .validUntil)
        confidence = try c.decodeIfPresent(Confidence.self, forKey: .confidence) ?? .high
    }
}

public struct CitationPreferences: Codable, Equatable, Hashable, Sendable {
    public let preferredAttribution: String?
    public let canonicalLinks: [String]?
    public let doNotCite: [String]?

    enum CodingKeys: String, CodingKey {
        case preferredAttribution = "preferred_attribution"
        case canonicalLinks = "canonical_links"
        case doNotCite = "do_not_cite"
    }
}

public struct AnswerConstraints: Codable, Equatable, Hashable, Sendable {
    public let mustInclude: [String]?
    public let mustNotInclude: [String]?
    public let freshnessWindowDays: Int?

    enum CodingKeys: String, CodingKey {
        case mustInclude = "must_include"
        case mustNotInclude = "must_not_include"
        case freshnessWindowDays = "freshness_window_days"
    }
}

public struct Audit: Codable, Equatable, Hashable, Sendable {
    public let mode: AuditMode
    public let signingKeyURI: String?
    public let signature: String?
    public let endpointURI: String?
    public let endpointSchema: String?

    enum CodingKeys: String, CodingKey {
        case mode, signature
        case signingKeyURI = "signing_key_uri"
        case endpointURI = "endpoint_uri"
        case endpointSchema = "endpoint_schema"
    }
}

public struct AEODocument: Codable, Equatable, Hashable, Sendable {
    public let aeoVersion: String
    public let entity: Entity
    public let authority: Authority
    public let claims: [Claim]
    public let citationPreferences: CitationPreferences?
    public let answerConstraints: AnswerConstraints?
    public let audit: Audit?

    enum CodingKeys: String, CodingKey {
        case entity, authority, claims, audit
        case aeoVersion = "aeo_version"
        case citationPreferences = "citation_preferences"
        case answerConstraints = "answer_constraints"
    }

    public init(
        aeoVersion: String = aeoProtocolVersion,
        entity: Entity,
        authority: Authority,
        claims: [Claim],
        citationPreferences: CitationPreferences? = nil,
        answerConstraints: AnswerConstraints? = nil,
        audit: Audit? = nil
    ) {
        self.aeoVersion = aeoVersion
        self.entity = entity
        self.authority = authority
        self.claims = claims
        self.citationPreferences = citationPreferences
        self.answerConstraints = answerConstraints
        self.audit = audit
    }

    public static func from(json: String) throws -> AEODocument {
        guard let data = json.data(using: .utf8) else {
            throw AEOError.invalidUTF8
        }
        return try JSONDecoder().decode(AEODocument.self, from: data)
    }

    public static func from(data: Data) throws -> AEODocument {
        try JSONDecoder().decode(AEODocument.self, from: data)
    }

    public func toJSON(prettyPrinted: Bool = true) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }

    public func claimIDs() -> [String] {
        claims.map { $0.id }
    }

    public func findClaim(id: String) -> Claim? {
        claims.first { $0.id == id }
    }
}

public enum AEOError: Error, Equatable, Hashable, Sendable {
    case invalidUTF8
    case httpStatus(code: Int, url: String)
    case noResponseBody
}
