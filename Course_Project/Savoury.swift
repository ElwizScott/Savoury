//
//  Savoury.swift
//  Savoury
//
//  Created by Kien Le on 24/8/24.
//

// Checked by An 1/9/24

import SwiftUI

/// Main entry point for the Savoury app
@main
struct Savoury: App {
    var body: some Scene {
        WindowGroup {
            UserAuthenticationView()
        }
        .modelContainer(for: AddFavorite.self)
    }
}
