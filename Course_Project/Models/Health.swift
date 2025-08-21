//
//  Health.swift
//  Savoury
//
//  Created by An Luu on 26/9/24.
//

import Foundation


///  Defines enums for dietary preferences and allergies used in the Savoury app.
///  - Health: Includes categories like Dairy Free, Gluten Free, etc., each with a descriptive label.
enum Health: CaseIterable, CustomStringConvertible {
    case dairyFree, glutenFree, peanutFree, shellfishFree, ketoFriendly, vegan, vegetarian, sulfiteFree, porkFree

    var description: String {
        switch self {
        case .dairyFree:
            return "Dairy Free"
        case .glutenFree:
            return "Gluten Free"
        case .peanutFree:
            return "Peanut Free"
        case .shellfishFree:
            return "Shellfish Free"
        case .ketoFriendly:
            return "Keto Friendly"
        case .vegan:
            return "Vegan"
        case .vegetarian:
            return "Vegetarian"
        case .sulfiteFree:
            return "Sulfite Free"
        case .porkFree:
            return "Pork Free"
        }
    }
    
    var apiValue: String {
        switch self {
        case .dairyFree:
            return "dairy-free"
        case .glutenFree:
            return "gluten-free"
        case .peanutFree:
            return "peanut-free"
        case .shellfishFree:
            return "shellfish-free"
        case .ketoFriendly:
            return "keto-friendly"
        case .vegan:
            return "vegan"
        case .vegetarian:
            return "vegetarian"
        case .sulfiteFree:
            return "sulfite-free"
        case .porkFree:
            return "pork-free"
        }
    }
}

