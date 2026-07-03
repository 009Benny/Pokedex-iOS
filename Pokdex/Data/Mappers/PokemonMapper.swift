//
//  PokemonMapper.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation

enum PokemonMapper {
    static func item(from data: PokemonDetailResponse) -> PokemonItem {
        PokemonItem(
            id: data.id,
            name: data.name,
            types: data.types
                .sorted { $0.slot < $1.slot }
                .map { PokemonType(slot: $0.slot, name: $0.type.name) },
            baseExperience: data.baseExperience,
            spriteURL: data.sprites.frontDefault.flatMap(URL.init(string:))
        )
    }
    
    static func detail(from data: PokemonDetailResponse) -> Pokemon {
        Pokemon(
            id: data.id,
            name: data.name,
            baseExperience: data.baseExperience,
            height: data.height,
            weight: data.weight,
            order: data.order,
            isDefault: data.isDefault,
            locationAreaEncounters: data.locationAreaEncounters,
            types: data.types
                .sorted { $0.slot < $1.slot }
                .map { PokemonType(slot: $0.slot, name: $0.type.name) },
            abilities: data.abilities
                .sorted { $0.slot < $1.slot }
                .map { Pokemon.Ability(name: $0.ability.name, isHidden: $0.isHidden, slot: $0.slot) },
            stats: data.stats.map { Pokemon.Stat(name: $0.stat.name, baseStat: $0.baseStat, effort: $0.effort) },
            moves: data.moves.map(\.move.name),
            forms: data.forms.map(\.name),
            heldItems: data.heldItems.map(\.item.name),
            gameIndices: data.gameIndices.map { Pokemon.GameIndex(gameIndex: $0.gameIndex, version: $0.version.name) },
            species: Pokemon.NamedResource(name: data.species.name),
            sprites: Pokemon.Sprites(
                officialArtwork: data.sprites.other?.officialArtwork?.frontDefault.flatMap(URL.init(string:)),
                frontDefault: data.sprites.frontDefault.flatMap(URL.init(string:)),
                backDefault: data.sprites.backDefault.flatMap(URL.init(string:)),
                frontShiny: data.sprites.frontShiny.flatMap(URL.init(string:)),
                backShiny: data.sprites.backShiny.flatMap(URL.init(string:))
            ),
            cries: Pokemon.Cries(
                latest: data.cries?.latest.flatMap(URL.init(string:)),
                legacy: data.cries?.legacy.flatMap(URL.init(string:))
            )
        )
    }
}
