//
//  GetPokemonDetailUseCase.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

/// Case:Get the full detail of a Pokemon
protocol GetPokemonDetailUseCase: Sendable {
    func execute(id: Int) async throws -> Pokemon
}

struct DefaultGetPokemonDetailUseCase: GetPokemonDetailUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> Pokemon {
        try await repository.fetchDetail(id: id)
    }
}
