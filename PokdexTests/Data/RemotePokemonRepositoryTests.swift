//
//  RemotePokemonRepositoryTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import Testing
@testable import Pokdex

struct RemotePokemonRepositoryTests {
    @Test("Enriches the page preserving order and computes hasMore")
    func fetchPageEnrichesItemsPreservingOrderAndComputesHasMore() async throws {
        let client = MockHTTPClient()
        let listURL = await PokeAPIEndpoint.pokemonList(limit: 2, offset: 0).url
        client.responses[listURL] = .success(Data("""
        {
          "count": 1500,
          "next": "https://pokeapi.co/api/v2/pokemon?offset=2&limit=2",
          "previous": null,
          "results": [
            {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
            {"name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2/"}
          ]
        }
        """.utf8))
        client.responses[URL(string: "https://pokeapi.co/api/v2/pokemon/1")!] =
            .success(Self.detailJSON(id: 1, name: "bulbasaur"))
        client.responses[URL(string: "https://pokeapi.co/api/v2/pokemon/2")!] =
            .success(Self.detailJSON(id: 2, name: "ivysaur"))

        let sut = await RemotePokemonRepository(client: client)
        let page = try await sut.fetchPage(limit: 2, offset: 0)

        #expect(page.items.map(\.id) == [1, 2])
        #expect(page.items.map(\.name) == ["bulbasaur", "ivysaur"])
        #expect(page.totalCount == 1500)
        #expect(page.hasMore)
    }

    @Test("When next is null, hasMore is false")
    func fetchPageWhenNextIsNullHasMoreIsFalse() async throws {
        let client = MockHTTPClient()
        let listURL = await PokeAPIEndpoint.pokemonList(limit: 20, offset: 1480).url
        client.responses[listURL] = .success(Data("""
        {"count": 1481, "next": null, "previous": null,
         "results": [{"name": "last", "url": "https://pokeapi.co/api/v2/pokemon/1481/"}]}
        """.utf8))
        client.responses[URL(string: "https://pokeapi.co/api/v2/pokemon/1481")!] =
            .success(Self.detailJSON(id: 1481, name: "last"))

        let sut = await RemotePokemonRepository(client: client)
        let page = try await sut.fetchPage(limit: 20, offset: 1480)

        #expect(!page.hasMore)
    }

    @Test("Propagates the decoding error as NetworkError.decoding")
    func fetchDetailPropagatesDecodingError() async {
        let client = MockHTTPClient()
        await client.responses[PokeAPIEndpoint.pokemonDetail(id: 1).url] = .success(Data("not json".utf8))

        let sut = await RemotePokemonRepository(client: client)

        do {
            _ = try await sut.fetchDetail(id: 1)
            Issue.record("Should throw a decoding error")
        } catch let error as NetworkError {
            guard case .decoding = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    // MARK: - Helpers

    private static func detailJSON(id: Int, name: String) -> Data {
        Data("""
        {
          "id": \(id),
          "name": "\(name)",
          "base_experience": 64,
          "height": 7,
          "weight": 69,
          "order": \(id),
          "is_default": true,
          "location_area_encounters": "",
          "types": [{"slot": 1, "type": {"name": "grass", "url": "u"}}],
          "abilities": [],
          "stats": [],
          "moves": [],
          "forms": [],
          "held_items": [],
          "game_indices": [],
          "species": {"name": "\(name)", "url": "u"},
          "sprites": {"front_default": null, "back_default": null, "front_shiny": null, "back_shiny": null, "other": null},
          "cries": null
        }
        """.utf8)
    }
}
