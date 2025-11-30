//
//  ActiveBakingView.swift
//  RiseTime
//
//  Active baking view with step-by-step timer
//

import SwiftUI

struct ActiveBakingView: View {
    @ObservedObject var session: BakingSession
    let onComplete: () -> Void

    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !session.isComplete {
                    progressIndicator
                    currentStepCard
                    timerDisplay
                    controlButtons
                    upcomingStepsPreview
                } else {
                    completionView
                }
            }
            .padding()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - View Components

    private var progressIndicator: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(session.currentStepIndex + 1) of \(session.schedule.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: session.progress)
                .tint(.blue)
        }
    }

    private var currentStepCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let step = session.currentStep {
                HStack {
                    Image(systemName: step.step.stepType.iconName)
                        .font(.title)
                        .foregroundStyle(.tint)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.step.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let temp = step.step.temperatureCelsius {
                            Label("\(temp)°C", systemImage: "thermometer")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }

                if !step.step.instructions.isEmpty {
                    Text(step.step.instructions)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            Text(timeRemainingFormatted)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(session.timeRemaining < 60 ? .red : .primary)

            Text("remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button {
                session.togglePause()
            } label: {
                Label(
                    session.isPaused ? "Resume" : "Pause",
                    systemImage: session.isPaused ? "play.fill" : "pause.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                completeCurrentStep()
            } label: {
                Label("Next Step", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var upcomingStepsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Steps")
                .font(.headline)

            ForEach(upcomingSteps) { scheduledStep in
                HStack(spacing: 12) {
                    Image(systemName: scheduledStep.step.stepType.iconName)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(scheduledStep.step.name)
                            .font(.subheadline)
                        Text("\(scheduledStep.step.durationInMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Baking Complete!")
                .font(.title)
                .fontWeight(.bold)

            Text("Your \(session.recipe.name) is ready!")
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                onComplete()
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    // MARK: - Computed Properties

    private var timeRemainingFormatted: String {
        let minutes = Int(session.timeRemaining) / 60
        let seconds = Int(session.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var upcomingSteps: [ScheduledStep] {
        let nextIndex = session.currentStepIndex + 1
        guard nextIndex < session.schedule.count else { return [] }
        return Array(session.schedule[nextIndex..<min(nextIndex + 3, session.schedule.count)])
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !session.isPaused && session.timeRemaining > 0 else { return }

            session.timeRemaining -= 1

            if session.timeRemaining <= 0 {
                stepTimerCompleted()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func stepTimerCompleted() {
        // Send notification
        NotificationManager.shared.sendStepCompletionNotification(
            stepName: session.currentStep?.step.name ?? "Step"
        )
    }

    private func completeCurrentStep() {
        session.startNextStep()
        if session.isComplete {
            stopTimer()
        }
    }
}

#Preview {
    let recipe = Recipe(
        name: "Neapolitan Pizza",
        bakingSteps: [
            BakingStep(name: "Mix", instructions: "Mix all ingredients", durationInMinutes: 10, stepType: .mixing, order: 0),
            BakingStep(name: "First Proof", instructions: "Let rise in warm place", durationInMinutes: 60, temperatureCelsius: 25, stepType: .firstProof, order: 1),
            BakingStep(name: "Bake", instructions: "Bake until golden", durationInMinutes: 15, temperatureCelsius: 250, stepType: .baking, order: 2)
        ],
        servings: 4,
        servingType: .pizza
    )

    let session = BakingSession(
        recipe: recipe,
        targetServings: 4,
        targetDateTime: Date().addingTimeInterval(3600),
        doughResiduePercentage: 5.0
    )

    return ActiveBakingView(session: session, onComplete: {})
}
