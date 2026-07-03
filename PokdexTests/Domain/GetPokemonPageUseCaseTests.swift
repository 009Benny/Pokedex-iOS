//
//  GetPokemonPageUseCaseTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Testing
@testable import Pokdex

struct GetPokemonPageUseCaseTests {
    @Test("Delegates to the repository with the received parameters")
    func executeDelegatesToRepository() async throws {
        let repository = MockPokemonRepository()
        repository.pageResult = .success(TestFixtures.page(ids: [1, 2, 3]))
        let sut = await DefaultGetPokemonPageUseCase(repository: repository)

        let page = try await sut.execute(limit: 20, offset: 40)

        #expect(page.items.count == 3)
        #expect(repository.fetchPageCalls.first?.limit == 20)
        #expect(repository.fetchPageCalls.first?.offset == 40)
    }

    @Test("Propagates repository errors")
    func executePropagatesErrors() async {
        let repository = MockPokemonRepository()
        repository.pageResult = .failure(NetworkError.statusCode(500))
        let sut = await DefaultGetPokemonPageUseCase(repository: repository)

        await #expect(throws: NetworkError.statusCode(500)) {
            _ = try await sut.execute(limit: 20, offset: 0)
        }
    }
}
