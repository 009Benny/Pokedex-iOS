//
//  RemotePokemonRepository.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import Foundation

/// The Pokie API have a enpoint 'https://pokeapi.co/api/v2/pokemon' that only return the
/// ' name ' and ' url '. So this repository have the responsabilirty to fill the necesary data to each item.
/// For this reason we request each detail  in parralel (TaskGroup). The domain receive a complete
/// ´PokemonPage´
struct RemotePokemonRepository: PokemonRepository {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchPage(limit: Int, offset: Int) async throws -> PokemonPage {
        let list: PokemonPageResponse = try await fetch(.pokemonList(limit: limit, offset: offset))
        
        let details = try await withThrowingTaskGroup(
            of: (Int, PokemonDetailResponse).self)
        { group in
            for (index, item) in list.results.enumerated() {
                guard let url = URL(string: item.url),
                      let id = Int(url.lastPathComponent)
                else { continue }
                group.addTask {
                    (index, try await fetch(.pokemonDetail(id: id)))
                }
            }
            var collected: [(Int, PokemonDetailResponse)] = []
            collected.reserveCapacity(list.results.count)
            for try await result in group {
                collected.append(result)
            }
            return collected
                .sorted { $0.0 < $1.0 }
                .map(\.1)
        }
        
        return PokemonPage(
            items: details.map(PokemonMapper.item(from:)),
            totalCount: list.count,
            hasMore: list.next != nil
        )
    }
    
    func fetchDetail(id: Int) async throws -> Pokemon {
        PokemonMapper.detail(from: try await fetch(.pokemonDetail(id: id)))
    }
    
    private func fetch<T: Decodable>(_ endpoint: PokeAPIEndpoint) async throws -> T {
        let data = try await client.data(from: endpoint.url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error.localizedDescription)
        }
    }
    
    
}
