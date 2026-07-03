//
//  PokemonDetailRecord.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

/// Codable mirror of `PokemonDetail` used only for local persistence.
/// Keeps the domain entity free of `Codable` (framework-agnostic) while
/// giving the Data layer a stable serialization format it owns.
nonisolated struct PokemonDetailRecord: Codable {
    struct TypeRecord: Codable {
        let slot: Int
        let name: String
    }

    struct AbilityRecord: Codable {
        let name: String
        let isHidden: Bool
        let slot: Int
    }

    struct StatRecord: Codable {
        let name: String
        let baseStat: Int
        let effort: Int
    }

    struct GameIndexRecord: Codable {
        let gameIndex: Int
        let version: String
    }

    struct SpritesRecord: Codable {
        let officialArtwork: String?
        let frontDefault: String?
        let backDefault: String?
        let frontShiny: String?
        let backShiny: String?
    }

    struct CriesRecord: Codable {
        let latest: String?
        let legacy: String?
    }

    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let order: Int
    let isDefault: Bool
    let locationAreaEncounters: String
    let types: [TypeRecord]
    let abilities: [AbilityRecord]
    let stats: [StatRecord]
    let moves: [String]
    let forms: [String]
    let heldItems: [String]
    let gameIndices: [GameIndexRecord]
    let speciesName: String
    let sprites: SpritesRecord
    let cries: CriesRecord

    // MARK: - Domain mapping

    init(from domain: Pokemon) {
        id = domain.id
        name = domain.name
        baseExperience = domain.baseExperience
        height = domain.height
        weight = domain.weight
        order = domain.order
        isDefault = domain.isDefault
        locationAreaEncounters = domain.locationAreaEncounters
        types = domain.types.map { TypeRecord(slot: $0.slot, name: $0.name) }
        abilities = domain.abilities.map { AbilityRecord(name: $0.name, isHidden: $0.isHidden, slot: $0.slot) }
        stats = domain.stats.map { StatRecord(name: $0.name, baseStat: $0.baseStat, effort: $0.effort) }
        moves = domain.moves
        forms = domain.forms
        heldItems = domain.heldItems
        gameIndices = domain.gameIndices.map { GameIndexRecord(gameIndex: $0.gameIndex, version: $0.version) }
        speciesName = domain.species.name
        sprites = SpritesRecord(
            officialArtwork: domain.sprites.officialArtwork?.absoluteString,
            frontDefault: domain.sprites.frontDefault?.absoluteString,
            backDefault: domain.sprites.backDefault?.absoluteString,
            frontShiny: domain.sprites.frontShiny?.absoluteString,
            backShiny: domain.sprites.backShiny?.absoluteString
        )
        cries = CriesRecord(
            latest: domain.cries.latest?.absoluteString,
            legacy: domain.cries.legacy?.absoluteString
        )
    }

    func toDomain() -> Pokemon {
        Pokemon(
            id: id,
            name: name,
            baseExperience: baseExperience,
            height: height,
            weight: weight,
            order: order,
            isDefault: isDefault,
            locationAreaEncounters: locationAreaEncounters,
            types: types.map { PokemonType(slot: $0.slot, name: $0.name) },
            abilities: abilities.map { .init(name: $0.name, isHidden: $0.isHidden, slot: $0.slot) },
            stats: stats.map { .init(name: $0.name, baseStat: $0.baseStat, effort: $0.effort) },
            moves: moves,
            forms: forms,
            heldItems: heldItems,
            gameIndices: gameIndices.map { .init(gameIndex: $0.gameIndex, version: $0.version) },
            species: .init(name: speciesName),
            sprites: .init(
                officialArtwork: sprites.officialArtwork.flatMap(URL.init(string:)),
                frontDefault: sprites.frontDefault.flatMap(URL.init(string:)),
                backDefault: sprites.backDefault.flatMap(URL.init(string:)),
                frontShiny: sprites.frontShiny.flatMap(URL.init(string:)),
                backShiny: sprites.backShiny.flatMap(URL.init(string:))
            ),
            cries: .init(
                latest: cries.latest.flatMap(URL.init(string:)),
                legacy: cries.legacy.flatMap(URL.init(string:))
            )
        )
    }
}
