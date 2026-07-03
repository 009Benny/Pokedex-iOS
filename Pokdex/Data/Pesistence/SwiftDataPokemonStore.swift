//
//  SwiftDataPokemonStore.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import Foundation
import SwiftData

/// SwiftData-backed implementation of `PokemonLocalDataSource`.
/// `@ModelActor` gives it its own serial executor and `ModelContext`,
/// so all database access is thread-safe by construction.
@ModelActor
actor SwiftDataPokemonStore: PokemonLocalDataSource {
    /// Convenience factory for the production container.
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([CachedPokemonItem.self, CachedPage.self, CachedPokemonDetail.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - Pages

    func page(limit: Int, offset: Int, maxAge: TimeInterval) async -> PokemonPage? {
        guard let meta = fetchPageMeta(offset: offset, limit: limit),
              Date().timeIntervalSince(meta.cachedAt) <= maxAge else {
            return nil
        }

        let ids = meta.itemIDs
        let descriptor = FetchDescriptor<CachedPokemonItem>(
            predicate: #Predicate { ids.contains($0.pokemonID) },
            sortBy: [SortDescriptor(\.listIndex)]
        )
        guard let summaries = try? modelContext.fetch(descriptor),
              summaries.count == ids.count else {
            return nil // incomplete cache: treat as a miss
        }

        return PokemonPage(
            items: summaries.map { cached in
                PokemonItem(
                    id: cached.pokemonID,
                    name: cached.name,
                    types: cached.typeNames.enumerated().map { PokemonType(slot: $0.offset + 1, name: $0.element) },
                    baseExperience: cached.baseExperience,
                    spriteURL: cached.spriteURLString.flatMap(URL.init(string:))
                )
            },
            totalCount: meta.totalCount,
            hasMore: meta.hasMore
        )
    }

    func savePage(_ page: PokemonPage, offset: Int) async {
        // @Attribute(.unique) turns these inserts into upserts on save.
        for (index, item) in page.items.enumerated() {
            modelContext.insert(CachedPokemonItem(
                pokemonID: item.id,
                name: item.name,
                typeNames: item.types.sorted { $0.slot < $1.slot }.map(\.name),
                baseExperience: item.baseExperience,
                spriteURLString: item.spriteURL?.absoluteString,
                listIndex: offset + index
            ))
        }
        modelContext.insert(CachedPage(
            offset: offset,
            limit: page.items.count,
            totalCount: page.totalCount,
            hasMore: page.hasMore,
            itemIDs: page.items.map(\.id),
            cachedAt: Date()
        ))
        try? modelContext.save()
    }

    // MARK: - Detail

    func detail(id: Int, maxAge: TimeInterval) async -> Pokemon? {
        var descriptor = FetchDescriptor<CachedPokemonDetail>(
            predicate: #Predicate { $0.pokemonID == id }
        )
        descriptor.fetchLimit = 1
        guard let cached = try? modelContext.fetch(descriptor).first,
              Date().timeIntervalSince(cached.cachedAt) <= maxAge,
              let record = try? JSONDecoder().decode(PokemonDetailRecord.self, from: cached.payload) else {
            return nil
        }
        return record.toDomain()
    }

    func saveDetail(_ detail: Pokemon) async {
        guard let payload = try? JSONEncoder().encode(PokemonDetailRecord(from: detail)) else { return }
        modelContext.insert(CachedPokemonDetail(pokemonID: detail.id, payload: payload, cachedAt: Date()))
        try? modelContext.save()
    }

    // MARK: - Private

    private func fetchPageMeta(offset: Int, limit: Int) -> CachedPage? {
        var descriptor = FetchDescriptor<CachedPage>(
            predicate: #Predicate { $0.offset == offset && $0.limit == limit }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}

