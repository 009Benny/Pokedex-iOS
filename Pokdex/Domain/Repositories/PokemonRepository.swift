//
//  PokemonRepository.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

/// This abstraction will help to define the contract to implement in Data layer
protocol PokemonRepository: Sendable {
    /// This function obtains a list of items by each page
    func fetchPage(limit: Int, offset:Int) async throws -> PokemonPage
    
    
    /// This function obtains the defailt of a Pokemon by Id
    func fetchDetail(id: Int) async throws -> Pokemon
}
