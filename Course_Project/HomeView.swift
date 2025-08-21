//
//  HomeView.swift
//  Savoury
//
//  Created by An Luu on 22/8/24.
//  Modified by Kien Le 30/8/24
//  Check by An Luu 1/9/24

import SwiftUI

///The main screen view of the application, providing an overview of various dishes, navigation through categories, and access to different sections like the recipe and cooking mode screens.
struct HomeView: View {
    
    /// This username value is passed in by the authentication process
    @State var username: String
    
    @State var ingredientsFromPhotos: [String] = []

    /// Default to "Main Dishes"
    @State var selectedCategory: Category = .maindish
    
    /// State to control the visibility of the  screens
    @State private var showCulinaryPreferencesView = false
    @State private var showSearchByNameView = false
    @State private var showFavoriteView = false
    @State private var showCameraView = false
    @State private var showSearchIngredients = false
    @State private var showTimerScreen = false
    
    /// Observed RecipeSearch for Popular recipes
    @ObservedObject var recipeSearch = RecipeSearch()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // instead of saying welcome home, it will said welcome username
                    Text("Welcome, \(username)!")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .onTapGesture {
                            showSearchByNameView = true
                        }
                    Image(systemName: "person.crop.circle")
                        .padding(.horizontal)
                        .onTapGesture {
                            showCulinaryPreferencesView = true
                        }
                }
                .padding()
                
                // CategoryTab for selection
                CategoryTab(selectedCategory: $selectedCategory, recipeSearch: recipeSearch)
                
                // Display the RecipeCategoryView for the selected category
                RecipeCategoryView(recipeSearch: recipeSearch, selectedCategory: $selectedCategory)
                
                // Using the TabBarView for navigating to other parts of the application.
                TabBar(showTimerScreen: $showTimerScreen, 
                       showSearchIngredients: $showSearchIngredients,
                       showFavoriteView: $showFavoriteView, showCameraView: $showCameraView)
            }
            
            // Conditionally display the selected screen if @State variable above is true.

            if showCulinaryPreferencesView{
                CulinaryPreferencesView(showCulinaryPreferencesView: $showCulinaryPreferencesView, userName_homeview: $username)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
            
            if showSearchByNameView {
                SearchView(
                    showSearchByNameView: $showSearchByNameView) // Pass the state to SearchView
                    .transition(.move(edge: .leading))
                    .zIndex(1)  // Ensure SearchView is on top
            }
            
            if showFavoriteView {
                FavoriteView(
                    showFavoriteView: $showFavoriteView) // Pass the state to FavoriteView
                    .transition(.move(edge: .leading))
                    .zIndex(1)  // Ensure FavoriteView is on top
            }
            
            if showCameraView {
                CameraView(showCameraView: $showCameraView, ingredients: [], classifier: ImageClassifier()) // Pass the state to CameraView
                    .transition(.move(edge: .leading))
                    .zIndex(1)  // Ensure CameraView is on top
            }
            
            if showSearchIngredients {
                IngredientSelectionView(
                    showSearchIngredients: $showSearchIngredients,
                    openedFromCameraView: .constant(false),
                    ingredientsFromPhotos: $ingredientsFromPhotos) // Pass the state to IngredientSelectionView
                    .transition(.move(edge: .leading))
                    .zIndex(1)  // Ensure IngredientSelectionView is on top
            }
            
            if showTimerScreen {
                TimerView(
                    isTimerViewVisible: $showTimerScreen) // Pass the state to TimerScreen
                    .transition(.move(edge: .leading))
                    .zIndex(1)  // Ensure TimerScreen is on top
            }

        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(username: "Dummy")
    }
}
