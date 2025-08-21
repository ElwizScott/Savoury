//
//  SavouryTests.swift
//  SavouryTests
//
//  Created by An Luu on 6/10/24.
//

import Foundation
import XCTest
@testable import Savoury

final class APIcalltests: XCTestCase {

    var recipeSearch: RecipeSearch!

    override func setUp() {
        super.setUp()
        recipeSearch = RecipeSearch()
    }

    override func tearDown() {
        recipeSearch = nil
        super.tearDown()
    }


    // Test for fetching recipes using the default query (real API)
    func testFetchRecipesRealAPI() {
        let expectation = self.expectation(description: "Fetching recipes from real API")
        
        // When: Fetch recipes is called
        recipeSearch.fetchRecipes(for: .maindish)

        // Wait for the network response
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Then: Verify the response and recipes are not empty
            XCTAssertFalse(self.recipeSearch.recipes.isEmpty, "Recipes should not be empty after API call")
            XCTAssertNotNil(self.recipeSearch.recipes.first?.recipe.label, "First recipe label should not be nil")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }


    // Test for searching recipes based on an ingredient (real API)
    func testSearchRecipesForIngredientRealAPI() {
        let expectation = self.expectation(description: "Searching recipes for ingredient 'beef' from real API")
        
        // When: Search for recipes with the ingredient "beef"
        recipeSearch.searchRecipes(for: "beef")

        // Wait for the network response
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Then: Verify the response and recipes are not empty
            XCTAssertFalse(self.recipeSearch.recipes.isEmpty, "Recipes should not be empty after API call")
            XCTAssertNotNil(self.recipeSearch.recipes.first?.recipe.label, "First recipe label should not be nil")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // Test for searching recipes with multiple ingredients (real API)
    func testSearchRecipesForSelectedIngredientsRealAPI() {
        let expectation = self.expectation(description: "Searching recipes for multiple ingredients from real API")
        
        // When: Search for recipes with selected ingredients "chicken" and "rice"
        recipeSearch.searchRecipes(forSelectedIngredients: ["chicken", "rice"])

        // Wait for the network response
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Then: Verify the response and recipes are not empty
            XCTAssertFalse(self.recipeSearch.recipes.isEmpty, "Recipes should not be empty after API call")
            XCTAssertNotNil(self.recipeSearch.recipes.first?.recipe.label, "First recipe label should not be nil")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // Test for clearing the recipe array
    func testClearRecipes() {
        // Given: There are some recipes in the array
        recipeSearch.recipes = [RecipeHit(recipe: Recipe(uri: "Dummy", label: "Chicken", image: "", yield: 4, calories: 500, totalWeight: 1000, totalTime: 60, cautions: [], ingredients: [], cuisineType: [], mealType: [], dishType: [], url: ""))]

        // When: Clear recipes is called
        recipeSearch.clearRecipes()

        // Then: Verify the recipes array is cleared
        XCTAssertTrue(recipeSearch.recipes.isEmpty, "Recipes array should be empty after clearing")
    }
}

