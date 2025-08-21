//
//  RecipeSearch.swift
//  Savoury
//
//  Created by Kien Le on 26/9/24.
//
//  Purpose:
//  A ViewModel that queries Edamam's Recipe API v2, manages pagination via
//  `_links.next.href`, and exposes results to SwiftUI via @Published state.
//

import Foundation
import SwiftData

/// ViewModel responsible for searching and loading recipe data from Edamam v2.
/// - Exposes `recipes` for UI consumption and `nextPageURL` for pagination.
/// - Always call `fetchNextPage()` if `nextPageURL` is non-nil to continue paging.
final class RecipeSearch: ObservableObject {

    // MARK: - Published State

    /// The list of recipe hits displayed in the UI.
    /// This array is replaced or appended depending on the call site.
    @Published var recipes: [RecipeHit] = []

    /// URL for the next page of results in Edamam v2.
    @Published var nextPageURL: URL? = nil

    // MARK: - Credentials

    /// Edamam `app_id`. Loaded from local API.plist via `APIKeys`.
    private var apiID: String { APIKeys.apiID }

    /// Edamam `app_key`. Loaded from local API.plist via `APIKeys`.
    private var apiKey: String { APIKeys.apiKey }

    // MARK: - Lifecycle & Reset

    /// Clears all loaded recipes and pagination state.
    /// Call before a new, unrelated search to avoid mixing old/new results.
    func clearRecipes() {
        recipes.removeAll()
        nextPageURL = nil
    }

    // MARK: - Category (dishType) Browse

    /// Fetches recipes for a user-selected `Category`.
    ///
    /// Internally maps your app's `Category` to Edamam's `dishType` values.
    /// This uses **v2** + `dishType` without an empty `q`, which is the recommended pattern
    /// for category-style browsing. (In v2, dishType is a first-class filter.)
    ///
    /// - Parameter category: App-level enum representing a user-selected category.
    func fetchRecipes(for category: Category) {
        // Map Category to Edamam dishType values.
        // Use lowercase phrases Edamam expects (they are case-insensitive, but this is conventional).
        let dishType: String = {
            switch category {
            case .maindish: return "main course"
            case .salad:    return "salad"
            case .drinks:   return "drinks"
            case .dessert:  return "desserts"
            }
        }()

        // Load persisted filters, if any. Ensure these strings match Edamam's expected values,
        // e.g., "gluten-free", "low-sugar", etc. If you store friendly labels, map them beforehand.
        let savedHealth = (UserDefaults.standard.array(forKey: "selectedHealth") as? [String]) ?? []
        let savedDiets  = (UserDefaults.standard.array(forKey: "selectedDiets")  as? [String]) ?? []

        // Build a safe, encoded v2 URL with dishType and selected filters.
        guard let url = makeV2SearchURL(q: nil,
                                        dishType: dishType,
                                        health: savedHealth,
                                        diet: savedDiets) else { return }

        // Fire request; replaces current results (browsing is typically a fresh list).
        requestSearchPage(url, resetResults: true)
    }

    // MARK: - Free-text Search

    /// Searches recipes by a free-text query using Edamam v2.
    ///
    /// - Parameter ingredient: User-entered text (e.g. "chicken", "beef brisket").
    /// - Note: Edamam recommends non-empty `q` for text searches. We trim and early-return if empty.
    func searchRecipes(for ingredient: String) {
        let trimmed = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let savedHealth = (UserDefaults.standard.array(forKey: "selectedHealth") as? [String]) ?? []
        let savedDiets  = (UserDefaults.standard.array(forKey: "selectedDiets")  as? [String]) ?? []

        guard let url = makeV2SearchURL(q: trimmed,
                                        dishType: nil,
                                        health: savedHealth,
                                        diet: savedDiets) else { return }

        // Replace the list with the new search results.
        requestSearchPage(url, resetResults: true)
    }

    // MARK: - Multi-ingredient Search

    /// Searches recipes using multiple selected ingredients (comma-joined in `q`).
    ///
    /// - Parameter selectedIngredients: A list of terms (e.g., ["chicken", "garlic", "lemon"]).
    func searchRecipes(forSelectedIngredients selectedIngredients: [String]) {
        let terms = selectedIngredients
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !terms.isEmpty else { return }

        let q = terms.joined(separator: ", ")

        let savedHealth = (UserDefaults.standard.array(forKey: "selectedHealth") as? [String]) ?? []
        let savedDiets  = (UserDefaults.standard.array(forKey: "selectedDiets")  as? [String]) ?? []

        guard let url = makeV2SearchURL(q: q,
                                        dishType: nil,
                                        health: savedHealth,
                                        diet: savedDiets) else { return }

        // Append to the existing list to mimic the "accumulate" behavior.
        requestSearchPage(url, resetResults: false)
    }

    // MARK: - Fetch by URI (v2 by ID)

