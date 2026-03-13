//
//  ContentView.swift
//  ThreeItemDailyToDoList
//
//  Created by Tam Le on 3/12/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyPlan.date, order: .reverse) private var plans: [DailyPlan]

    @State private var isPresentingEditor = false
    @State private var isPresentingHistory = false
    @State private var showCelebration = false

    private let calendar = Calendar.current

    private var todayPlan: DailyPlan? {
        let today = calendar.startOfDay(for: .now)
        return plans.first(where: { calendar.isDate($0.date, inSameDayAs: today) })
    }

    private var progressText: String {
        let completedCount = todayPlan?.completedCount ?? 0
        return "\(completedCount) of 3 completed"
    }

    var body: some View {
        NavigationStack {
            contentLayer
            .navigationTitle("Top 3")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel("Open history")
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                TaskEditorView(
                    initialTasks: todayPlan?.tasks ?? DailyPlan.emptyTasks(),
                    onSave: saveTodayTasks
                )
            }
            .sheet(isPresented: $isPresentingHistory) {
                HistoryView(plans: plans)
            }
            .overlay(alignment: .top) {
                if showCelebration {
                    celebrationBanner
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.82), value: showCelebration)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: todayPlan?.completedCount ?? 0)
            .onChange(of: todayPlan?.completedCount ?? 0) { _, newValue in
                if newValue == 3 {
                    triggerCelebration()
                    fireSuccessFeedback()
                }
            }
        }
    }

    private var contentLayer: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            mainScrollContent
        }
    }

    private var mainScrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                if let todayPlan {
                    todayPlanSection(todayPlan)
                } else {
                    emptyStateSection
                }

                if let todayPlan, todayPlan.isFullyCompleted {
                    completionSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.primaryText)

                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)

                Text(progressText)
                    .font(.headline)
                    .foregroundStyle(Color.accentBlue)
            }

            Spacer()

            ProgressRingView(progress: CGFloat(todayPlan?.completedCount ?? 0) / 3.0)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
        )
    }

    private func todayPlanSection(_ plan: DailyPlan) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(plan.tasks.enumerated()), id: \.element.id) { index, task in
                TaskCardView(
                    number: index + 1,
                    task: task,
                    onToggle: { toggleTaskCompletion(at: index) },
                    onReset: { resetTask(at: index) }
                )
            }

            Button {
                isPresentingEditor = true
            } label: {
                Text(plan.completedCount == 3 ? "Prepare Tomorrow's 3" : "Edit Tasks")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist.checked")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(Color.accentBlue)
                .padding(22)
                .background(
                    Circle()
                        .fill(Color.accentBlue.opacity(0.12))
                )

            VStack(spacing: 8) {
                Text("Start your day with 3 clear priorities.")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.primaryText)

                Text("Pick only the three most important things to finish today.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.secondaryText)
            }

            Button {
                isPresentingEditor = true
            } label: {
                Text("Add Today's 3")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
        )
    }

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You finished your top 3 today.")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.primaryText)

            Text("Current streak: \(currentStreak) day\(currentStreak == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            Button {
                isPresentingEditor = true
            } label: {
                Text("Prepare Tomorrow's 3")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.successGreen.opacity(0.12))
        )
    }

    private var celebrationBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
            Text("Top 3 complete")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color.accentBlue)
        )
        .shadow(color: Color.accentBlue.opacity(0.28), radius: 12, x: 0, y: 6)
    }

    private var greeting: String {
        let hour = calendar.component(.hour, from: .now)

        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    private var currentStreak: Int {
        let completedDays = Set(
            plans
                .filter(\.isFullyCompleted)
                .map { calendar.startOfDay(for: $0.date) }
        )

        guard !completedDays.isEmpty else {
            return 0
        }

        let anchor: Date
        let today = calendar.startOfDay(for: .now)

        if completedDays.contains(today) {
            anchor = today
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  completedDays.contains(yesterday) {
            anchor = yesterday
        } else {
            return 0
        }

        var streak = 0
        var cursor = anchor

        while completedDays.contains(cursor) {
            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    private func saveTodayTasks(_ tasks: [FocusTask]) {
        let sanitizedTasks = tasks.map { task in
            FocusTask(
                id: task.id,
                title: task.title.trimmingCharacters(in: .whitespacesAndNewlines),
                note: task.note.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: task.isCompleted
            )
        }

        let today = calendar.startOfDay(for: .now)

        if let todayPlan {
            todayPlan.tasks = sanitizedTasks
        } else {
            modelContext.insert(DailyPlan(date: today, tasks: sanitizedTasks))
        }

        try? modelContext.save()
        isPresentingEditor = false
    }

    private func toggleTaskCompletion(at index: Int) {
        guard let todayPlan, todayPlan.tasks.indices.contains(index) else {
            return
        }

        var updatedTasks = todayPlan.tasks
        updatedTasks[index].isCompleted.toggle()
        todayPlan.tasks = updatedTasks

        fireSelectionFeedback()
        try? modelContext.save()
    }

    private func resetTask(at index: Int) {
        guard let todayPlan, todayPlan.tasks.indices.contains(index) else {
            return
        }

        var updatedTasks = todayPlan.tasks
        updatedTasks[index].isCompleted = false
        todayPlan.tasks = updatedTasks

        try? modelContext.save()
    }

    private func triggerCelebration() {
        showCelebration = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCelebration = false
        }
    }

    private func fireSelectionFeedback() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    private func fireSuccessFeedback() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}

private struct TaskCardView: View {
    let number: Int
    let task: FocusTask
    let onToggle: @MainActor () -> Void
    let onReset: @MainActor () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.successGreen : Color.accentBlue.opacity(0.35), lineWidth: 2)
                        .frame(width: 32, height: 32)

                    if task.isCompleted {
                        Circle()
                            .fill(Color.successGreen)
                            .frame(width: 32, height: 32)

                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.spring(response: 0.28, dampingFraction: 0.72), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text("Task \(number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)

                Text(task.title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.primaryText.opacity(task.isCompleted ? 0.55 : 1))
                    .strikethrough(task.isCompleted, color: Color.primaryText.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText.opacity(task.isCompleted ? 0.65 : 1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 10)
        )
        .opacity(task.isCompleted ? 0.86 : 1)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if task.isCompleted {
                Button("Reset", action: onReset)
                    .tint(.gray)
            }
        }
    }
}

private struct ProgressRingView: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentBlue.opacity(0.14), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentBlue,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(Int(progress * 3))")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.primaryText)

                Text("/ 3")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .frame(width: 94, height: 94)
    }
}

private struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draftTasks: [FocusTask]
    @FocusState private var focusedIndex: Int?

    let onSave: ([FocusTask]) -> Void

    init(initialTasks: [FocusTask], onSave: @escaping ([FocusTask]) -> Void) {
        _draftTasks = State(initialValue: initialTasks)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose Your 3 Focus Items")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.primaryText)

                            Text("Pick only the 3 most important things for today.")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                        }

                        ForEach(Array(draftTasks.enumerated()), id: \.element.id) { index, task in
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Priority \(index + 1)")
                                        .font(.headline)
                                        .foregroundStyle(Color.primaryText)

                                    Spacer()

                                    HStack(spacing: 10) {
                                        reorderButton(
                                            systemName: "arrow.up",
                                            disabled: index == 0
                                        ) {
                                            moveTask(from: index, to: index - 1)
                                        }

                                        reorderButton(
                                            systemName: "arrow.down",
                                            disabled: index == draftTasks.count - 1
                                        ) {
                                            moveTask(from: index, to: index + 1)
                                        }
                                    }
                                }

                                TextField("Task title", text: binding(for: index).title)
                                    .textInputAutocapitalization(.sentences)
                                    .focused($focusedIndex, equals: index)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.white)
                                    )

                                TextField("Optional note", text: binding(for: index).note, axis: .vertical)
                                    .textInputAutocapitalization(.sentences)
                                    .lineLimit(2...4)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.white)
                                    )
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Color.cardBackground)
                                    .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Today's Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draftTasks)
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                focusedIndex = 0
            }
        }
    }

    private var canSave: Bool {
        draftTasks.allSatisfy { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func binding(for index: Int) -> (title: Binding<String>, note: Binding<String>) {
        (
            title: Binding(
                get: { draftTasks[index].title },
                set: { draftTasks[index].title = $0 }
            ),
            note: Binding(
                get: { draftTasks[index].note },
                set: { draftTasks[index].note = $0 }
            )
        )
    }

    private func moveTask(from source: Int, to destination: Int) {
        guard draftTasks.indices.contains(source), draftTasks.indices.contains(destination) else {
            return
        }

        let task = draftTasks.remove(at: source)
        draftTasks.insert(task, at: destination)
    }

    private func reorderButton(systemName: String, disabled: Bool, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(disabled ? Color.secondaryText.opacity(0.35) : Color.accentBlue)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(Color.accentBlue.opacity(disabled ? 0.08 : 0.12))
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct HistoryView: View {
    let plans: [DailyPlan]

    @Environment(\.dismiss) private var dismiss
    @State private var filter: HistoryFilter = .all

    private var filteredPlans: [DailyPlan] {
        switch filter {
        case .all:
            return plans
        case .completed:
            return plans.filter(\.isFullyCompleted)
        case .missed:
            return plans.filter { !$0.isFullyCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    Picker("History Filter", selection: $filter) {
                        ForEach(HistoryFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    if filteredPlans.isEmpty {
                        Spacer()

                        Text("No saved days yet.")
                            .font(.headline)
                            .foregroundStyle(Color.secondaryText)

                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                ForEach(filteredPlans, id: \.persistentModelID) { plan in
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack {
                                            Text(plan.date.formatted(.dateTime.month(.wide).day().year()))
                                                .font(.headline)
                                                .foregroundStyle(Color.primaryText)

                                            Spacer()

                                            Text("\(plan.completedCount)/3")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(plan.isFullyCompleted ? Color.successGreen : Color.accentBlue)
                                        }

                                        ForEach(Array(plan.tasks.enumerated()), id: \.element.id) { index, task in
                                            HStack(alignment: .top, spacing: 10) {
                                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(task.isCompleted ? Color.successGreen : Color.accentBlue.opacity(0.45))

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("\(index + 1). \(task.title)")
                                                        .font(.subheadline.weight(.medium))
                                                        .foregroundStyle(Color.primaryText)

                                                    if !task.note.isEmpty {
                                                        Text(task.note)
                                                            .font(.caption)
                                                            .foregroundStyle(Color.secondaryText)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .fill(Color.cardBackground)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, 18)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case completed
    case missed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .completed:
            return "Completed"
        case .missed:
            return "Missed"
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentBlue)
                    .scaleEffect(configuration.isPressed ? 0.985 : 1)
                    .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
            )
    }
}

private extension Color {
    static let appBackground = Color(red: 0.97, green: 0.98, blue: 0.99)
    static let cardBackground = Color.white
    static let accentBlue = Color(red: 0.25, green: 0.48, blue: 0.95)
    static let primaryText = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let secondaryText = Color(red: 0.46, green: 0.5, blue: 0.57)
    static let successGreen = Color(red: 0.35, green: 0.67, blue: 0.47)
}
