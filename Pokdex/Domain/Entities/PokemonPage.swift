//
//  PokemonPage.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

/// This entity will be user to request a chunk of 20 items
/// in the Home View
struct PokemonPage: Sendable, Equatable {
    let items: [PokemonItem]
    let totalCount: Int
    let hasMore: Bool
}