    /// Loads recipes by Edamam recipe URIs using v2 "get by ID".
    ///
    /// Expected URI format:
    /// `http://www.edamam.com/ontologies/edamam.owl#recipe_<RECIPE_ID>`
    ///
    /// We extract the `<RECIPE_ID>` after the last underscore, then call:
    /// `/api/recipes/v2/{id}?type=public&app_id=...&app_key=...`
    ///
    /// - Parameter uris: Array of full Edamam URIs.
    func fetchRecipesByURI(_ uris: [String]) {
        // Fresh set – we're loading explicit IDs.
        self.recipes.removeAll()
        self.nextPageURL = nil

        for uri in uris {
            // Extract ID after "recipe_" safely.
            guard let recipeID = uri.split(separator: "_").last else {
                print("Invalid URI format: \(uri)")
                continue
            }

            // Build v2 "by ID" URL with proper query items.
            var comps = URLComponents(string: "https://api.edamam.com/api/recipes/v2/\(recipeID)")
            comps?.queryItems = [
                URLQueryItem(name: "type", value: "public"),
                URLQueryItem(name: "app_id", value: apiID),
                URLQueryItem(name: "app_key", value: apiKey),
            ]

            guard let url = comps?.url else { continue }

            URLSession.shared.dataTask(with: url) { data, response, error in
                // Print status + headers for debugging (helps diagnose non-JSON responses).
                self.debugResponse(url: url, data: data, response: response, error: error)
                guard let data = data else { return }

                do {
                    // v2-by-ID returns a top-level { recipe: {...}, _links?: {...} }
                    let decoded = try JSONDecoder().decode(RecipeByIDResponse.self, from: data)
                    let hit = RecipeHit(recipe: decoded.recipe)

                    DispatchQueue.main.async {
                        self.recipes.append(hit)
                    }
                } catch {
                    // If server returned HTML (e.g., 401/404 page), this prints a preview for quick diagnosis.
                    self.printBodySnippetOnFailure(data: data, error: error)
                }
            }.resume()
        }
    }

    // MARK: - Pagination

    /// Attempts to fetch the next page using `_links.next.href` from the previous response.
    func fetchNextPage() {
        guard let next = nextPageURL else { return }
        requestSearchPage(next, resetResults: false)
    }

    // MARK: - Networking Helpers

    /// Builds a **v2** search URL with safe percent-encoding.
    ///
    /// - Parameters:
    ///   - q: Optional free-text query. If `nil` or empty, it is not included.
    ///   - dishType: Optional Edamam dish type, e.g., "main course", "salad".
    ///   - health: Optional list of health filters (strings must match Edamam values).
    ///   - diet: Optional list of diet filters (strings must match Edamam values).
    /// - Returns: A fully encoded URL pointing to `/api/recipes/v2?type=public&...`.
    private func makeV2SearchURL(q: String?, dishType: String?, health: [String], diet: [String]) -> URL? {
        var comps = URLComponents(string: "https://api.edamam.com/api/recipes/v2")

        // Required v2 params.
        var items: [URLQueryItem] = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: apiID),
            URLQueryItem(name: "app_key", value: apiKey),
        ]

        // Include only when non-empty. This avoids empty `q` edge cases.
        if let q, !q.isEmpty {
            items.append(URLQueryItem(name: "q", value: q))
        }

        if let dishType, !dishType.isEmpty {
            items.append(URLQueryItem(name: "dishType", value: dishType))
        }

        // Convert stored description strings back to enum cases, then use apiValue
        for h in health {
            if let healthEnum = Health.allCases.first(where: { $0.description == h }) {
                items.append(URLQueryItem(name: "health", value: healthEnum.apiValue))
            }
        }

        for d in diet {
            if let dietEnum = Diet.allCases.first(where: { $0.description == d }) {
                items.append(URLQueryItem(name: "diet", value: dietEnum.apiValue))
            }
        }


        comps?.queryItems = items
        return comps?.url
    }

    /// Executes a GET request for the given v2 search URL and updates:
    /// - `recipes` (replaced or appended)
    /// - `nextPageURL` (from `_links.next.href` when present)
    ///
    /// - Parameters:
    ///   - url: A v2 search URL (from `makeV2SearchURL` or `_links.next.href`).
    ///   - resetResults: If `true`, replaces `recipes`. If `false`, appends to it.
    private func requestSearchPage(_ url: URL, resetResults: Bool) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Print status + headers; invaluable when backend returns HTML instead of JSON.
            self.debugResponse(url: url, data: data, response: response, error: error)
            guard let data = data else { return }

            do {
                // v2 search/list response contains `hits` and optional `_links.next.href`.
                let decoded = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)

                // Prepare next page (if any). If not present, this remains nil.
                let nextHref = decoded._links?.next?.href
                let nextURL  = nextHref.flatMap(URL.init(string:))

                DispatchQueue.main.async {
                    if resetResults {
                        self.recipes = decoded.hits
                    } else {
                        self.recipes.append(contentsOf: decoded.hits)
                    }
                    self.nextPageURL = nextURL
                }
            } catch {
                // When JSON decoding fails, quickly preview body to identify HTML or error payloads.
                self.printBodySnippetOnFailure(data: data, error: error)
            }
        }.resume()
    }

    // MARK: - Diagnostics

    /// Logs basic response diagnostics helpful for debugging API issues.
    ///
    /// - Important: If you ever see "Unexpected character '<'" during decoding,
    ///   check these logs. An HTML error/redirect page will show up here and in the snippet.
    private func debugResponse(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Request error:", error.localizedDescription)
        }
        if let http = response as? HTTPURLResponse {
            print("➡️ \(url.absoluteString)")
            print("Status:", http.statusCode)
            print("Content-Type:", http.value(forHTTPHeaderField: "Content-Type") ?? "nil")
        }
    }

    /// Prints a short preview of the body on decode failure.
    /// Useful to spot HTML pages, authorization errors, or unexpected shapes.
    private func printBodySnippetOnFailure(data: Data, error: Error) {
        let snippet = String(data: data.prefix(500), encoding: .utf8) ?? ""
        print("Decode error:", error)
        print("Body preview (first 500 chars):\n\(snippet)")
    }
}

