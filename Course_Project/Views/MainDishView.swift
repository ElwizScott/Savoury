//
//  MainDishView.swift
//  Savoury
//
//  Created by Elwiz Scott on 1/10/24.
//

import SwiftUI

struct MainDishView: View {
    
    /// Observing the RecipeSearch ViewModel
    @ObservedObject var recipeSearch = RecipeSearch()

    /// Layout configuration for displaying dishes in a grid with flexible columns.
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
                    // Loop through fetched recipes and display each recipe using ImageDishView
                    ForEach(recipeSearch.recipes, id: \.id) { recipeHit in
                        ImageDishView(recipe: recipeHit.recipe)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Fetch recipes when the view appears
                recipeSearch.fetchMainDish()
            }
        }
    }
}

struct MainDishView_Previews: PreviewProvider {
    static var previews: some View {
        MainDishView(recipeSearch: RecipeSearch())  // Use an instance of RecipeSearch for the preview
    }
}
