//
//  Pokemon.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//
import Foundation

/// This model contains all the properties that will be used in the View
struct Pokemon: Equatable, Sendable {
    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let order: Int
    let isDefault: Bool
    let locationAreaEncounters: String

    let types: [PokemonType]
    let abilities: [Ability]
    let stats: [Stat]
    let moves: [String]
    let forms: [String]
    let heldItems: [String]
    let gameIndices: [GameIndex]
    let species: NamedResource
    let sprites: Sprites
    let cries: Cries

    struct Ability: Equatable, Sendable {
        let name: String
        let isHidden: Bool
        let slot: Int
    }

    struct Stat: Equatable, Sendable {
        let name: String
        let baseStat: Int
        let effort: Int
    }

    struct GameIndex: Equatable, Sendable {
        let gameIndex: Int
        let version: String
    }

    struct NamedResource: Equatable, Sendable {
        let name: String
    }

    struct Sprites: Equatable, Sendable {
        let officialArtwork: URL?
        let frontDefault: URL?
        let backDefault: URL?
        let frontShiny: URL?
        let backShiny: URL?

        /// Some items don't have oficial artwork so we will display the default image
        var primaryImage: URL? { officialArtwork ?? frontDefault }
    }

    struct Cries: Equatable, Sendable {
        let latest: URL?
        let legacy: URL?
    }
}
