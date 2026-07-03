//
//  DetailViewlModelTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Testing
@testable import Pokdex

@MainActor
struct PokemonDetailViewModelTests {
    @Test("Success: pass to .loaded with the Detail")
    func loadSuccessTransitionsToLoaded() async {
        // Given
        let useCase = MockGetPokemonDetailUseCase()
        useCase.result = .success(TestFixtures.detail(id: 1))
        let item = TestFixtures.summary(id: 1, name: "bulbasaur")
        let sut = DetailViewModel(item: item, useCase: useCase)
        
        // When
        await sut.load()
        
        // Then
        guard case .loaded(let detail) = sut.state else {
            Issue.record("Status expected: loaded, current: \(sut.state)")
            return
        }
        #expect(detail.id == 1)
        #expect(useCase.receivedIDs == [1])
    }
    
    @Test("Fail: pass to .failed")
    func loadFailureTransitionsToFailed() async {
        let useCase = MockGetPokemonDetailUseCase()
        useCase.result = .failure(NetworkError.statusCode(500))
        let item = TestFixtures.summary(id: 1, name: "bulbasaur")
        let sut = DetailViewModel(item: item, useCase: useCase)

        await sut.load()

        guard case .failed = sut.state else {
            Issue.record("Status expected: failed, actual \(sut.state)")
            return
        }
    }
}
