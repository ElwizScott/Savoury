//
//  IngredientSelectionView.swift
//  Savoury
//
//  Created by Kien Le on 27/9/24.
//

import SwiftUI

/// View to display the list of ingredients and trigger the recipe search
struct IngredientSelectionView: View {
    /// Detect light or dark mode
    @Environment(\.colorScheme) var colorScheme
    /// Binding to control the visibility of the screens
    @Binding var showSearchIngredients: Bool
    @Binding var openedFromCameraView: Bool
    
    /// Binding to get ingredients from CameraView
    @Binding var ingredientsFromPhotos: Array<String>
    
    /// Track selected ingredients
    @State private var selectedIngredients: [String] = []
    
    /// Environment value to allow dismissing the view manually (custom back button)
    @Environment(\.dismiss) var dismiss
    
    /// Example ingredients
    @State var availableIngredients = ["Chicken", "Cucumber", "Onion", "Tomato", "Garlic", "Pasta"]
    
    /// Track new ingredient input
    @State private var newIngredient = ""
    
    /// Control visibility of new ingredient input
    @State private var isAddingNewIngredient = false
    
    /// Track if search results should be shown
    @State private var showResults = false

    /// Use the RecipeSearch ViewModel
    @ObservedObject var recipeViewModel = RecipeSearch()
    
    /// Layout configuration for displaying in a grid with flexible columns.
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /// Computed property to determine which ingredients to show
    private var ingredientsToShow: [String] {
        return ingredientsFromPhotos.isEmpty ? availableIngredients : ingredientsFromPhotos
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title
                HStack {
                    Text("Select Ingredients")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                

                // Ingredient selection list
                List {
                    ForEach(ingredientsToShow, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            // Toggle selection
                            Image(systemName: selectedIngredients.contains(ingredient) ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    if selectedIngredients.contains(ingredient) {
                                        selectedIngredients.removeAll { $0 == ingredient }
                                    } else {
                                        selectedIngredients.append(ingredient)
                                    }
                                }
                        }
                    }
                    
                    // "Add ingredients..." button
                    if !isAddingNewIngredient {
                        Button(action: {
                            isAddingNewIngredient = true  // Show input for new ingredient
                        }) {
                            HStack {
                                Text("Add ingredients...")
                                Spacer()
                                Image(systemName: "plus.circle")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    } else {
                        // TextField to input new ingredient
                        HStack {
                            TextField("Enter new ingredient", text: $newIngredient)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 8)
                            
                            // Button to add new ingredient
                            Button(action: {
                                if !newIngredient.isEmpty {
                                    if ingredientsFromPhotos.isEmpty {
                                        availableIngredients.append(newIngredient.capitalized)  // Add to available ingredients if photos are empty
                                    } else {
                                        ingredientsFromPhotos.append(newIngredient.capitalized)  // Add to photo ingredients if they're used
                                    }
                                    newIngredient = ""  // Clear input field
                                }
                                isAddingNewIngredient = false  // Hide input field after adding
                            }) {
                                Text("Add")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.yellow))
                            }
                        }
                    }
                }
                .padding(.top, -10)
                
                HStack {
                    // Show back button if opened from CameraView, else show the home button
                    if openedFromCameraView {
                        Button(action: {
                            dismiss()  // Dismiss the view manually
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 50, height: 50) // Circle size
                                    .shadow(radius: 3)
                                
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    else {
                        Button(action: {
                            showSearchIngredients = false
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 50, height: 50) // Circle size
                                    .shadow(radius: 3)
                                
                                Image(systemName: "house")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    
                    // Button to trigger search
                    Button(action: {
                        recipeViewModel.clearRecipes() // Clear old results
                        recipeViewModel.searchRecipes(forSelectedIngredients: selectedIngredients)
                        showResults = true  // Show results when search is triggered
                    }) {
                        Text("Search Recipes")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Capsule()
                                .fill(Color.yellow)
                                .frame(height: 50)
                                .shadow(radius: 3))
                    }
                    .padding()
                    // Navigate to RecipeResultsView when `showResults` is true
                    .navigationDestination(isPresented: $showResults) {
                        RecipeResultsView(recipes: recipeViewModel.recipes)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

/// New view to display the search results
struct RecipeResultsView: View {
    
    /// Pass the recipes to the new view
    let recipes: [RecipeHit]

    /// Layout configuration for displaying in a grid with flexible columns.
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Search Results")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if !recipes.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(recipes, id: \.id) { recipeHit in
                            ImageDishView(recipe: recipeHit.recipe)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No recipes found. Try different ingredients.")
                    .padding()
            }
        }
    }
}

struct IngredientSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientSelectionView(showSearchIngredients: .constant(true), openedFromCameraView: .constant(false), ingredientsFromPhotos: .constant([]))
    }
}
