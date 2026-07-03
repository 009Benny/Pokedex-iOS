//
//  PokeAPIEndpoint.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

/// This enum will contain all the paths that this app will request to the Poke API.
///
enum PokeAPIEndpoint {
    // If the base URL isn't created, the app should crash because will show nothing
    static let baseUrl = URL(string: "https://pokeapi.co/api/v2")!
    
    case pokemonList(limit: Int, offset:Int)
    case pokemonDetail(id: Int)
    
    var url: URL {
        switch self {
        case .pokemonList(let limit, let offset):
            var components = URLComponents(
                url: Self.baseUrl.appending(path: "pokemon"),
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
            guard let url = components?.url else {
                fatalError("Failed to create URLComponents")
            }
            return url
        case .pokemonDetail(id: let id):
            return Self.baseUrl.appendingPathComponent("pokemon/\(id)")
        }
    }
    
}
