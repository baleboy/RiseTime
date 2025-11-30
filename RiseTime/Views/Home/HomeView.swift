//
//  HomeView.swift
//  RiseTime
//
//  Main home screen with recipe list and navigation
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Recipe.modifiedDate, order: .reverse)])
    private var recipes: [Recipe]
    @State private var showingRecipeWizard = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            recipeListContent
                .navigationTitle("Rise Time")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showingRecipeWizard) {
                    RecipeWizardView()
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private var recipeListContent: some View {
        if recipes.isEmpty {
            emptyStateView
        } else {
            RecipeListView(recipes: recipes)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Recipes", systemImage: "book.closed")
        } description: {
            Text("Tap the + button to create your first recipe")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingRecipeWizard = true
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItem(placement: .topBarLeading) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Recipe.self, Experiment.self], inMemory: true)
}
