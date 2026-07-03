//
//  NetworkClient.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

/// This protocol will be used to replace avoid calls to the API in tests
protocol NetworkClient {
    func data(from url: URL) async throws -> Data
}

struct URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func data(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.statusCode(http.statusCode)
            }
            return data
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }
}

