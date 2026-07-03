//
//  AppContainer.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

@MainActor
final class AppContainer {
    private lazy var client: NetworkClient  = URLSessionNetworkClient()
    /// Remote repository wrapped in a SwiftData caching decorator.
    /// If the persistent store cannot be created, the app degrades
    /// gracefully to network-only instead of crashing.
    private lazy var pokemonRepository: PokemonRepository = {
        let remote = RemotePokemonRepository(client: client)
        guard let container = try? SwiftDataPokemonStore.makeContainer() else {
            return remote
        }
        let local = SwiftDataPokemonStore(modelContainer: container)
        return CachedPokemonRepository(remote: remote, local: local)
    }()
    
    // Domain
    private lazy var getPokemonPageUseCase: GetPokemonPageUseCase =
        DefaultGetPokemonPageUseCase(repository: pokemonRepository)
    private lazy var getPokemonDetailUseCase: GetPokemonDetailUseCase =
        DefaultGetPokemonDetailUseCase(repository: pokemonRepository)
    
    func makeHome() -> HomeView {
        HomeView(
            viewModel: HomeViewModel(getPokemonPageUseCase),
            detailView: { [unowned self] item in
                makeDetail(for: item)
            }
        )
    }
    
    func makeDetail(for item: PokemonItem) -> DetailView {
        DetailView(viewModel: DetailViewModel(item: item, useCase: getPokemonDetailUseCase))
    }
    
}
