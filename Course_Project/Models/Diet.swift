//
//  Diet.swift
//  Savoury
//
//  Created by An Luu on 26/9/24.
//

import Foundation

///  Defines enums for dietary preferences and allergies used in the Savoury app.
///  - Diet: Covers diets such as Vegan, Keto, and others, providing clear labels for UI display.
enum Diet: CaseIterable, CustomStringConvertible {
    case lowCarb, lowSodium, lowFat, highProtein, highFiber, balanced

    var description: String {
        switch self {
        case .lowCarb:
            return "Low Carb"
        case .lowSodium:
            return "Low Sodium"
        case .lowFat:
            return "Low Fat"
        case .highProtein:
            return "High Protein"
        case .highFiber:
            return "High Fiber"
        case .balanced:
            return "Balanced"
        }
    }
    
    var apiValue: String {
        switch self {
        case .lowCarb:
            return "low-carb"
        case .lowSodium:
            return "low-sodium"
        case .lowFat:
            return "low-fat"
        case .highProtein:
            return "high-protein"
        case .highFiber:
            return "high-fiber"
        case .balanced:
            return "balanced"
        }
    }
}

