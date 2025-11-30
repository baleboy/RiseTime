//
//  IngredientInputRow.swift
//  RiseTime
//
//  Reusable row component for ingredient input
//

import SwiftUI

struct IngredientInputRow: View {
    @Binding var ingredient: IngredientInput

    var body: some View {
        VStack(spacing: 12) {
            nameAndWeightFields
            typePicker

            if ingredient.type.isStarter {
                hydrationField
            }
        }
        .padding(.vertical, 4)
        .onChange(of: ingredient.type) { oldValue, newValue in
            handleTypeChange(from: oldValue, to: newValue)
        }
    }

    // MARK: - View Components

    private var nameAndWeightFields: some View {
        HStack(spacing: 12) {
            TextField("Ingredient name", text: $ingredient.name)
                .textFieldStyle(.roundedBorder)

            TextField("Weight", value: $ingredient.weight, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 80)

            Text("g")
                .foregroundStyle(.secondary)
        }
    }

    private var typePicker: some View {
        Picker("Type", selection: $ingredient.type) {
            ForEach(IngredientType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.menu)
    }

    private var hydrationField: some View {
        HStack {
            Text("Hydration:")
                .font(.subheadline)

            TextField("Hydration", value: $ingredient.hydration, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 60)

            Text("%")
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Actions

    private func handleTypeChange(from oldType: IngredientType, to newType: IngredientType) {
        // When switching to a starter type, pre-fill hydration with default
        if newType.isStarter, let defaultHydration = newType.defaultHydration {
            ingredient.hydration = defaultHydration
        }
        // When switching away from starter, clear hydration
        else if !newType.isStarter {
            ingredient.hydration = nil
        }
    }
}

#Preview {
    @Previewable @State var ingredient = IngredientInput()

    Form {
        IngredientInputRow(ingredient: $ingredient)
    }
}
