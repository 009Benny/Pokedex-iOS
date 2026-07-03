//
//  GetPokemonPageUseCase.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

/// Case: Get a list of Pokemons to display a summary in Home View.
protocol GetPokemonPageUseCase {
    func execute(limit: Int, offset: Int) async throws -> PokemonPage
}

struct DefaultGetPokemonPageUseCase: GetPokemonPageUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(limit: Int, offset: Int) async throws -> PokemonPage {
        try await repository.fetchPage(limit: limit, offset: offset)
    }
}
