//
//  NetworkError.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidResponse
    case statusCode(Int)
    case decoding(String)
    case transport(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Invalid response from server"
        case .statusCode(let code): "Invalid status code: \(code)"
        case .decoding(let error): "Failed to decode: \(error)"
        case .transport(let error): "Network error: \(error)"
        }
    }
}
