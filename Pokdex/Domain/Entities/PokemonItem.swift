//
//  PokemonItem.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

// This model will be used to show the principal data of
// each Pokemon in the Home View
struct PokemonItem: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let baseExperience: Int?
    let spriteURL: URL?
}

struct PokemonType: Hashable, Sendable {
    let slot: Int
    let name: String
}
