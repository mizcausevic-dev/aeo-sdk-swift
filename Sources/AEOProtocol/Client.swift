// HTTP client helpers for the AEO Protocol discovery convention.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public let wellKnownPath: String = "/.well-known/aeo.json"
public let acceptHeader: String = "application/aeo+json, application/json"

/// Build the canonical well-known URL for an origin.
public func wellKnownURL(origin: String) -> String {
    var trimmed = origin
    while trimmed.hasSuffix("/") {
        trimmed.removeLast()
    }
    return trimmed + wellKnownPath
}

/// Fetch and parse the AEO declaration at `origin`'s well-known URL.
public func fetchWellKnown(origin: String, session: URLSession = .shared) async throws -> AEODocument {
    let urlString = wellKnownURL(origin: origin)
    guard let url = URL(string: urlString) else {
        throw AEOError.httpStatus(code: -1, url: urlString)
    }
    var request = URLRequest(url: url)
    request.setValue(acceptHeader, forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)
    if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
        throw AEOError.httpStatus(code: http.statusCode, url: urlString)
    }
    return try AEODocument.from(data: data)
}