// MARK: - Response Models (Edamam v2)

// NOTE ABOUT MODELS:
// - Edamam v2 search/list endpoints respond with:
//   { "hits": [ { "recipe": {...} }, ... ], "_links": { "next": { "href": "..." } } }
// - The "get by ID" endpoint responds with:
//   { "recipe": {...}, "_links": { ... } }

/// Top-level response for search/list queries in v2.
/// Includes the hits to display and the `_links` object used for pagination.
struct RecipeSearchResponse: Decodable {
    /// Array of result items where each `hit` wraps a `recipe`.
    let hits: [RecipeHit]

    /// Links object for pagination (e.g., `_links.next.href`).
    let _links: Links?
}

/// Container for hyperlink relations returned by Edamam v2 (pagination, etc.).
struct Links: Decodable {
    /// The link relation pointing to the next page of results, when available.
    let next: LinkHref?
}

/// Represents a hyperlink with an absolute URL string.
struct LinkHref: Decodable {
    /// Absolute URL for the next page. Use `URL(string: href)` directly.
    let href: String
}

/// A single search result item wrapping the actual `recipe`.
/// - Note: `Identifiable` is implemented with a generated UUID so that SwiftUI Lists/ForEach
///   can render without relying on server-side stable IDs. If you prefer stable IDs,
///   so we use `recipe.uri` (hash) as an identifier.
struct RecipeHit: Decodable, Identifiable {
    /// Synthetic ID for SwiftUI identity; not from server.
    let id = UUID()

    /// The actual recipe payload from Edamam.
    let recipe: Recipe
}

/// Response shape for "get by ID" in v2 (`/api/recipes/v2/{id}`).
/// The server returns a top-level `recipe`, plus optional `_links`.
struct RecipeByIDResponse: Decodable {
    /// The fully detailed recipe object.
    let recipe: Recipe

    /// Optional links (not always needed for "by ID", but we allow it for flexibility).
    let _links: Links?
}

/// Core recipe object returned by Edamam v2.
/// Fields are optional when the API may omit them; decoding remains resilient.
struct Recipe: Decodable {
    /// Edamam's canonical recipe URI (includes the recipe ID).
    let uri: String

    /// Human-readable title of the recipe.
    let label: String

    /// URL to a representative image for the recipe.
    let image: String

    /// Number of servings the recipe yields (may be omitted).
    let yield: Double?

    /// Total calories across the entire recipe (may be omitted).
    let calories: Double?

    /// Aggregate weight across all ingredients (grams, may be omitted).
    let totalWeight: Double?

    /// Estimated total cooking time in minutes (may be omitted).
    let totalTime: Double?

    /// List of caution labels (e.g., allergens). Often empty or omitted.
    let cautions: [String]?

    /// Flat list of ingredients used in the recipe (may be omitted).
    let ingredients: [Ingredient]?

    /// Cuisine types (e.g., "american", "italian"). Usually lowercase strings.
    let cuisineType: [String]?

    /// Meal types (e.g., "lunch/dinner", "breakfast").
    let mealType: [String]?

    /// Dish types (e.g., "main course", "salad").
    let dishType: [String]?

    /// Source URL with full instructions hosted by the original publisher.
    let url: String?
}

/// Minimal ingredient model; extend as needed for quantities/measure.
/// Edamam provides richer fields, but `food` is often what you show in lists.
struct Ingredient: Decodable {
    /// The human-readable ingredient name (e.g., "chicken breast").
    let food: String
}

// MARK: - API Keys

/// Utility for loading API credentials from API.plist at runtime.
/// - Ensure `API.plist` contains string keys "API_ID" and "API_KEY".
/// - Keep API.plist out of source control or provide a non-secret placeholder
///   and inject real values via CI/Secrets for production builds.
struct APIKeys {
    /// Edamam `app_id`
    static var apiID: String { getValueFromAPI(for: "API_ID") }

    /// Edamam `app_key`
    static var apiKey: String { getValueFromAPI(for: "API_KEY") }

    /// Reads a value from API.plist.
    /// - Parameter key: The dictionary key to read.
    /// - Returns: The string value if found; otherwise an empty string.
    static func getValueFromAPI(for key: String) -> String {
        if let path = Bundle.main.path(forResource: "API", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            return dict[key] as? String ?? ""
        }
        return ""
    }
}
