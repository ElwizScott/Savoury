//
//  SetupPreferencesBackendTests.swift
//  SetupPreferencesBackendTests
//
//  Created by An Luu on 6/10/24.
//

import Foundation
import XCTest
@testable import Savoury

// Backend test class for SetupPreferences
final class SetupPreferencesBackendTests: XCTestCase {

    // Reference to UserDefaults, using a suite to avoid clashing with the main app’s UserDefaults
    var defaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Using a separate UserDefaults suite to prevent real UserDefaults from being altered
        defaults = UserDefaults(suiteName: "TestDefaults")
        defaults.removePersistentDomain(forName: "TestDefaults")
    }
    
    override func tearDown() {
        defaults.removePersistentDomain(forName: "TestDefaults")
        defaults = nil
        super.tearDown()
    }

    // Test saving and retrieving health preferences
    func testSavingAndLoadingHealthPreferences() {
        let selectedHealth = ["Dairy Free", "Gluten Free"]
        
        // When: Save the selected health preferences
        defaults.set(selectedHealth, forKey: "selectedHealth")
        
        // Then: Retrieve and verify the saved preferences
        let retrievedHealth = defaults.array(forKey: "selectedHealth") as? [String] ?? []
        XCTAssertEqual(retrievedHealth, selectedHealth, "Retrieved health preferences should match saved preferences.")
    }
    
    // Test saving and retrieving dietary preferences
    func testSavingAndLoadingDietPreferences() {
        let selectedDiets = ["Low Carb", "High Protein"]
        
        // When: Save the selected diets preferences
        defaults.set(selectedDiets, forKey: "selectedDiets")
        
        // Then: Retrieve and verify the saved preferences
        let retrievedDiets = defaults.array(forKey: "selectedDiets") as? [String] ?? []
        XCTAssertEqual(retrievedDiets, selectedDiets, "Retrieved diet preferences should match saved preferences.")
    }
    
    // Test clearing saved preferences
    func testClearingPreferences() {
        let selectedHealth = ["Dairy Free", "Gluten Free"]
        let selectedDiets = ["Low Carb", "High Protein"]
        
        // Given: Saved health and diet preferences
        defaults.set(selectedHealth, forKey: "selectedHealth")
        defaults.set(selectedDiets, forKey: "selectedDiets")
        
        // When: Remove preferences
        defaults.removeObject(forKey: "selectedHealth")
        defaults.removeObject(forKey: "selectedDiets")
        
        // Then: Ensure preferences are cleared
        let retrievedHealth = defaults.array(forKey: "selectedHealth") as? [String] ?? []
        let retrievedDiets = defaults.array(forKey: "selectedDiets") as? [String] ?? []
        XCTAssertTrue(retrievedHealth.isEmpty, "Health preferences should be cleared.")
        XCTAssertTrue(retrievedDiets.isEmpty, "Diet preferences should be cleared.")
    }
}
