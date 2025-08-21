//
//  Tab.swift
//  Savoury
//
//  Created by An Luu on 1/9/24.
//

// Checked by An 1/9/24

import Foundation

/// An enum representing the different tabs available in the application.
/// Each case corresponds to a specific tab, such as home, bookmark, camera, cooking, and timer.
enum Tab: String, CaseIterable {
    case home
    case bookmark
    case camera
    case cooking
    case timer
    
    /// SF-Symbol to return the system symbol name associated with each case.
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .bookmark:
            return "bookmark"
        case .camera:
            return "camera"
        case .cooking:
            return "frying.pan"
        case .timer:
            return "timer"
        }
    }
}
