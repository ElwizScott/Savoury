//
//  FavoriteView.swift
//  Savoury
//
//  Created by Kien Le on 6/10/24.
//

import SwiftUI
import SwiftData


/// View to display the user's favorite recipes
struct FavoriteView: View {
    /// Detect light or dark mode
    @Environment(\.colorScheme) var colorScheme
    
    /// Binding to control the visibility of the favorite view
    @Binding var showFavoriteView: Bool
    
    /// Observed object to manage the search and fetch of recipes
    @ObservedObject var recipeSearch = RecipeSearch()
    
    /// Assuming AddFavorite contains saved URIs. Query to fetch favorite recipes saved by their URIs
    @Query var addFavorites: [AddFavorite]

    /// Defines the layout of the grid with two flexible columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            /// Adapt the background color based on the system's color scheme
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            VStack {
                // Top navigation bar
                HStack {
                    Button(action: {
                        showFavoriteView = false  // Hide TimerScreen
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                            .bold()
                            .padding()
                            .background(Circle()
                                .fill(Color.yellow)
                                .shadow(radius: 4))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                
                HStack {
                    Text("Your Favorite Recipes")
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
                    // Fetch the saved recipes by URI when the view appears
                    let savedURIs = addFavorites.map { $0.recipeID }
                    recipeSearch.fetchRecipesByURI(savedURIs)
                }
            }
        }
        
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView(showFavoriteView: .constant(true))
    }
}
