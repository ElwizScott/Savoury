//
//  RecipeCategoryView.swift
//  Savoury
//
//  Created by Kien Le on 4/10/24.
//

import SwiftUI

/// View to display a grid of dishes for a selected recipe category
struct RecipeCategoryView: View {
    
    /// Observed object to manage and update recipe search results
    @ObservedObject var recipeSearch: RecipeSearch
    
    /// Binding variable to track the currently selected category
    @Binding var selectedCategory: Category
    
    
    /// Defines the layout of the grid with two flexible columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Top dishes of the day")
                    .font(.title)
                    .fontWeight(.black)
                    .padding()
                Spacer()
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(recipeSearch.recipes, id: \.id) { recipeHit in
                        ImageDishView(recipe: recipeHit.recipe)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Fetch recipes for the selected category when the view appears
                recipeSearch.clearRecipes()
                recipeSearch.fetchRecipes(for: selectedCategory)
            }
            .onChange(of: selectedCategory) {
                // Fetch recipes whenever the selected category changes
                recipeSearch.clearRecipes()
                recipeSearch.fetchRecipes(for: selectedCategory)
            }
        }
    }
}
