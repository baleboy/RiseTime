//
//  RecipeWizardView.swift
//  RiseTime
//
//  Wizard for creating and editing recipes
//

import SwiftUI

struct RecipeWizardView: View {
    let recipe: Recipe?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: RecipeWizardMode = .manualEntry

    init(recipe: Recipe? = nil) {
        self.recipe = recipe
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if recipe == nil {
                    modeSelector
                }

                selectedModeView
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - View Components

    private var modeSelector: some View {
        Picker("Mode", selection: $selectedMode) {
            ForEach(RecipeWizardMode.allCases, id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    @ViewBuilder
    private var selectedModeView: some View {
        switch selectedMode {
        case .manualEntry:
            ManualEntryView(recipe: recipe) {
                dismiss()
            }
        case .proportionalGenerator:
            ProportionalGeneratorView {
                dismiss()
            }
        }
    }

    private var navigationTitle: String {
        if let recipe = recipe {
            return "Edit \(recipe.name)"
        }
        return "New Recipe"
    }
}

// MARK: - Recipe Wizard Mode

enum RecipeWizardMode: CaseIterable {
    case manualEntry
    case proportionalGenerator

    var displayName: String {
        switch self {
        case .manualEntry:
            return "Manual Entry"
        case .proportionalGenerator:
            return "Generate from %"
        }
    }
}

#Preview {
    RecipeWizardView()
}
