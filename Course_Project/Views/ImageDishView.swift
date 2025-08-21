//
//  DishImageView.swift
//  Savoury
//
//  Created by Kien Le on 26/9/24.
//

import SwiftUI

/// View to display a dish image along with its recipe details
struct ImageDishView: View {
    
    /// Holds the recipe data passed to this view.
    var recipe: Recipe
    
    /// State to show the detail view
    @State private var showDetailView = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                Button(action: {
                    showDetailView = true  // Navigate to the detail view
                }) {
                    if let imageUrl = URL(string: recipe.image) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 160)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()  // Show loading spinner while the image is being fetched
                        }
                    }
                }
                
                // Total Time with gray opacity background
                if let totalTime = recipe.totalTime {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.trailing, -4)
                        Text("\(Int(totalTime)) mins")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(20)
                    .padding([.top, .leading], 10)
                }
            }
            
            // Label and Cuisine Type
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.label)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)  // Truncate label if too long
                
                if let cuisineType = recipe.cuisineType?.first {
                    Text(cuisineType)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 4)  // Add padding above text
        }
        .frame(width: 160, height: 200)  // Adjust frame to fit in the grid
        .sheet(isPresented: $showDetailView) {
            RecipeDetailView(isFavorite: true, recipe: recipe)  // Show detail view modally
        }
    }
}

struct ImageDishView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDishView(
            recipe: Recipe(
                uri: "",
                label: "Spaghetti Carbonara",
                image: "https://www.allrecipes.com/thmb/ewSWaXqsw97lWyAWek_u9fguJ3g=/0x512/filters:no_upscale():max_bytes(150000):strip_icc()/Easyspaghettiwithtomatosauce_11715_DDMFS_4x3_2424-8d7bf30b2622465f9dd78a2c6277eeb8.jpg",  // Example image
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
    }
}
