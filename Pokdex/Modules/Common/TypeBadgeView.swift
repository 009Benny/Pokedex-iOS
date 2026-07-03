//
//  TypeBadgeView.swift
//  Pokdex
//
//  Created by Benny Reyes on 03/07/26.
//

import SwiftUI

/// This is the Badge for a type of Pokemon with
/// semantic color by type
struct TypeBadgeView: View {
    let typeName: String

    var body: some View {
        Text(typeName.capitalized)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Self.color(for: typeName)))
    }

    static func color(for type: String) -> Color {
        switch type {
        case "fire": .red
        case "water": .blue
        case "grass": .green
        case "electric": .yellow
        case "psychic": .pink
        case "ice": .cyan
        case "dragon": .indigo
        case "dark": Color(.darkGray)
        case "fairy": Color(red: 0.93, green: 0.6, blue: 0.74)
        case "poison": .purple
        case "ground": .brown
        case "rock": Color(red: 0.72, green: 0.63, blue: 0.42)
        case "bug": Color(red: 0.6, green: 0.73, blue: 0.18)
        case "ghost": Color(red: 0.45, green: 0.34, blue: 0.59)
        case "steel": .gray
        case "fighting": .orange
        case "flying": Color(red: 0.66, green: 0.56, blue: 0.95)
        case "normal": Color(red: 0.66, green: 0.65, blue: 0.48)
        default: .secondary
        }
    }
}
