//
//  HomeViewModelTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Testing
@testable import Pokdex

@MainActor
struct HomeViewModelTests {
    @Test("Initial load: fills the first page of 20")
    func loadInitialPopulatesFirstPage() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20)))
        let sut = HomeViewModel(useCase)

        await sut.loadInitialIfNeeded()

        #expect(sut.items.count == 20)
        #expect(sut.hasMore)
        #expect(sut.errorMessage == nil)
        #expect(useCase.receivedCalls.first?.limit == 20)
        #expect(useCase.receivedCalls.first?.offset == 0)
    }

    @Test("loadInitialIfNeeded is idempotent across re-renders")
    func loadInitialIfNeededIsIdempotent() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20)))
        let sut = HomeViewModel(useCase)

        await sut.loadInitialIfNeeded()
        await sut.loadInitialIfNeeded()

        #expect(useCase.receivedCalls.count == 1)
    }

    @Test("Lazy scroll: appends the next page when the last cell appears")
    func loadMoreAppendsNextPageWhenLastItemAppears() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20)))
        useCase.pagesByOffset[20] = .success(TestFixtures.page(ids: Array(21...40)))
        let sut = HomeViewModel(useCase)
        await sut.loadInitialIfNeeded()

        await sut.loadMoreIfNeeded(currentItem: sut.items[19])

        #expect(sut.items.count == 40)
        #expect(sut.items.last?.id == 40)
    }

    @Test("Does not paginate when the visible cell is far from the end")
    func loadMoreDoesNothingForItemsFarFromEnd() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20)))
        let sut = HomeViewModel(useCase)
        await sut.loadInitialIfNeeded()

        await sut.loadMoreIfNeeded(currentItem: sut.items[0])

        #expect(sut.items.count == 20)
        #expect(useCase.receivedCalls.count == 1) // only the initial load
    }

    @Test("Does not paginate when there are no more pages")
    func loadMoreDoesNothingWhenNoMorePages() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20), hasMore: false))
        let sut = HomeViewModel(useCase)
        await sut.loadInitialIfNeeded()

        await sut.loadMoreIfNeeded(currentItem: sut.items[19])

        #expect(sut.items.count == 20)
        #expect(useCase.receivedCalls.count == 1)
    }

    @Test("Filters duplicate ids across pages")
    func loadMoreFiltersDuplicateIDs() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .success(TestFixtures.page(ids: Array(1...20)))
        useCase.pagesByOffset[20] = .success(TestFixtures.page(ids: Array(20...39))) // 20 is duplicated
        let sut = HomeViewModel(useCase)
        await sut.loadInitialIfNeeded()

        await sut.loadMoreIfNeeded(currentItem: sut.items[19])

        #expect(sut.items.count == 39)
        #expect(Set(sut.items.map(\.id)).count == sut.items.count)
    }

    @Test("Initial load failure: exposes an error message")
    func loadInitialFailureExposesErrorMessage() async {
        let useCase = MockGetPokemonPageUseCase()
        useCase.pagesByOffset[0] = .failure(NetworkError.statusCode(500))
        let sut = HomeViewModel(useCase)

        await sut.loadInitialIfNeeded()

        #expect(sut.items.isEmpty)
        #expect(sut.errorMessage != nil)
    }
    
}

