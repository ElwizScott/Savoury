//
//  RecipeDetailView.swift
//  Savoury
//
//  Created by Kien Le on 27/9/24.
//

import SwiftUI
import UIKit
import SwiftData

/// A view that displays detailed information about a recipe, including images, descriptions, and interactive elements.
struct RecipeDetailView: View {
    
    /// State variable to manage whether a recipe is marked as favorite.
    @State var isFavorite: Bool
    
    /// Access to the model context for database operations.
    @Environment(\.modelContext) private var modelContext
    
    /// Query to fetch favorite recipes.
    @Query var addFavorite: [AddFavorite]
    
    /// Constant that stores the recipe being detailed.
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    // Recipe Image
                    if let imageUrl = URL(string: recipe.image) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .padding(.vertical, 30)
                                .frame(width: UIScreen.main.bounds.width, height: 300)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // Button to toggle favorite status.
                    Button(action: {
                        // Action for the save or bookmark functionality
                        if isFavorite {
                            // Find the existing favorite and delete it
                            if let favoriteItem = addFavorite.first(where: { $0.dish == recipe.label }) {
                                modelContext.delete(favoriteItem)
                                try? modelContext.save()  // Commit the changes
                                isFavorite = false
                            }
                        } else {
                            // Add a new favorite
                            let newFavorite = AddFavorite(Recipe: recipe.label, RecipeID: recipe.uri)
                            modelContext.insert(newFavorite)
                            try? modelContext.save()  // Commit the changes
                            isFavorite = true
                        }
                        
                        // just to test but right now it is some how only printing one dish
                        for favorite in addFavorite {
                            print("Favorite dish: \(favorite.dish)")
                            print("Favorite uri: \(favorite.recipeID)")
                        }
                    }) {
                        // this for the save button
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .shadow(radius: 4)
                            if isFavorite {
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "bookmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    .padding(.leading, 300)
                    .padding(.bottom, 200)
                }
                
                // Recipe Title
                HStack {
                    Text(recipe.label)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                if let cuisineType = recipe.cuisineType, !cuisineType.isEmpty {
                    Text("\(cuisineType.joined(separator: ", "))")
                        .font(.title3)
                        .padding(.horizontal)
                        .padding(.top, -10)
                        .foregroundColor(.gray)
                }

                // Capsules for Total Time, Servings, Calories, Total Weight
                HStack {
                    HStack {
                        Spacer()

                        // Capsule for Total Time
                        if let totalTime = recipe.totalTime {
                            ZStack {
                                Capsule()
                                    .frame(width: 70, height: 120)
                                    .foregroundColor(.yellow)
                                VStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .padding(.top, -10)
                                        .padding(.bottom, 5)
                                        .overlay(
                                            Image(systemName: "clock")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.black)
                                                .padding(.top, -15)
                                        )
                                    Text("\(Int(totalTime))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("mins")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        Spacer()

                        // Capsule for Servings
                        if let yield = recipe.yield {
                            ZStack {
                                Capsule()
                                    .frame(width: 70, height: 120)
                                    .foregroundColor(.yellow)
                                VStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .padding(.top, -10)
                                        .padding(.bottom, 5)
                                        .overlay(
                                            Image(systemName: "person.2.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.black)
                                                .padding(.top, -15)
                                        )
                                    Text("\(Int(yield))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Servings")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        Spacer()

                        // Capsule for Calories
                        if let calories = recipe.calories {
                            ZStack {
                                Capsule()
                                    .frame(width: 70, height: 120)
                                    .foregroundColor(.yellow)
                                VStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .padding(.top, -10)
                                        .padding(.bottom, 5)
                                        .overlay(
                                            Image(systemName: "flame.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.black)
                                                .padding(.top, -15)
                                        )
                                    Text("\(Int(calories))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Cal")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        Spacer()

                        // Capsule for Total Weight
                        if let totalWeight = recipe.totalWeight {
                            ZStack {
                                Capsule()
                                    .frame(width: 70, height: 120)
                                    .foregroundColor(.yellow)
                                VStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .padding(.top, -10)
                                        .padding(.bottom, 5)
                                        .overlay(
                                            Image(systemName: "square.stack.3d.up.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.black)
                                                .padding(.top, -15)
                                        )
                                    Text("\(Int(totalWeight))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Gram")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        Spacer()
                    }
                }
                .padding()
                
                // Ingredients
                if let ingredients = recipe.ingredients {
                    Text("Ingredients")
                        .font(.system(.title3, weight: .bold))
                        .padding(.horizontal)
                    
                    ForEach(ingredients, id: \.food) { ingredient in
                        HStack {
                            Text("•")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                                .padding(.leading)
                            Text("\(ingredient.food)")
                                .font(.body)
                        }
                        .padding(.vertical, -10)
                        
                    }
                }
                
                Spacer()

                // Optional additional sections (Cautions, Cuisine Type, etc.)
                if let cautions = recipe.cautions, !cautions.isEmpty {
                    Text("Cautions: \(cautions.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                if let mealType = recipe.mealType, !mealType.isEmpty {
                    Text("Meal Type: \(mealType.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                if let dishType = recipe.dishType, !dishType.isEmpty {
                    Text("Dish Type: \(dishType.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                if let url = recipe.url {
                    Text("View Recipe Instructions")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                        .padding(.horizontal)
                        .onTapGesture {
                            // Add print statement or visual feedback for debugging
                            print("Link tapped: \(url)")
                            
                            // Open the link in the default browser
                            if let recipeURL = URL(string: url) {
                                UIApplication.shared.open(recipeURL)
                            }
                        }
                }

            }
            .navigationBarTitle("Recipe Details", displayMode: .inline)
        }
        .onAppear {
            // Use a regular `for` loop for logic
            for addFavoriteItem in addFavorite {
                if addFavoriteItem.dish == recipe.label {
                    isFavorite = true
                    return // Exit the loop as we found a favorite match
                }
            }
            isFavorite = false // If no match found, set to false
        }
    }
}



/// View to show each capsule for the recipe details
struct RecipeDetailCapsule: View {
    var iconName: String
    var label: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.yellow)
            Text(label)
                .font(.footnote)
                .bold()
        }
        .padding(12)
        .background(Capsule().fill(Color.yellow.opacity(0.2)))
    }
}

// Preview
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(
            isFavorite: true, recipe: Recipe(
                uri: "123",
                label: "Spaghetti Carbonara",
                image: "https://www.allrecipes.com/thmb/ewSWaXqsw97lWyAWek_u9fguJ3g=/0x512/filters:no_upscale():max_bytes(150000):strip_icc()/Easyspaghettiwithtomatosauce_11715_DDMFS_4x3_2424-8d7bf30b2622465f9dd78a2c6277eeb8.jpg",
                yield: 4,
                calories: 500,
                totalWeight: 800,
                totalTime: 25,
                cautions: ["Gluten", "Dairy"],
                ingredients: [
                    Ingredient(food: "Spaghetti"),
                    Ingredient(food: "Bacon"),
                    Ingredient(food: "Egg"),
                    Ingredient(food: "Parmesan cheese"),
                    Ingredient(food: "Black pepper")
                ],
                cuisineType: ["Italian"],
                mealType: ["Lunch", "Dinner"],
                dishType: ["Main course"], 
                url: "https://honestcooking.com/spring-strawberry-pea-salad-chicken/"
            )
        )
        .modelContainer(for: AddFavorite.self)
    }
}
