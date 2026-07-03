//
//  CachedModels.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import SwiftData

/// This models are created like crud data, they never cross into Domain or Views

/// /// One Pokémon of the list, denormalized for the Home cells.
@Model
final class CachedPokemonItem {
    @Attribute(.unique) var pokemonID: Int
    var name: String
    var typeNames: [String]
    var baseExperience: Int?
    var spriteURLString: String?
    var listIndex: Int
    
    init(pokemonID: Int, name: String, typeNames: [String], baseExperience: Int? = nil, spriteURLString: String? = nil, listIndex: Int) {
        self.pokemonID = pokemonID
        self.name = name
        self.typeNames = typeNames
        self.baseExperience = baseExperience
        self.spriteURLString = spriteURLString
        self.listIndex = listIndex
    }
}

/// Metadata of a cached page: which ids it contains and when it was fetched (TTL).
@Model
final class CachedPage {
    @Attribute(.unique) var offset: Int
    var limit: Int
    var totalCount: Int
    var hasMore: Bool
    var itemIDs: [Int]
    var cachedAt: Date

    init(offset: Int, limit: Int, totalCount: Int, hasMore: Bool, itemIDs: [Int], cachedAt: Date) {
        self.offset = offset
        self.limit = limit
        self.totalCount = totalCount
        self.hasMore = hasMore
        self.itemIDs = itemIDs
        self.cachedAt = cachedAt
    }
}

/// Full detail stored as an encoded `PokemonDetailRecord` payload.
/// A single blob avoids a dozen @Model classes for nested collections
/// that are never queried individually.
@Model
final class CachedPokemonDetail {
    @Attribute(.unique) var pokemonID: Int
    var payload: Data
    var cachedAt: Date

    init(pokemonID: Int, payload: Data, cachedAt: Date) {
        self.pokemonID = pokemonID
        self.payload = payload
        self.cachedAt = cachedAt
    }
}
