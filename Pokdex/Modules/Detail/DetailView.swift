//
//  DetailView.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import SwiftUI

struct DetailView: View {
    
    @State private var viewModel: DetailViewModel
    @State private var showAllMoves = false
    
    
    init(viewModel: DetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Cargando detalle…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                ContentUnavailableView {
                    Label("No se pudo cargar", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Reintentar") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .loaded(let detail):
                loadedContent(detail)
            }
        }
        .navigationTitle(viewModel.item.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task { await viewModel.load() }
    }
    
    private func loadedContent(_ detail: Pokemon) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                header(detail)
                basicInfoCard(detail)
                typesCard(detail)
                abilitiesCard(detail)
                statsCard(detail)
                spritesCard(detail)
                movesCard(detail)
                if !detail.forms.isEmpty { formsCard(detail) }
                if !detail.heldItems.isEmpty { heldItemsCard(detail) }
                if !detail.gameIndices.isEmpty { gameIndicesCard(detail) }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    private func header(_ detail: Pokemon) -> some View {
        VStack(spacing: 8) {
            AsyncImage(url: detail.sprites.primaryImage) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 220)

            Text("#\(String(format: "%03d", detail.id))  \(detail.name.capitalized)")
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity)
    }

    private func basicInfoCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Información básica") {
            InfoRow(label: "Experiencia base", value: detail.baseExperience.map(String.init) ?? "—")
            InfoRow(label: "Altura", value: String(format: "%.1f m", Double(detail.height) / 10))
            InfoRow(label: "Peso", value: String(format: "%.1f kg", Double(detail.weight) / 10))
            InfoRow(label: "Orden", value: "\(detail.order)")
            InfoRow(label: "Forma por defecto", value: detail.isDefault ? "Sí" : "No")
            InfoRow(label: "Especie", value: detail.species.name.capitalized)
        }
    }

    private func typesCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Tipos") {
            HStack(spacing: 8) {
                ForEach(detail.types, id: \.slot) { type in
                    TypeBadgeView(typeName: type.name)
                }
            }
        }
    }

    private func abilitiesCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Habilidades") {
            ForEach(detail.abilities, id: \.slot) { ability in
                HStack {
                    Text(ability.name.replacingOccurrences(of: "-", with: " ").capitalized)
                        .font(.subheadline.weight(.medium))
                    if ability.isHidden {
                        Text("Oculta")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.secondary.opacity(0.2)))
                    }
                    Spacer()
                    Text("Slot \(ability.slot)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statsCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Estadísticas") {
            ForEach(detail.stats, id: \.name) { stat in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(.subheadline)
                        Spacer()
                        Text("\(stat.baseStat)")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    ProgressView(value: Double(stat.baseStat), total: 255)
                        .tint(stat.baseStat > 90 ? .green : stat.baseStat > 50 ? .orange : .red)
                }
            }
            InfoRow(label: "Total", value: "\(detail.stats.map(\.baseStat).reduce(0, +))")
        }
    }

    private func spritesCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Sprites") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    spriteThumb(detail.sprites.frontDefault, label: "Frente")
                    spriteThumb(detail.sprites.backDefault, label: "Espalda")
                    spriteThumb(detail.sprites.frontShiny, label: "Shiny")
                    spriteThumb(detail.sprites.backShiny, label: "Shiny espalda")
                }
            }
        }
    }

    @ViewBuilder
    private func spriteThumb(_ url: URL?, label: String) -> some View {
        if let url {
            VStack(spacing: 4) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 72, height: 72)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func movesCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Movimientos (\(detail.moves.count))") {
            let visible = showAllMoves ? detail.moves : Array(detail.moves.prefix(12))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                ForEach(visible, id: \.self) { move in
                    Text(move.replacingOccurrences(of: "-", with: " ").capitalized)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(Color.secondary.opacity(0.15)))
                }
            }
            if detail.moves.count > 12 {
                Button(showAllMoves ? "Mostrar menos" : "Mostrar todos") {
                    withAnimation { showAllMoves.toggle() }
                }
                .font(.subheadline)
            }
        }
    }

    private func formsCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Formas") {
            ForEach(detail.forms, id: \.self) { form in
                Text(form.capitalized)
                    .font(.subheadline)
            }
        }
    }

    private func heldItemsCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Objetos equipados") {
            ForEach(detail.heldItems, id: \.self) { item in
                Text(item.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(.subheadline)
            }
        }
    }

    private func gameIndicesCard(_ detail: Pokemon) -> some View {
        InfoCard(title: "Apariciones en juegos (\(detail.gameIndices.count))") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                ForEach(detail.gameIndices, id: \.version) { index in
                    Text(index.version.replacingOccurrences(of: "-", with: " ").capitalized)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(Color.secondary.opacity(0.15)))
                }
            }
        }
    }
}
