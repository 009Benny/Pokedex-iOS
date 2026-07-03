//
//  PokemonDetailResponse.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

/// Response of the request `GET /pokemon/{id}`
/// The `snake_case` is resolved by the CodingKeys enums
nonisolated struct PokemonDetailResponse: Decodable {
    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let order: Int
    let isDefault: Bool
    let locationAreaEncounters: String
    let types: [TypeSlot]
    let abilities: [AbilitySlot]
    let stats: [Stat]
    let moves: [MoveSlot]
    let forms: [NamedResource]
    let heldItems: [HeldItem]
    let gameIndices: [GameIndex]
    let species: NamedResource
    let sprites: Sprites
    let cries: Cries?

    enum CodingKeys: String, CodingKey {
        case id, name, height, weight, order, types, abilities, stats, moves, forms, species, sprites, cries
        case baseExperience = "base_experience"
        case isDefault = "is_default"
        case locationAreaEncounters = "location_area_encounters"
        case heldItems = "held_items"
        case gameIndices = "game_indices"
    }
    
    struct NamedResource: Decodable {
        let name: String
        let url: String
    }

    struct TypeSlot: Decodable {
        let slot: Int
        let type: NamedResource
    }

    struct AbilitySlot: Decodable {
        let ability: NamedResource
        let isHidden: Bool
        let slot: Int

        enum CodingKeys: String, CodingKey {
            case ability, slot
            case isHidden = "is_hidden"
        }
    }

    struct Stat: Decodable {
        let baseStat: Int
        let effort: Int
        let stat: NamedResource

        enum CodingKeys: String, CodingKey {
            case effort, stat
            case baseStat = "base_stat"
        }
    }

    struct MoveSlot: Decodable {
        let move: NamedResource
    }

    struct HeldItem: Decodable {
        let item: NamedResource
    }

    struct GameIndex: Decodable {
        let gameIndex: Int
        let version: NamedResource

        enum CodingKeys: String, CodingKey {
            case version
            case gameIndex = "game_index"
        }
    }

    struct Sprites: Decodable {
        let frontDefault: String?
        let backDefault: String?
        let frontShiny: String?
        let backShiny: String?
        let other: OtherSprites?

        enum CodingKeys: String, CodingKey {
            case other
            case frontDefault = "front_default"
            case backDefault = "back_default"
            case frontShiny = "front_shiny"
            case backShiny = "back_shiny"
        }

        struct OtherSprites: Decodable {
            let officialArtwork: Artwork?

            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }

            struct Artwork: Decodable {
                let frontDefault: String?

                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
        }
    }

    struct Cries: Decodable {
        let latest: String?
        let legacy: String?
    }
}


