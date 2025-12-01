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
    @State private var bakingSteps: [BakingStepInput] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // Cached calculated values
    @State private var cachedTotalWeight: Double = 0
    @State private var cachedHydration: Double?
    @State private var cachedWeightPerServing: Double = 0

    init(recipe: Recipe? = nil, onDismiss: @escaping () -> Void) {
        self.recipe = recipe
        self.onDismiss = onDismiss
    }

    var body: some View {
        Form {
            recipeInfoSection
            servingSection
            ingredientsSection
            bakingStepsSection
            calculatedMetricsSection
            saveButton
        }
        .onAppear {
            loadRecipe()
        }
        .onChange(of: ingredients) { oldValue, newValue in
            updateCalculatedMetrics()
        }
        .onChange(of: servings) { oldValue, newValue in
            updateCalculatedMetrics()
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

    private var bakingStepsSection: some View {
        Section {
            ForEach(bakingSteps) { step in
                BakingStepInputRow(
                    step: bindingForStep(step)
                )
            }
            .onDelete(perform: deleteBakingSteps)
            .onMove(perform: moveBakingSteps)

            Button {
                addBakingStep()
            } label: {
                Label("Add Step", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Preparation Steps (Optional)")
        }
    }

    private var calculatedMetricsSection: some View {
        Section("Calculated Metrics") {
            metricRow("Total Weight", value: String(format: "%.0fg", cachedTotalWeight))
            metricRow("Per \(servingType.displayName)", value: String(format: "%.0fg", cachedWeightPerServing))
            if let hydration = cachedHydration {
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

    private var isValid: Bool {
        !recipeName.isEmpty && !ingredients.isEmpty && ingredients.allSatisfy { !$0.name.isEmpty && $0.weight > 0 }
    }

    // MARK: - Actions

    private func updateCalculatedMetrics() {
        cachedTotalWeight = ingredients.reduce(0.0) { $0 + $1.weight }
        cachedWeightPerServing = servings > 0 ? cachedTotalWeight / Double(servings) : 0

        let ingredientModels = ingredients.map { $0.toIngredient() }
        cachedHydration = HydrationCalculator.calculateHydration(from: ingredientModels)
    }

    private func loadRecipe() {
        guard let recipe = recipe else {
            addIngredient()
            updateCalculatedMetrics()
            return
        }

        recipeName = recipe.name
        recipeDescription = recipe.recipeDescription ?? ""
        servings = recipe.servings
        servingType = recipe.servingType
        ingredients = recipe.ingredients.map { IngredientInput(from: $0) }
        bakingSteps = recipe.bakingSteps
            .sorted(by: { $0.order < $1.order })
            .map { BakingStepInput(from: $0) }

        updateCalculatedMetrics()
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

    private func addBakingStep() {
        let order = bakingSteps.count
        bakingSteps.append(BakingStepInput(order: order))
    }

    private func deleteBakingSteps(at offsets: IndexSet) {
        bakingSteps.remove(atOffsets: offsets)
        reorderSteps()
    }

    private func moveBakingSteps(from source: IndexSet, to destination: Int) {
        bakingSteps.move(fromOffsets: source, toOffset: destination)
        reorderSteps()
    }

    private func reorderSteps() {
        for (index, _) in bakingSteps.enumerated() {
            bakingSteps[index].order = index
        }
    }

    private func bindingForStep(_ step: BakingStepInput) -> Binding<BakingStepInput> {
        guard let index = bakingSteps.firstIndex(where: { $0.id == step.id }) else {
            return .constant(step)
        }
        return $bakingSteps[index]
    }

    private func saveRecipe() {
        let ingredientModels = ingredients.map { $0.toIngredient() }
        let ingredientsWithPercentages = BakerPercentageCalculator.calculatePercentages(from: ingredientModels)
        let stepModels = bakingSteps.map { $0.toBakingStep() }

        if let existingRecipe = recipe {
            // Update existing recipe
            existingRecipe.name = recipeName
            existingRecipe.recipeDescription = recipeDescription.isEmpty ? nil : recipeDescription
            existingRecipe.ingredients = ingredientsWithPercentages
            existingRecipe.bakingSteps = stepModels
            existingRecipe.totalWeightInGrams = cachedTotalWeight
            existingRecipe.hydrationPercentage = cachedHydration
            existingRecipe.servings = servings
            existingRecipe.servingType = servingType
            existingRecipe.modifiedDate = Date()
        } else {
            // Create new recipe
            let newRecipe = Recipe(
                name: recipeName,
                recipeDescription: recipeDescription.isEmpty ? nil : recipeDescription,
                ingredients: ingredientsWithPercentages,
                bakingSteps: stepModels,
                totalWeightInGrams: cachedTotalWeight,
                hydrationPercentage: cachedHydration,
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

struct IngredientInput: Identifiable, Equatable {
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

    static func == (lhs: IngredientInput, rhs: IngredientInput) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.weight == rhs.weight &&
        lhs.type == rhs.type &&
        lhs.hydration == rhs.hydration
    }
}

// MARK: - Baking Step Input Model

struct BakingStepInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var instructions: String = ""
    var durationInMinutes: Int = 0
    var temperatureCelsius: Int?
    var stepType: StepType = .other
    var order: Int = 0

    init(order: Int = 0) {
        self.order = order
    }

    init(from step: BakingStep) {
        self.name = step.name
        self.instructions = step.instructions
        self.durationInMinutes = step.durationInMinutes
        self.temperatureCelsius = step.temperatureCelsius
        self.stepType = step.stepType
        self.order = step.order
    }

    func toBakingStep() -> BakingStep {
        BakingStep(
            name: name,
            instructions: instructions,
            durationInMinutes: durationInMinutes,
            temperatureCelsius: temperatureCelsius,
            stepType: stepType,
            order: order
        )
    }
}

#Preview {
    ManualEntryView {}
        .modelContainer(for: [Recipe.self], inMemory: true)
}
