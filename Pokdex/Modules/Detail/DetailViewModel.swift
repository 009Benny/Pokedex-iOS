//
//  DetailViewModel.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class DetailViewModel {
    private(set) var state: ViewState<Pokemon> = .idle
    
    let item:PokemonItem
    private let useCase: GetPokemonDetailUseCase
    
    init(item: PokemonItem, useCase: GetPokemonDetailUseCase) {
        self.item = item
        self.useCase = useCase
    }
    
    func load() async {
        if case .loading = state { return }
        state = .loading
        do {
            state = .loaded(try await useCase.execute(id: item.id))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    enum ViewState<Value> {
        case idle
        case loading
        case loaded(Value)
        case failed(String)
    }
}


