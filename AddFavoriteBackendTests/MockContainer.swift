//
//  MockContainer.swift
//  AddFavoriteBackendTests
//
//  Created by An Luu on 6/10/24.
//

import Foundation
import SwiftData

@MainActor
var MockContainer: ModelContainer {
    do {
        let container = try ModelContainer(
            for: AddFavorite.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    } catch {
        fatalError("Failed to create container.")
    }
}
