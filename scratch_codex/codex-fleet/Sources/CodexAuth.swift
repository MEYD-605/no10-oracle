import Foundation

// MARK: - auth.json model + token refresh
// Ported from CodexBar: CodexOAuthCredentials + CodexTokenRefresher

struct CodexAuth: Sendable {
    struct Tokens: Sendable {
        let accessToken: String
        let refreshToken: String
        let idToken: String?
        let accountId: String?
    }

    let tokens: Tokens
    let lastRefresh: Date?

    // Same threshold as CodexBar: refresh when >8 days old
    private static let refreshThresholdDays: TimeInterval = 8 * 24 * 60 * 60

    var needsRefresh: Bool {
        guard let lastRefresh else { return true }
        return Date().timeIntervalSince(lastRefresh) > Self.refreshThresholdDays
    }

    var accessTokenExpiry: Date? {
        JWTHelper.expiry(of: tokens.accessToken)
    }

    // MARK: - Load from disk

    static func load(from codexHome: String) throws -> CodexAuth {
        let url = URL(fileURLWithPath: codexHome).appendingPathComponent("auth.json")
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AuthError.notFound(url.path)
        }

        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AuthError.invalidJSON
        }

        // Support OPENAI_API_KEY mode (no refresh)
        if let apiKey = json["OPENAI_API_KEY"] as? String,
           !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            return CodexAuth(
                tokens: Tokens(accessToken: apiKey, refreshToken: "", idToken: nil, accountId: nil),
                lastRefresh: nil
            )
        }

        guard let tokensDict = json["tokens"] as? [String: Any] else {
            throw AuthError.missingTokens
        }

        let accessToken = stringValue(tokensDict, "access_token", "accessToken") ?? ""
        let refreshToken = stringValue(tokensDict, "refresh_token", "refreshToken") ?? ""
        guard !accessToken.isEmpty else { throw AuthError.missingTokens }

        let idToken = stringValue(tokensDict, "id_token", "idToken")
        let accountId = stringValue(tokensDict, "account_id", "accountId")
        let lastRefresh = parseISO8601(json["last_refresh"] as? String)

        return CodexAuth(
            tokens: Tokens(
                accessToken: accessToken,
                refreshToken: refreshToken,
                idToken: idToken,
                accountId: accountId
            ),
            lastRefresh: lastRefresh
        )
    }

    // MARK: - Token refresh
    // Same endpoint + client_id as CodexBar: CodexTokenRefresher.swift

    private static let refreshEndpoint = URL(string: "https://auth.openai.com/oauth/token")!
    private static let clientID = "app_EMoamEEZ73f0CkXaXp7hrann"

    static func refresh(_ auth: CodexAuth, writeTo codexHome: String) async throws -> CodexAuth {
        guard !auth.tokens.refreshToken.isEmpty else { return auth }

        var request = URLRequest(url: refreshEndpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "client_id": clientID,
            "grant_type": "refresh_token",
            "refresh_token": auth.tokens.refreshToken,
            "scope": "openid profile email",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.refreshFailed("No HTTP response")
        }
        guard httpResponse.statusCode == 200 else {
            let errorCode = extractErrorCode(from: data)
            throw AuthError.refreshFailed(errorCode ?? "HTTP \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AuthError.refreshFailed("Invalid JSON response")
        }

        let newAuth = CodexAuth(
            tokens: Tokens(
                accessToken: json["access_token"] as? String ?? auth.tokens.accessToken,
                refreshToken: json["refresh_token"] as? String ?? auth.tokens.refreshToken,
                idToken: json["id_token"] as? String ?? auth.tokens.idToken,
                accountId: auth.tokens.accountId
            ),
            lastRefresh: Date()
        )

        // Write back to auth.json (same as CodexBar: CodexOAuthCredentialsStore.save)
        try Self.save(newAuth, to: codexHome)
        return newAuth
    }

    private static func save(_ auth: CodexAuth, to codexHome: String) throws {
        let url = URL(fileURLWithPath: codexHome).appendingPathComponent("auth.json")

        // Read existing file to preserve extra fields (auth_mode etc.)
        var json: [String: Any] = [:]
        if let data = try? Data(contentsOf: url),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        {
            json = existing
        }

        var tokens: [String: Any] = [
            "access_token": auth.tokens.accessToken,
            "refresh_token": auth.tokens.refreshToken,
        ]
        if let idToken = auth.tokens.idToken { tokens["id_token"] = idToken }
        if let accountId = auth.tokens.accountId { tokens["account_id"] = accountId }

        json["tokens"] = tokens
        json["last_refresh"] = ISO8601DateFormatter().string(from: Date())

        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: url, options: .atomic)
    }

    // MARK: - Helpers

    private static func extractErrorCode(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let error = json["error"] as? [String: Any], let code = error["code"] as? String { return code }
        if let error = json["error"] as? String { return error }
        return json["code"] as? String
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case notFound(String)
    case invalidJSON
    case missingTokens
    case refreshFailed(String)

    var errorDescription: String? {
        switch self {
        case let .notFound(path): "auth.json not found: \(path)"
        case .invalidJSON: "Invalid auth.json"
        case .missingTokens: "No tokens in auth.json — run `codex` to log in"
        case let .refreshFailed(reason): "Token refresh failed: \(reason)"
        }
    }
}

// MARK: - JWT decode (zero-dep, same as CodexBar)

enum JWTHelper {
    static func expiry(of jwt: String) -> Date? {
        guard let payload = Self.decodePayload(jwt),
              let exp = payload["exp"] as? Double
        else { return nil }
        return Date(timeIntervalSince1970: exp)
    }

    static func email(of jwt: String) -> String? {
        guard let payload = Self.decodePayload(jwt) else { return nil }
        return payload["email"] as? String
    }

    static func decodePayload(_ jwt: String) -> [String: Any]? {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }
}

// MARK: - Shared parsing helpers

private func stringValue(_ dict: [String: Any], _ snakeCase: String, _ camelCase: String) -> String? {
    if let v = dict[snakeCase] as? String, !v.isEmpty { return v }
    if let v = dict[camelCase] as? String, !v.isEmpty { return v }
    return nil
}

private func parseISO8601(_ string: String?) -> Date? {
    guard let string, !string.isEmpty else { return nil }
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = f.date(from: string) { return d }
    f.formatOptions = [.withInternetDateTime]
    return f.date(from: string)
}
