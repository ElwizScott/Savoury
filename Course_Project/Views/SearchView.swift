//
//  SearchView.swift
//  Savoury
//
//  Created by Kien Le on 26/9/24.
//

import SwiftUI

/// View to handle the search functionality for recipes
struct SearchView: View {
    
    /// Binding to control the visibility of the screens
    @Binding var showSearchByNameView: Bool
    
    /// Environment value to allow dismissing the view manually (custom back button)
    @Environment(\.dismiss) var dismiss
    
    /// New state for search query
    @State private var searchQuery: String = ""
    
    /// ViewModel to fetch recipes based on search query
    @ObservedObject var recipeViewModel = RecipeSearch()
    
    /// Filtered recipes based on the search query
    var filteredRecipes: [RecipeHit] {
        if searchQuery.isEmpty {
            return recipeViewModel.recipes
        } else {
            return recipeViewModel.recipes.filter { $0.recipe.label.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    /// For grid layout similar to home screen
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // ScrollView with LazyVGrid for a grid layout
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredRecipes, id: \.id) { recipeHit in
                                ImageDishView(recipe: recipeHit.recipe)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .searchable(text: $searchQuery, prompt: "Search recipes") // Add searchable to the ScrollView
                    .navigationTitle("Search Recipes") // Navigation title for the screen
                    .onSubmit(of: .search) {
                        recipeViewModel.searchRecipes(for: searchQuery) // Perform search when submitting
                    }
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    showSearchByNameView = false
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 60, height: 60) // Circle size
                            .shadow(radius: 3)
                        
                        Image(systemName: "house")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
            }
            .padding(.top, 700)
            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(showSearchByNameView: .constant(true))
    }
}

