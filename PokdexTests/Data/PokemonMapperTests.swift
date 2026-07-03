//
//  PokemonMapperTests.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import Testing
@testable import Pokdex

struct PokemonMapperTests {
    @Test("The detail DTO decodes and maps to the domain")
    func detailDTODecodesAndMapsToDomain() throws {
        let data = try JSONDecoder().decode(PokemonDetailResponse.self, from: Self.detailJSON)
        let detail = PokemonMapper.detail(from: data)

        #expect(detail.id == 1)
        #expect(detail.name == "bulbasaur")
        #expect(detail.baseExperience == 64)
        #expect(detail.height == 7)
        #expect(detail.weight == 69)
        #expect(detail.isDefault)
        #expect(detail.types.map(\.name) == ["grass", "poison"])
        #expect(detail.abilities.first?.name == "overgrow")
        #expect(detail.stats.first?.baseStat == 45)
        #expect(detail.moves == ["razor-wind"])
        #expect(detail.species.name == "bulbasaur")
        #expect(detail.sprites.officialArtwork?.absoluteString == "https://example.com/official.png")
        #expect(detail.cries.latest?.absoluteString == "https://example.com/cry.ogg")
    }

    @Test("The summary sorts types by slot")
    func summaryMappingSortsTypesBySlot() throws {
        let data = try JSONDecoder().decode(PokemonDetailResponse.self, from: Self.detailJSON)
        let summary = PokemonMapper.detail(from: data)

        #expect(summary.id == 1)
        #expect(summary.baseExperience == 64)
        #expect(summary.types.map(\.name) == ["grass", "poison"])
    }

    // Fixture with types deliberately out of order to exercise the sort by slot.
    static let detailJSON = Data("""
    {
      "id": 1,
      "name": "bulbasaur",
      "base_experience": 64,
      "height": 7,
      "weight": 69,
      "order": 1,
      "is_default": true,
      "location_area_encounters": "https://pokeapi.co/api/v2/pokemon/1/encounters",
      "types": [
        {"slot": 2, "type": {"name": "poison", "url": "u"}},
        {"slot": 1, "type": {"name": "grass", "url": "u"}}
      ],
      "abilities": [
        {"ability": {"name": "overgrow", "url": "u"}, "is_hidden": false, "slot": 1}
      ],
      "stats": [
        {"base_stat": 45, "effort": 0, "stat": {"name": "hp", "url": "u"}}
      ],
      "moves": [
        {"move": {"name": "razor-wind", "url": "u"}}
      ],
      "forms": [{"name": "bulbasaur", "url": "u"}],
      "held_items": [],
      "game_indices": [{"game_index": 153, "version": {"name": "red", "url": "u"}}],
      "species": {"name": "bulbasaur", "url": "u"},
      "sprites": {
        "front_default": "https://example.com/front.png",
        "back_default": null,
        "front_shiny": null,
        "back_shiny": null,
        "other": {"official-artwork": {"front_default": "https://example.com/official.png"}}
      },
      "cries": {"latest": "https://example.com/cry.ogg", "legacy": null}
    }
    """.utf8)
}
