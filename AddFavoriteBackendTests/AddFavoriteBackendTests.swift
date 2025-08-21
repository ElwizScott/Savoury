import XCTest
import SwiftData
@testable import Savoury

final class AddFavoriteTests: XCTestCase {
    private var context: ModelContext!

    @MainActor
    override func setUp() {
        context = MockContainer.mainContext
    }
    
    func testInsertFavoriteSuccessfully() throws {
        let sample = AddFavorite(Recipe: "Strawberry Cake", RecipeID: "Dummy")
        
        // Insert the sample into the context
        context.insert(sample)

        // Save the context and verify no issues occurred
        XCTAssertNoThrow(try context.save())
    }
    
    func testDeleteFavoriteSuccessfully() throws {
        let sample = AddFavorite(Recipe: "Strawberry Cake", RecipeID: "Dummy")
        
        // Insert the sample into the context
        context.insert(sample)
        context.delete(sample)

        // Save the context and verify no issues occurred
        XCTAssertNoThrow(try context.save())
    }
    
    func testInsertDuplicateFavorites() throws {
        let sample = AddFavorite(Recipe: "Strawberry Cake", RecipeID: "Dummy")
        
        // Insert the sample into the context
        context.insert(sample)
        context.insert(sample)

        // If save succeeds, fail the test
        XCTAssertThrowsError(try context.save(), "Context allowed duplicate insertions") { error in
            XCTAssertNotNil(error, "Expected an error for duplicate insertion")
        }
    }
    
    
    @MainActor
    override func tearDown() {
        try! context.delete(model: AddFavorite.self)
    }

}
