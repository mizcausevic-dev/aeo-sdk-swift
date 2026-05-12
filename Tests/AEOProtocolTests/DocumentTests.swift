import XCTest
@testable import AEOProtocol

final class DocumentTests: XCTestCase {

    private func loadFixture() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "aeo-person", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testParsesCanonicalPersonExample() throws {
        let data = try loadFixture()
        let doc = try AEODocument.from(data: data)
        XCTAssertEqual(doc.aeoVersion, "0.1")
        XCTAssertEqual(doc.entity.type, .person)
        XCTAssertEqual(doc.entity.name, "Miz Causevic")
        XCTAssertEqual(doc.claims.count, 6)
    }

    func testClaimIDsRoundTrip() throws {
        let doc = try AEODocument.from(data: loadFixture())
        let ids = Set(doc.claimIDs())
        XCTAssertEqual(ids, [
            "current-role",
            "location",
            "years-experience",
            "live-products",
            "primary-stack",
            "authored-spec",
        ])
    }

    func testFindClaimReturnsClaim() throws {
        let doc = try AEODocument.from(data: loadFixture())
        let claim = try XCTUnwrap(doc.findClaim(id: "years-experience"))
        XCTAssertEqual(claim.predicate, "aeo:yearsOfExperience")
        if case .number(let n) = claim.value {
            XCTAssertEqual(n, 30)
        } else {
            XCTFail("expected number value, got \(claim.value)")
        }
    }

    func testFindClaimMissingReturnsNil() throws {
        let doc = try AEODocument.from(data: loadFixture())
        XCTAssertNil(doc.findClaim(id: "does-not-exist"))
    }

    func testRoundTripSerializationPreservesStructure() throws {
        let doc = try AEODocument.from(data: loadFixture())
        let json = try doc.toJSON()
        let reparsed = try AEODocument.from(json: json)
        XCTAssertEqual(reparsed.entity.name, doc.entity.name)
        XCTAssertEqual(reparsed.claimIDs(), doc.claimIDs())
        XCTAssertEqual(reparsed.authority.primarySources, doc.authority.primarySources)
    }

    func testBuildMinimalDocument() throws {
        let doc = AEODocument(
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
        XCTAssertEqual(doc.entity.type, .organization)
        XCTAssertEqual(doc.claims.first?.confidence, .high)
    }

    func testWellKnownURLStripsTrailingSlashes() {
        XCTAssertEqual(wellKnownURL(origin: "https://example.com"), "https://example.com/.well-known/aeo.json")
        XCTAssertEqual(wellKnownURL(origin: "https://example.com/"), "https://example.com/.well-known/aeo.json")
        XCTAssertEqual(wellKnownURL(origin: "https://example.com///"), "https://example.com/.well-known/aeo.json")
    }

    func testConfidenceDefaultsToHighOnMissingField() throws {
        // Force a Claim with no confidence field.
        let raw = """
        {
          "id": "minimal-claim",
          "predicate": "description",
          "value": "test"
        }
        """
        let data = try XCTUnwrap(raw.data(using: .utf8))
        let claim = try JSONDecoder().decode(Claim.self, from: data)
        XCTAssertEqual(claim.confidence, .high)
    }
}
