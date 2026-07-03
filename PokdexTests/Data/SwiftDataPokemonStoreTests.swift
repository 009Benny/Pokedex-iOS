//
//  SwiftDataPokemonStoreTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import Testing
@testable import Pokdex

/// Integration tests for the SwiftData store using an in-memory container.
struct SwiftDataPokemonStoreTests {
    private func makeSUT() throws -> SwiftDataPokemonStore {
        let container = try SwiftDataPokemonStore.makeContainer(inMemory: true)
        return SwiftDataPokemonStore(modelContainer: container)
    }

    @Test("Page round-trip: saves and restores items in order with metadata")
    func pageRoundTrip() async throws {
        let sut = try makeSUT()
        let page = TestFixtures.page(ids: [4, 1, 9], total: 1500, hasMore: true)

        await sut.savePage(page, offset: 20)
        let restored = await sut.page(limit: 3, offset: 20, maxAge: 60)

        #expect(restored != nil)
        #expect(restored?.items.map(\.id) == [4, 1, 9]) // insertion order, not id order
        #expect(restored?.totalCount == 1500)
        #expect(restored?.hasMore == true)
    }

    @Test("Missing page returns nil")
    func missingPageReturnsNil() async throws {
        let sut = try makeSUT()

        let restored = await sut.page(limit: 20, offset: 0, maxAge: 60)

        #expect(restored == nil)
    }

    @Test("Expired page returns nil (TTL)")
    func expiredPageReturnsNil() async throws {
        let sut = try makeSUT()
        await sut.savePage(TestFixtures.page(ids: [1, 2]), offset: 0)

        let restored = await sut.page(limit: 2, offset: 0, maxAge: 0)

        #expect(restored == nil)
    }

    @Test("Detail round-trip preserves every property group")
    func detailRoundTrip() async throws {
        let sut = try makeSUT()
        let detail = TestFixtures.detail(id: 1)

        await sut.saveDetail(detail)
        let restored = await sut.detail(id: 1, maxAge: 60)

        #expect(restored == detail) // PokemonDetail is Equatable: full comparison
    }

    @Test("Saving the same page twice upserts instead of duplicating")
    func savingTwiceUpserts() async throws {
        let sut = try makeSUT()
        await sut.savePage(TestFixtures.page(ids: [1, 2]), offset: 0)
        await sut.savePage(TestFixtures.page(ids: [1, 2]), offset: 0)

        let restored = await sut.page(limit: 2, offset: 0, maxAge: 60)

        #expect(restored?.items.count == 2)
    }
}
