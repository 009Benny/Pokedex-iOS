//
//  HomeViewModel.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation
import Observation

/// This View Model have the responsability of request the data
/// when the user are near to the last item with lazy scroll
@MainActor
@Observable
final class HomeViewModel {
    // View vars
    private(set) var items: [PokemonItem] = []
    private(set) var errorMessage: String?
    private(set) var isLoadingInitial = false
    private(set) var isLoadingMore = false
    private(set) var hasMore = true

    private let pageSize = 20
    
    // Dependencies
    private let useCase: GetPokemonPageUseCase
    
    init(_ useCase: GetPokemonPageUseCase) {
        self.useCase = useCase
    }
    
    func loadInitialIfNeeded() async {
        guard items.isEmpty, !isLoadingInitial else { return }
        await loadInitial()
    }
    
    private func loadInitial() async {
        isLoadingInitial = true
        errorMessage = nil
        defer { isLoadingInitial = false }
        do {
            let page = try await useCase.execute(limit: pageSize, offset: 0)
            items = page.items
            hasMore = page.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Lazy scroll call this method
    func loadMoreIfNeeded(currentItem: PokemonItem) async {
        guard hasMore, !isLoadingMore, !isLoadingInitial else { return }
        guard shouldPrefetch(after: currentItem) else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let page = try await useCase.execute(limit: pageSize, offset: items.count)
            // Clean duplicates
            let ids = Set(items.map(\.id))
            items += page.items.filter { !ids.contains($0.id) }
            hasMore = page.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func shouldPrefetch(after item: PokemonItem) -> Bool {
        let prefetchThreshold: Int = 5 // Cells before the end to load more
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return false }
        return index >= items.count - prefetchThreshold
    }
    
}
