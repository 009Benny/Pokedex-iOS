//
//  Mocks.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
@testable import Pokdex

// MARK: - Build entities for tests

enum TestFixtures {
    static func summary(id: Int, name: String = "pokemon") -> PokemonItem {
        PokemonItem(
            id: id,
            name: "\(name)-\(id)",
            types: [PokemonType(slot: 1, name: "grass")],
            baseExperience: 60 + id,
            spriteURL: nil
        )
    }

    static func page(ids: [Int], total: Int = 1500, hasMore: Bool = true) -> PokemonPage {
        PokemonPage(items: ids.map { summary(id: $0) }, totalCount: total, hasMore: hasMore)
    }

    static func detail(id: Int = 1) -> Pokemon {
        Pokemon(
            id: id,
            name: "bulbasaur",
            baseExperience: 64,
            height: 7,
            weight: 69,
            order: 1,
            isDefault: true,
            locationAreaEncounters: "https://pokeapi.co/api/v2/pokemon/1/encounters",
            types: [PokemonType(slot: 1, name: "grass"), PokemonType(slot: 2, name: "poison")],
            abilities: [.init(name: "overgrow", isHidden: false, slot: 1)],
            stats: [.init(name: "hp", baseStat: 45, effort: 0)],
            moves: ["razor-wind"],
            forms: ["bulbasaur"],
            heldItems: [],
            gameIndices: [.init(gameIndex: 153, version: "red")],
            species: .init(name: "bulbasaur"),
            sprites: .init(officialArtwork: nil, frontDefault: nil, backDefault: nil, frontShiny: nil, backShiny: nil),
            cries: .init(latest: nil, legacy: nil)
        )
    }
}

// MARK: - Mocks of use cases

final class MockGetPokemonPageUseCase: GetPokemonPageUseCase, @unchecked Sendable {
    var pagesByOffset: [Int: Result<PokemonPage, Error>] = [:]
    private(set) var receivedCalls: [(limit: Int, offset: Int)] = []

    func execute(limit: Int, offset: Int) async throws -> PokemonPage {
        receivedCalls.append((limit, offset))
        guard let result = pagesByOffset[offset] else {
            throw NetworkError.invalidResponse
        }
        return try result.get()
    }
}

final class MockGetPokemonDetailUseCase: GetPokemonDetailUseCase, @unchecked Sendable {
    var result: Result<Pokemon, Error> = .failure(NetworkError.invalidResponse)
    private(set) var receivedIDs: [Int] = []

    func execute(id: Int) async throws -> Pokemon {
        receivedIDs.append(id)
        return try result.get()
    }
}

// MARK: - Mock repositories

final class MockPokemonRepository: PokemonRepository, @unchecked Sendable {
    var pageResult: Result<PokemonPage, Error> = .failure(NetworkError.invalidResponse)
    var detailResult: Result<Pokemon, Error> = .failure(NetworkError.invalidResponse)
    private(set) var fetchPageCalls: [(limit: Int, offset: Int)] = []
    private(set) var fetchDetailCalls: [Int] = []

    func fetchPage(limit: Int, offset: Int) async throws -> PokemonPage {
        fetchPageCalls.append((limit, offset))
        return try pageResult.get()
    }

    func fetchDetail(id: Int) async throws -> Pokemon {
        fetchDetailCalls.append(id)
        return try detailResult.get()
    }
}

// MARK: - Local data source mock (for caching tests)

final class MockPokemonLocalDataSource: PokemonLocalDataSource, @unchecked Sendable {
    var storedPage: PokemonPage?
    var storedPageIsStale = false
    var storedDetail: Pokemon?
    var storedDetailIsStale = false

    private(set) var savedPages: [(page: PokemonPage, offset: Int)] = []
    private(set) var savedDetails: [Pokemon] = []

    func page(limit: Int, offset: Int, maxAge: TimeInterval) async -> PokemonPage? {
        guard let storedPage else { return nil }
        if storedPageIsStale && maxAge != .infinity { return nil }
        return storedPage
    }

    func savePage(_ page: PokemonPage, offset: Int) async {
        savedPages.append((page, offset))
    }

    func detail(id: Int, maxAge: TimeInterval) async -> Pokemon? {
        guard let storedDetail else { return nil }
        if storedDetailIsStale && maxAge != .infinity { return nil }
        return storedDetail
    }

    func saveDetail(_ detail: Pokemon) async {
        savedDetails.append(detail)
    }
}

// MARK: - Mock de HTTPClient (para tests de Data)

final class MockHTTPClient: NetworkClient, @unchecked Sendable {
    var responses: [URL: Result<Data, Error>] = [:]

    func data(from url: URL) async throws -> Data {
        guard let result = responses[url] else {
            throw NetworkError.statusCode(404)
        }
        return try result.get()
    }
}
