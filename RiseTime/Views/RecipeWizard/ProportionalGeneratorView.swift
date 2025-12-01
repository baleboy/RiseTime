//
//  ProportionalGeneratorView.swift
//  RiseTime
//
//  Proportional generator mode for recipe creation
//

import SwiftUI
import SwiftData

struct ProportionalGeneratorView: View {
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    @State private var servingType: ServingType = .pizza
    @State private var servingCount: Int = 1
    @State private var weightPerServing: Double = 250
    @State private var targetHydration: Double = 65
    @State private var ingredientPercentages: [IngredientPercentageInput] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        Form {
            recipeInfoSection
            targetParametersSection
            ingredientPercentagesSection
            calculatedIngredientsSection
            saveButton
        }
        .onAppear {
            setupDefaultIngredients()
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

    private var targetParametersSection: some View {
        Section("Target Parameters") {
            Picker("Type", selection: $servingType) {
                ForEach(ServingType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }

            HStack {
                Text("Count")
                Spacer()
                TextField("Count", value: $servingCount, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
            }

            HStack {
                Text("Weight per \(servingType.displayName)")
                Spacer()
                TextField("Weight", value: $weightPerServing, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
                Text("g")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Hydration")
                Spacer()
                TextField("Hydration", value: $targetHydration, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                Text("%")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var ingredientPercentagesSection: some View {
        Section("Ingredient Percentages (% of flour)") {
            ForEach(ingredientPercentages) { ingredient in
                percentageRow(for: binding(for: ingredient))
            }
            .onDelete(perform: deletePercentageIngredient)

            Button {
                addPercentageIngredient()
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
        }
    }

    private func percentageRow(for ingredient: Binding<IngredientPercentageInput>) -> some View {
        HStack {
            TextField("Name", text: ingredient.name)
                .textFieldStyle(.roundedBorder)

            TextField("%", value: ingredient.percentage, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)

            Text("%")
                .foregroundStyle(.secondary)
        }
    }

    private var calculatedIngredientsSection: some View {
        Section("Calculated Ingredients") {
            ForEach(calculatedIngredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(String(format: "%.0fg", ingredient.weightInGrams))
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("Total Weight")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.0fg", totalCalculatedWeight))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Per \(servingType.displayName)")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.0fg", weightPerServing))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
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

    private var targetTotalWeight: Double {
        Double(servingCount) * weightPerServing
    }

    private var calculatedIngredients: [Ingredient] {
        let flourWeight = calculateFlourWeight()
        let waterWeight = HydrationCalculator.calculateWaterWeight(
            flourWeight: flourWeight,
            targetHydration: targetHydration
        )

        var ingredients = [
            Ingredient(name: "Flour", weightInGrams: flourWeight, bakerPercentage: 100, type: .flour),
            Ingredient(name: "Water", weightInGrams: waterWeight, bakerPercentage: targetHydration, type: .water)
        ]

        for percentageInput in ingredientPercentages where !percentageInput.name.isEmpty {
            let weight = (percentageInput.percentage / 100) * flourWeight
            ingredients.append(
                Ingredient(
                    name: percentageInput.name,
                    weightInGrams: weight,
                    bakerPercentage: percentageInput.percentage,
                    type: percentageInput.type
                )
            )
        }

        return ingredients
    }

    private var totalCalculatedWeight: Double {
        calculatedIngredients.reduce(0) { $0 + $1.weightInGrams }
    }

    private var isValid: Bool {
        !recipeName.isEmpty && targetHydration > 0 && weightPerServing > 0 && servingCount > 0
    }

    // MARK: - Calculations

    private func calculateFlourWeight() -> Double {
        // Total weight = flour + water + other ingredients
        // Total weight = flour × (1 + hydration% + sum of other percentages)
        let totalPercentage = 100 + targetHydration + ingredientPercentages.reduce(0) { $0 + $1.percentage }
        return (targetTotalWeight * 100) / totalPercentage
    }

    // MARK: - Actions

    private func setupDefaultIngredients() {
        if ingredientPercentages.isEmpty {
            ingredientPercentages = [
                IngredientPercentageInput(name: "Salt", percentage: 2, type: .salt),
                IngredientPercentageInput(name: "Yeast", percentage: 1, type: .yeast),
                IngredientPercentageInput(name: "Olive Oil", percentage: 2, type: .oil)
            ]
        }
    }

    private func addPercentageIngredient() {
        ingredientPercentages.append(IngredientPercentageInput())
    }

    private func deletePercentageIngredient(at offsets: IndexSet) {
        ingredientPercentages.remove(atOffsets: offsets)
    }

    private func binding(for ingredient: IngredientPercentageInput) -> Binding<IngredientPercentageInput> {
        guard let index = ingredientPercentages.firstIndex(where: { $0.id == ingredient.id }) else {
            return .constant(ingredient)
        }
        return $ingredientPercentages[index]
    }

    private func saveRecipe() {
        let newRecipe = Recipe(
            name: recipeName,
            recipeDescription: recipeDescription.isEmpty ? nil : recipeDescription,
            ingredients: calculatedIngredients,
            totalWeightInGrams: totalCalculatedWeight,
            hydrationPercentage: targetHydration,
            servings: servingCount,
            servingType: servingType,
            createdDate: Date(),
            modifiedDate: Date()
        )

        modelContext.insert(newRecipe)
        do {
            try modelContext.save()
            onDismiss()
        } catch {
            alertMessage = "Failed to save recipe: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Ingredient Percentage Input Model

struct IngredientPercentageInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var percentage: Double = 0
    var type: IngredientType = .other

    init(name: String = "", percentage: Double = 0, type: IngredientType = .other) {
        self.name = name
        self.percentage = percentage
        self.type = type
    }
}

#Preview {
    ProportionalGeneratorView {}
        .modelContainer(for: [Recipe.self], inMemory: true)
}
