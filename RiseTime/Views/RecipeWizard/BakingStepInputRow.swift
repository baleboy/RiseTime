//
//  BakingStepInputRow.swift
//  RiseTime
//
//  Reusable row component for baking step input
//

import SwiftUI

struct BakingStepInputRow: View {
    @Binding var step: BakingStepInput

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            stepNameAndType
            instructionsField
            durationAndTemperature
        }
        .padding(.vertical, 8)
    }

    // MARK: - View Components

    private var stepNameAndType: some View {
        HStack(spacing: 12) {
            TextField("Step name (e.g., 'First Proof')", text: $step.name)
                .textFieldStyle(.roundedBorder)

            Picker("Type", selection: $step.stepType) {
                ForEach(StepType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.iconName)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)
        }
    }

    private var instructionsField: some View {
        TextField("Instructions", text: $step.instructions, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(2...4)
    }

    private var durationAndTemperature: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                TextField("Duration", value: $step.durationInMinutes, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 60)

                Text("min")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            HStack(spacing: 8) {
                Image(systemName: "thermometer")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                TextField("Temp", value: $step.temperatureCelsius, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 60)

                Text("°C")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                Text("(optional)")
                    .foregroundStyle(.tertiary)
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    @Previewable @State var step = BakingStepInput(order: 0)

    Form {
        BakingStepInputRow(step: $step)
    }
}
