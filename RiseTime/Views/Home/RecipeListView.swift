//
//  RecipeListView.swift
//  RiseTime
//
//  List view displaying saved recipes
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    let recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(recipes) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .onDelete(perform: deleteRecipes)
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }

    // MARK: - Actions

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = recipes[index]
            modelContext.delete(recipe)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: config
    )

    let sampleRecipe = Recipe(
        name: "Neapolitan Pizza",
        servings: 4,
        servingType: .pizza
    )
    container.mainContext.insert(sampleRecipe)

    return NavigationStack {
        RecipeListView(recipes: [sampleRecipe])
            .modelContainer(container)
    }
}
