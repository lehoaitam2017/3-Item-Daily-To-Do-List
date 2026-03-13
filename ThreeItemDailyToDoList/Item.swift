//
//  Item.swift
//  ThreeItemDailyToDoList
//
//  Created by Tam Le on 3/12/26.
//

import Foundation
import SwiftData

struct FocusTask: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var note: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String = "",
        note: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
    }
}

@Model
final class DailyPlan {
    var date: Date
    var tasks: [FocusTask]

    init(date: Date, tasks: [FocusTask] = DailyPlan.emptyTasks()) {
        self.date = date
        self.tasks = tasks
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var isFullyCompleted: Bool {
        completedCount == tasks.count && !tasks.isEmpty
    }

    static func emptyTasks() -> [FocusTask] {
        [FocusTask(), FocusTask(), FocusTask()]
    }
}
