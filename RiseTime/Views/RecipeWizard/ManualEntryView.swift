//
//  ManualEntryView.swift
//  RiseTime
//
//  Manual entry mode for recipe creation
//

import SwiftUI
import SwiftData

struct ManualEntryView: View {
    let recipe: Recipe?
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    @State private var servings: Int = 1
    @State private var servingType: ServingType = .pizza
    @State private var ingredients: [IngredientInput] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(recipe: Recipe? = nil, onDismiss: @escaping () -> Void) {
        self.recipe = recipe
        self.onDismiss = onDismiss
    }

    var body: some View {
        Form {
            recipeInfoSection
            servingSection
            ingredientsSection
            calculatedMetricsSection
            saveButton
        }
        .onAppear {
            loadRecipe()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - View Components

    private var recipeInfoSection: some View {
        Section("Recipe Info") {
            TextField("Recipe Name", text: $recipeName)
            TextField("Description (optional)", text: $recipeDescription, axis: .vertical)
                .lineLimit(3...5)
        }
    }

    private var servingSection: some View {
        Section("Servings") {
            Picker("Type", selection: $servingType) {
                ForEach(ServingType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }

            Stepper("Count: \(servings)", value: $servings, in: 1...100)
        }
    }

    private var ingredientsSection: some View {
        Section {
            ForEach(ingredients) { ingredient in
                IngredientInputRow(
                    ingredient: binding(for: ingredient)
                )
            }
            .onDelete(perform: deleteIngredients)

            Button {
                addIngredient()
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Ingredients")
        }
    }

    private var calculatedMetricsSection: some View {
        Section("Calculated Metrics") {
            metricRow("Total Weight", value: totalWeight)
            if let hydration = calculatedHydration {
                metricRow("Hydration", value: String(format: "%.1f%%", hydration))
            }
        }
    }

    private func metricRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private var saveButton: some View {
        Section {
            Button {
                saveRecipe()
            } label: {
                Text("Save Recipe")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .disabled(!isValid)
        }
    }

    // MARK: - Computed Properties

    private var totalWeight: String {
        let total = ingredients.reduce(0.0) { $0 + $1.weight }
        return String(format: "%.0fg", total)
    }

    private var calculatedHydration: Double? {
        let ingredientModels = ingredients.map { $0.toIngredient() }
        return HydrationCalculator.calculateHydration(from: ingredientModels)
    }

    private var isValid: Bool {
        !recipeName.isEmpty && !ingredients.isEmpty && ingredients.allSatisfy { !$0.name.isEmpty && $0.weight > 0 }
    }

    // MARK: - Actions

    private func loadRecipe() {
        guard let recipe = recipe else {
            addIngredient()
            return
        }

        recipeName = recipe.name
        recipeDescription = recipe.recipeDescription ?? ""
        servings = recipe.servings
        servingType = recipe.servingType
        ingredients = recipe.ingredients.map { IngredientInput(from: $0) }
    }

    private func addIngredient() {
        ingredients.append(IngredientInput())
    }

    private func deleteIngredients(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }

    private func binding(for ingredient: IngredientInput) -> Binding<IngredientInput> {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else {
            return .constant(ingredient)
        }
        return $ingredients[index]
    }

    private func saveRecipe() {
        let ingredientModels = ingredients.map { $0.toIngredient() }
        let ingredientsWithPercentages = BakerPercentageCalculator.calculatePercentages(from: ingredientModels)

        if let existingRecipe = recipe {
            // Update existing recipe
            existingRecipe.name = recipeName
            existingRecipe.recipeDescription = recipeDescription.isEmpty ? nil : recipeDescription
            existingRecipe.ingredients = ingredientsWithPercentages
            existingRecipe.totalWeightInGrams = ingredients.reduce(0) { $0 + $1.weight }
            existingRecipe.hydrationPercentage = calculatedHydration
            existingRecipe.servings = servings
            existingRecipe.servingType = servingType
            existingRecipe.modifiedDate = Date()
        } else {
            // Create new recipe
            let newRecipe = Recipe(
                name: recipeName,
                recipeDescription: recipeDescription.isEmpty ? nil : recipeDescription,
                ingredients: ingredientsWithPercentages,
                totalWeightInGrams: ingredients.reduce(0) { $0 + $1.weight },
                hydrationPercentage: calculatedHydration,
                servings: servings,
                servingType: servingType
            )
            modelContext.insert(newRecipe)
        }

        do {
            try modelContext.save()
            onDismiss()
        } catch {
            alertMessage = "Failed to save recipe: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Ingredient Input Model

struct IngredientInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var weight: Double = 0
    var type: IngredientType = .flour
    var hydration: Double?

    init() {}

    init(from ingredient: Ingredient) {
        self.name = ingredient.name
        self.weight = ingredient.weightInGrams
        self.type = ingredient.type
        self.hydration = ingredient.hydration
    }

    func toIngredient() -> Ingredient {
        Ingredient(
            name: name,
            weightInGrams: weight,
            type: type,
            hydration: hydration
        )
    }
}

#Preview {
    ManualEntryView {}
        .modelContainer(for: [Recipe.self], inMemory: true)
}
