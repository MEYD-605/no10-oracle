import Foundation

// MARK: - Codex Usage API
// Ported from CodexBar: CodexOAuthUsageFetcher.swift
// Endpoint: GET https://chatgpt.com/backend-api/wham/usage

enum CodexUsageAPI {
    private static let usageURL = URL(string: "https://chatgpt.com/backend-api/wham/usage")!

    static func fetchUsage(accessToken: String, accountId: String?) async throws -> UsageResponse {
        var request = URLRequest(url: usageURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("CodexFleet/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let accountId, !accountId.isEmpty {
            request.setValue(accountId, forHTTPHeaderField: "ChatGPT-Account-Id")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(UsageResponse.self, from: data)
        case 401, 403:
            throw UsageError.unauthorized
        default:
            throw UsageError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Response models (matches ChatGPT /wham/usage JSON)

struct UsageResponse: Decodable, Sendable {
    let email: String
    let planType: String
    let rateLimit: RateLimitInfo
    let additionalRateLimits: [AdditionalRateLimit]?
    let credits: CreditsInfo

    enum CodingKeys: String, CodingKey {
        case email
        case planType = "plan_type"
        case rateLimit = "rate_limit"
        case additionalRateLimits = "additional_rate_limits"
        case credits
    }
}

struct RateLimitInfo: Decodable, Sendable {
    let allowed: Bool
    let limitReached: Bool
    let primaryWindow: WindowSnapshot?
    let secondaryWindow: WindowSnapshot?

    enum CodingKeys: String, CodingKey {
        case allowed
        case limitReached = "limit_reached"
        case primaryWindow = "primary_window"
        case secondaryWindow = "secondary_window"
    }
}

struct WindowSnapshot: Decodable, Sendable {
    let usedPercent: Int
    let limitWindowSeconds: Int
    let resetAfterSeconds: Int
    let resetAt: Int

    enum CodingKeys: String, CodingKey {
        case usedPercent = "used_percent"
        case limitWindowSeconds = "limit_window_seconds"
        case resetAfterSeconds = "reset_after_seconds"
        case resetAt = "reset_at"
    }
}

struct AdditionalRateLimit: Decodable, Sendable {
    let limitName: String
    let meteredFeature: String
    let rateLimit: RateLimitInfo

    enum CodingKeys: String, CodingKey {
        case limitName = "limit_name"
        case meteredFeature = "metered_feature"
        case rateLimit = "rate_limit"
    }
}

struct CreditsInfo: Decodable, Sendable {
    let hasCredits: Bool
    let balance: String

    enum CodingKeys: String, CodingKey {
        case hasCredits = "has_credits"
        case balance
    }
}

// MARK: - Errors

enum UsageError: LocalizedError {
    case unauthorized
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .unauthorized: "Unauthorized — run `codex` to re-login"
        case .invalidResponse: "Invalid API response"
        case let .serverError(code): "API error: HTTP \(code)"
        }
    }
}
