//
//  PokemonLocalDataSource.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

/// Local cache abstraction. `CachedPokemonRepository` depends on this
/// protocol, not on SwiftData (Dependency Inversion), so the storage
/// technology can change without touching the caching policy.
protocol PokemonLocalDataSource: Sendable {
    /// Returns the cached page if it exists and is younger than `maxAge`.
    func page(limit: Int, offset: Int, maxAge: TimeInterval) async -> PokemonPage?
    func savePage(_ page: PokemonPage, offset: Int) async

    /// Returns the cached detail if it exists and is younger than `maxAge`.
    func detail(id: Int, maxAge: TimeInterval) async -> Pokemon?
    func saveDetail(_ detail: Pokemon) async
}

