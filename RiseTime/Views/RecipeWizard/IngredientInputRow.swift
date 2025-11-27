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

            if ingredient.type == .starter {
                starterHydrationSection
            }
        }
        .padding(.vertical, 4)
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

    private var starterHydrationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Starter Hydration")
                .font(.caption)
                .foregroundStyle(.secondary)

            presetButtons

            customHydrationField
        }
    }

    private var presetButtons: some View {
        HStack(spacing: 8) {
            ForEach(StarterPreset.allCases, id: \.self) { preset in
                Button {
                    ingredient.hydration = preset.hydration
                } label: {
                    Text(preset.displayName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(ingredient.hydration == preset.hydration ? .blue : .gray)
            }
        }
    }

    private var customHydrationField: some View {
        HStack {
            Text("Hydration:")
                .font(.subheadline)

            TextField("Hydration", value: $ingredient.hydration, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 60)

            Text("%")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Starter Presets

enum StarterPreset: CaseIterable {
    case poolish
    case sourdough
    case biga
    case levain

    var displayName: String {
        switch self {
        case .poolish: return "Poolish"
        case .sourdough: return "Sourdough"
        case .biga: return "Biga"
        case .levain: return "Levain"
        }
    }

    var hydration: Double {
        switch self {
        case .poolish: return 100
        case .sourdough: return 100
        case .biga: return 50
        case .levain: return 100
        }
    }
}

#Preview {
    @Previewable @State var ingredient = IngredientInput()

    Form {
        IngredientInputRow(ingredient: $ingredient)
    }
}
