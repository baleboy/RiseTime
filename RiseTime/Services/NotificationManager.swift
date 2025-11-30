//
//  NotificationManager.swift
//  RiseTime
//
//  Service for managing local notifications for baking reminders
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }

    // MARK: - Send Notifications

    func sendStepCompletionNotification(stepName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Step Complete!"
        content.body = "\(stepName) is done. Time for the next step."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    // MARK: - Schedule Future Notifications

    func scheduleStepNotifications(for schedule: [ScheduledStep]) {
        // Remove all pending notifications
        notificationCenter.removeAllPendingNotificationRequests()

        for scheduledStep in schedule {
            let content = UNMutableNotificationContent()
            content.title = "Time for: \(scheduledStep.step.name)"
            content.body = scheduledStep.step.instructions
            content.sound = .default

            // Schedule for end time of this step
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: scheduledStep.endTime
                ),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: scheduledStep.id.uuidString,
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }

    // MARK: - Cancel Notifications

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
