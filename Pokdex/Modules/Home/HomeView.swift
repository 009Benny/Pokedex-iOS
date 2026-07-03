//
//  HomeView.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import SwiftUI

/// This view will show a list of Pokemons
/// Whem the user select a pokemon will display a detail
/// If the user scroll until the last pokemon we will request the next page
/// of 20 Pokemons
struct HomeView: View {
    
    @State private var viewModel: HomeViewModel
    private let detailView: (PokemonItem) -> DetailView
    
    init(
        viewModel: HomeViewModel,
        detailView: @escaping @MainActor (PokemonItem) -> DetailView
    ) {
        _viewModel = State(initialValue: viewModel)
        self.detailView = detailView
    }
    
    var body: some View {
        NavigationStack{
            content
                .navigationTitle("Pokedex")
                .navigationDestination(for: PokemonItem.self) { item in
                    detailView(item)
                }
        }
        .task {
            await viewModel.loadInitialIfNeeded()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingInitial {
            ProgressView("Loading Pokemon List...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView{
                Text("Something went wrong")
            } description: {
                Text(error)
            } actions: {
                Button("Reintentar") {
                    Task { await viewModel.loadInitialIfNeeded()}
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            list
        }
    }
    
    @ViewBuilder
    private var list: some View {
        List{
            ForEach(viewModel.items) { pokemon in
                NavigationLink(value: pokemon) {
                    PokemonRowItem(pokemon: pokemon)
                }
                .onAppear{
                    Task { await viewModel.loadMoreIfNeeded(currentItem: pokemon) }
                }
            }
            
            if viewModel.isLoadingMore {
                HStack{
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.automatic)
        .refreshable { await viewModel.loadInitialIfNeeded() }
    }
}
