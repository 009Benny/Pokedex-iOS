//
//  CachedPokemonRepository.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

/// Caching decorator over any `PokemonRepository` (Decorator pattern).
///
/// Policy: cache-first with TTL, plus stale fallback.
/// 1. Fresh local data (younger than `maxAge`) → returned without hitting the network.
/// 2. Cache miss/expired → network, then the result is persisted.
/// 3. Network failure → expired cache, if any, is returned (offline support).
///
/// Because it implements the same protocol it wraps, Domain and
/// Presentation are unaware that caching exists (Liskov + Open/Closed).
struct CachedPokemonRepository: PokemonRepository {
    private let remote: PokemonRepository
    private let local: PokemonLocalDataSource
    private let maxAge: TimeInterval

    init(
        remote: PokemonRepository,
        local: PokemonLocalDataSource,
        maxAge: TimeInterval = 60 * 60 * 24 // a day
    ) {
        self.remote = remote
        self.local = local
        self.maxAge = maxAge
    }

    func fetchPage(limit: Int, offset: Int) async throws -> PokemonPage {
        if let fresh = await local.page(limit: limit, offset: offset, maxAge: maxAge) {
            return fresh
        }
        do {
            let page = try await remote.fetchPage(limit: limit, offset: offset)
            await local.savePage(page, offset: offset)
            return page
        } catch {
            if let stale = await local.page(limit: limit, offset: offset, maxAge: .infinity) {
                return stale
            }
            throw error
        }
    }

    func fetchDetail(id: Int) async throws -> Pokemon {
        if let fresh = await local.detail(id: id, maxAge: maxAge) {
            return fresh
        }
        do {
            let detail = try await remote.fetchDetail(id: id)
            await local.saveDetail(detail)
            return detail
        } catch {
            if let stale = await local.detail(id: id, maxAge: .infinity) {
                return stale
            }
            throw error
        }
    }
}
