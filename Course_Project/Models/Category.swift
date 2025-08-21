//
//  Category.swift
//  Savoury
//
//  Created by Kien Le on 24/8/24.
//

// Checked by An Luu 1/9/24

import Foundation


/// Enum representing different categories used within the application.
/// Each case corresponds to a specific type of category, such as popular items, recently added items, desserts, and main dishes.
enum Category {
    case maindish, salad, dessert, drinks
    
    var categoryName: String {
        switch self {
        case .maindish:
            return "Main Dishes"
        case .salad:
            return "Salad"
        case .dessert:
            return "Dessert"
        case .drinks:
            return "Drinks"
        }
    }
    
    /// SF-Symbol to return the system symbol name associated with each case.
    var categorySymbol: String {
        switch self {
        case .maindish:
            return "fork.knife"
        case .salad:
            return "leaf.fill"
        case .dessert:
            return "popcorn.fill"
        case .drinks:
            return "cup.and.saucer.fill"
        }
    }
    
    static var allItems: [Category] {
        return [.maindish, .salad, .dessert, .drinks]
    }
}
