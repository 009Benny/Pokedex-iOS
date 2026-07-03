//
//  Untitled.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import SwiftUI

struct PokemonRowItem: View {
    let pokemon: PokemonItem
    
    var body: some View {
        HStack(spacing: 12) {
            
            AsyncImage(url: pokemon.spriteURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "circle.dashed")
                    .foregroundStyle(.tertiary)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                Text(pokemon.name.capitalized)
                    .font(.headline)

                HStack(spacing: 6) {
                    ForEach(pokemon.types, id: \.slot) { type in
                        TypeBadgeView(typeName: type.name)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(pokemon.baseExperience.map(String.init) ?? "—")")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                Text("base exp")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
