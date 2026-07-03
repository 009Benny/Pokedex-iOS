//
//  PokemonListResponse.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

struct PokemonPageResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonItemResponse]
    
    struct PokemonItemResponse: Decodable {
        let name: String
        let url: String
    }
}
