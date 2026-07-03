//
//  PokdexApp.swift
//  Pokdex
//
//  Created by Benny Reyes on 02/07/26.
//

import SwiftUI

@main
struct PokdexApp: App {
    @State private var container = AppContainer()
    var body: some Scene {
        WindowGroup {
            container.makeHome()
        }
    }
}
