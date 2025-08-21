//
//  CategoryTabView.swift
//  Savoury
//
//  Created by Kien Le on 27/8/24.
//

// Checked by An 1/9/24

import SwiftUI

/// A SwiftUI view that displays a horizontal scrollable list of category buttons.
/// Users can select a category by tapping on one of the buttons, and the selected category will be highlighted. But for now the default value is "popular" case
struct CategoryTab: View {
    @Binding var selectedCategory: Category
    @ObservedObject var recipeSearch: RecipeSearch
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Category.allItems, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        onSelect: {
                            selectedCategory = category  // Update the selected category when tapped
                        }
                    )
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
            }
        }
        .padding(.leading, 2)
    }
}

struct CategoryTab_Previews: PreviewProvider {
    static var previews: some View {
        CategoryTab(selectedCategory: .constant(.maindish), recipeSearch: RecipeSearch())
    }
}
