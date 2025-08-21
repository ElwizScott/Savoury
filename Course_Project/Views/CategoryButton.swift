//
//  CategoryButton.swift
//  Savoury
//
//  Created by Kien Le on 24/8/24.
//

// Checked by An 1/9/24

import SwiftUI

/// A SwiftUI view that represents a button for a specific category.
/// The button displays an icon and the name of the category, and it visually indicates whether the category is selected.
struct CategoryButton: View {
    /// Detect light or dark mode
    @Environment(\.colorScheme) var colorScheme
    
    let category: Category
    var isSelected: Bool
    
    /// Callback when a button is tapped
    var onSelect: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                onSelect()  // Perform the category selection when the button is tapped
            }) {
                Image(systemName: category.categorySymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34) // Size of the flame symbol
                    .padding(30)
                    .foregroundColor(isSelected ? (colorScheme == .dark ? .white : .black) : .gray) // Icon color changes based on selection
                    .background(RoundedRectangle(cornerRadius: 45) // Rounded rectangle with circular radius
                        .fill(isSelected ? Color.yellow : (colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1)))
 // Background color changes when selected
                        .frame(width: 74, height: 84))
            }
            Text(category.categoryName)
                .bold()
                .font(.footnote)
                .foregroundColor(isSelected ? (colorScheme == .dark ? .white : .black) : .gray) // Text color changes based on selection
        }
    }
}


struct CategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        CategoryButton(category: .maindish, isSelected: true, onSelect: {})
    }
}
