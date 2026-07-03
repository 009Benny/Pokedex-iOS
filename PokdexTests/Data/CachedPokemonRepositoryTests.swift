//
//  CachedPokemonRepositoryTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import Testing
@testable import Pokdex

struct CachedPokemonRepositoryTests {
    @Test("Fresh cache: returns local data without hitting the network")
    func freshCacheSkipsNetwork() async throws {
        let remote = MockPokemonRepository()
        let local = MockPokemonLocalDataSource()
        local.storedPage = TestFixtures.page(ids: [1, 2, 3])
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let page = try await sut.fetchPage(limit: 20, offset: 0)

        #expect(page.items.count == 3)
        #expect(remote.fetchPageCalls.isEmpty)
    }

    @Test("Cache miss: fetches from network and persists the result")
    func cacheMissFetchesAndSaves() async throws {
        let remote = MockPokemonRepository()
        remote.pageResult = .success(TestFixtures.page(ids: Array(1...20)))
        let local = MockPokemonLocalDataSource()
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let page = try await sut.fetchPage(limit: 20, offset: 0)

        #expect(page.items.count == 20)
        #expect(remote.fetchPageCalls.count == 1)
        #expect(local.savedPages.count == 1)
        #expect(local.savedPages.first?.offset == 0)
    }

    @Test("Expired cache: goes to the network and refreshes")
    func expiredCacheRefreshesFromNetwork() async throws {
        let remote = MockPokemonRepository()
        remote.pageResult = .success(TestFixtures.page(ids: Array(1...20)))
        let local = MockPokemonLocalDataSource()
        local.storedPage = TestFixtures.page(ids: [1, 2, 3])
        local.storedPageIsStale = true
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let page = try await sut.fetchPage(limit: 20, offset: 0)

        #expect(page.items.count == 20) // fresh network data, not the stale 3
        #expect(remote.fetchPageCalls.count == 1)
        #expect(local.savedPages.count == 1)
    }

    @Test("Offline: falls back to stale cache when the network fails")
    func networkFailureFallsBackToStaleCache() async throws {
        let remote = MockPokemonRepository() // defaults to failure
        let local = MockPokemonLocalDataSource()
        local.storedPage = TestFixtures.page(ids: [1, 2, 3])
        local.storedPageIsStale = true
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let page = try await sut.fetchPage(limit: 20, offset: 0)

        #expect(page.items.count == 3) // stale is better than nothing
    }

    @Test("No cache and no network: rethrows the network error")
    func noCacheNoNetworkThrows() async {
        let remote = MockPokemonRepository()
        remote.pageResult = .failure(NetworkError.statusCode(500))
        let local = MockPokemonLocalDataSource()
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        await #expect(throws: NetworkError.statusCode(500)) {
            _ = try await sut.fetchPage(limit: 20, offset: 0)
        }
    }

    @Test("Detail follows the same policy: fresh cache skips network")
    func detailFreshCacheSkipsNetwork() async throws {
        let remote = MockPokemonRepository()
        let local = MockPokemonLocalDataSource()
        local.storedDetail = TestFixtures.detail(id: 1)
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let detail = try await sut.fetchDetail(id: 1)

        #expect(detail.id == 1)
        #expect(remote.fetchDetailCalls.isEmpty)
    }

    @Test("Detail cache miss: fetches from network and persists")
    func detailCacheMissFetchesAndSaves() async throws {
        let remote = MockPokemonRepository()
        remote.detailResult = .success(TestFixtures.detail(id: 7))
        let local = MockPokemonLocalDataSource()
        let sut = await CachedPokemonRepository(remote: remote, local: local)

        let detail = try await sut.fetchDetail(id: 7)

        #expect(detail.id == 7)
        #expect(local.savedDetails.map(\.id) == [7])
    }
}
