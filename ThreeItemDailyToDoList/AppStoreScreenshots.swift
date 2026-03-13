import SwiftUI

private struct ScreenshotTask: Identifiable {
    let id = UUID()
    let title: String
    let note: String
    let isCompleted: Bool
}

private struct ScreenshotDay: Identifiable {
    let id = UUID()
    let title: String
    let progress: String
    let tasks: [ScreenshotTask]
    let completed: Bool
}

private enum ScreenshotDevice {
    case phone
    case pad
    case watch

    var canvasSize: CGSize {
        switch self {
        case .phone:
            return CGSize(width: 1284, height: 2778)
        case .pad:
            return CGSize(width: 2048, height: 2732)
        case .watch:
            return CGSize(width: 416, height: 496)
        }
    }

    var contentWidth: CGFloat {
        switch self {
        case .phone:
            return 1120
        case .pad:
            return 1780
        case .watch:
            return 360
        }
    }

    var mockupWidth: CGFloat {
        switch self {
        case .phone:
            return 930
        case .pad:
            return 1280
        case .watch:
            return 214
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .phone:
            return 180
        case .pad:
            return 150
        case .watch:
            return 28
        }
    }
}

private struct AppStoreScreenshotScene: View {
    let device: ScreenshotDevice
    let title: String
    let subtitle: String
    let detail: String
    let variant: ScreenshotVariant

    var body: some View {
        let size = device.canvasSize

        ZStack {
            screenshotBackground

            VStack(spacing: 42) {
                VStack(spacing: 20) {
                    Text(title)
                        .font(.system(size: headlineSize, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ScreenshotPalette.ink)
                        .frame(maxWidth: device.contentWidth)

                    Text(subtitle)
                        .font(.system(size: subtitleSize, weight: .medium, design: .rounded))
                        .foregroundStyle(ScreenshotPalette.muted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: device.contentWidth)

                    Text(detail)
                        .font(.system(size: detailSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(ScreenshotPalette.red)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(
                            Capsule(style: .continuous)
                                .fill(ScreenshotPalette.red.opacity(0.12))
                        )
                }
                .padding(.top, device.topPadding)

                Spacer(minLength: 0)

                DeviceMockup(device: device) {
                    variant.body(device: device)
                }
                .frame(width: device.mockupWidth)

                Spacer(minLength: device == .phone ? 140 : 120)
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(width: size.width, height: size.height)
    }

    private var headlineSize: CGFloat {
        switch device {
        case .phone:
            return 120
        case .pad:
            return 110
        case .watch:
            return 28
        }
    }

    private var subtitleSize: CGFloat {
        switch device {
        case .phone:
            return 48
        case .pad:
            return 42
        case .watch:
            return 14
        }
    }

    private var detailSize: CGFloat {
        switch device {
        case .phone:
            return 34
        case .pad:
            return 30
        case .watch:
            return 12
        }
    }

    private var screenshotBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(ScreenshotPalette.blue.opacity(0.14))
                .frame(width: 820, height: 820)
                .blur(radius: 40)
                .offset(x: -360, y: 840)

            Circle()
                .fill(ScreenshotPalette.red.opacity(0.12))
                .frame(width: 640, height: 640)
                .blur(radius: 28)
                .offset(x: 390, y: -880)

            RoundedRectangle(cornerRadius: 220, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ScreenshotPalette.blue.opacity(0.08),
                            ScreenshotPalette.red.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(-12))
                .scaleEffect(1.2)
        }
        .ignoresSafeArea()
    }
}

private struct DeviceMockup<Content: View>: View {
    let device: ScreenshotDevice
    @ViewBuilder let content: Content

    var body: some View {
        let cornerRadius: CGFloat = device == .phone ? 110 : 76

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.black)

            RoundedRectangle(cornerRadius: cornerRadius - 18, style: .continuous)
                .fill(Color.white)
                .padding(16)
                .overlay(alignment: .top) {
                    if device == .phone {
                        Capsule(style: .continuous)
                            .fill(Color.black)
                            .frame(width: 220, height: 38)
                            .padding(.top, 28)
                    } else if device == .watch {
                        Capsule(style: .continuous)
                            .fill(Color.black)
                            .frame(width: 72, height: 8)
                            .padding(.top, 12)
                    }
                }
                .overlay {
                    content
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 18, style: .continuous))
                        .padding(16)
                }
        }
        .shadow(color: Color.black.opacity(0.14), radius: 40, x: 0, y: 24)
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    private var aspectRatio: CGFloat {
        switch device {
        case .phone:
            return 430.0 / 932.0
        case .pad:
            return 1024.0 / 1366.0
        case .watch:
            return 208.0 / 248.0
        }
    }
}

private enum ScreenshotVariant {
    case emptyState
    case editor
    case homeReady
    case progressOne
    case progressTwo
    case notes
    case reorder
    case calmLayout
    case celebration
    case history
    case watchSummary

    @ViewBuilder
    func body(device: ScreenshotDevice) -> some View {
        switch self {
        case .emptyState:
            ScreenshotHomeView(
                greeting: "Good Morning",
                progress: "0 of 3 completed",
                tasks: [],
                highlight: .empty
            )
        case .editor:
            ScreenshotEditorView(reorderAccent: false)
        case .homeReady:
            ScreenshotHomeView(
                greeting: "Good Morning",
                progress: "0 of 3 completed",
                tasks: ScreenshotSamples.todayTasks,
                highlight: .none
            )
        case .progressOne:
            ScreenshotHomeView(
                greeting: "Good Afternoon",
                progress: "1 of 3 completed",
                tasks: ScreenshotSamples.progressOneTasks,
                highlight: .ring
            )
        case .progressTwo:
            ScreenshotHomeView(
                greeting: "Good Afternoon",
                progress: "2 of 3 completed",
                tasks: ScreenshotSamples.progressTwoTasks,
                highlight: .ring
            )
        case .notes:
            ScreenshotHomeView(
                greeting: "Good Morning",
                progress: "0 of 3 completed",
                tasks: ScreenshotSamples.notesTasks,
                highlight: .notes
            )
        case .reorder:
            ScreenshotEditorView(reorderAccent: true)
        case .calmLayout:
            ScreenshotHomeView(
                greeting: "Good Evening",
                progress: "1 of 3 completed",
                tasks: ScreenshotSamples.calmTasks,
                highlight: .none
            )
        case .celebration:
            ScreenshotHomeView(
                greeting: "Good Evening",
                progress: "3 of 3 completed",
                tasks: ScreenshotSamples.doneTasks,
                highlight: .celebration
            )
        case .history:
            ScreenshotHistoryView(days: ScreenshotSamples.historyDays)
        case .watchSummary:
            ScreenshotWatchView()
        }
    }
}

private struct ScreenshotHomeView: View {
    enum Highlight {
        case none
        case ring
        case notes
        case celebration
        case empty
    }

    let greeting: String
    let progress: String
    let tasks: [ScreenshotTask]
    let highlight: Highlight

    private var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(ScreenshotPalette.ink)

                        Text("Thursday, March 13")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(ScreenshotPalette.muted)

                        Text(progress)
                            .font(.headline)
                            .foregroundStyle(ScreenshotPalette.blue)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(ScreenshotPalette.blue.opacity(0.14), lineWidth: 14)

                        Circle()
                            .trim(from: 0, to: CGFloat(completedCount) / 3.0)
                            .stroke(ScreenshotPalette.blue, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 0) {
                            Text("\(completedCount)")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(ScreenshotPalette.ink)
                            Text("/ 3")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(ScreenshotPalette.muted)
                        }
                    }
                    .frame(width: 130, height: 130)
                    .overlay {
                        if highlight == .ring {
                            Circle()
                                .stroke(ScreenshotPalette.red, style: StrokeStyle(lineWidth: 5, dash: [8, 8]))
                                .padding(-12)
                        }
                    }
                }
                .padding(28)
                .background(ScreenshotPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                if highlight == .empty {
                    VStack(spacing: 18) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(ScreenshotPalette.blue)
                            .padding(26)
                            .background(Circle().fill(ScreenshotPalette.blue.opacity(0.12)))

                        Text("Start your day with 3 clear priorities.")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(ScreenshotPalette.ink)

                        Text("Pick only the three most important things to finish today.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(ScreenshotPalette.muted)

                        Text("Add Today's 3")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(ScreenshotPalette.blue)
                            )
                    }
                    .padding(30)
                    .background(ScreenshotPalette.card)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                } else {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(task.isCompleted ? ScreenshotPalette.green : ScreenshotPalette.blue.opacity(0.35), lineWidth: 3)
                                    .frame(width: 36, height: 36)

                                if task.isCompleted {
                                    Circle()
                                        .fill(ScreenshotPalette.green)
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Task \(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(ScreenshotPalette.muted)

                                Text(task.title)
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(ScreenshotPalette.ink.opacity(task.isCompleted ? 0.55 : 1))
                                    .strikethrough(task.isCompleted, color: ScreenshotPalette.ink.opacity(0.35))

                                if !task.note.isEmpty {
                                    Text(task.note)
                                        .font(.subheadline)
                                        .foregroundStyle(ScreenshotPalette.muted)
                                }
                            }

                            Spacer()
                        }
                        .padding(22)
                        .background(ScreenshotPalette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .overlay {
                            if highlight == .notes && !task.note.isEmpty {
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(ScreenshotPalette.red, lineWidth: 4)
                            }
                        }
                    }

                    if highlight == .celebration {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("You finished your top 3 today.")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(ScreenshotPalette.ink)

                            Text("Current streak: 4 days")
                                .font(.headline)
                                .foregroundStyle(ScreenshotPalette.muted)
                        }
                        .padding(24)
                        .background(ScreenshotPalette.green.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    }
                }
            }
            .padding(24)
        }
        .background(ScreenshotPalette.background)
    }
}

private struct ScreenshotEditorView: View {
    let reorderAccent: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Your 3 Focus Items")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(ScreenshotPalette.ink)

                    Text("Pick only the 3 most important things for today.")
                        .font(.title3)
                        .foregroundStyle(ScreenshotPalette.muted)
                }
                .padding(.top, 18)

                ForEach(Array(ScreenshotSamples.editorTasks.enumerated()), id: \.element.id) { index, task in
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Priority \(index + 1)")
                                .font(.headline)
                                .foregroundStyle(ScreenshotPalette.ink)

                            Spacer()

                            HStack(spacing: 10) {
                                CircleButton(systemName: "arrow.up")
                                CircleButton(systemName: "arrow.down")
                            }
                        }

                        Text(task.title)
                            .font(.headline)
                            .foregroundStyle(ScreenshotPalette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(task.note)
                            .font(.subheadline)
                            .foregroundStyle(ScreenshotPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(20)
                    .background(ScreenshotPalette.card)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay {
                        if reorderAccent && index == 0 {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(ScreenshotPalette.red, lineWidth: 4)
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(ScreenshotPalette.background)
    }
}

private struct ScreenshotHistoryView: View {
    let days: [ScreenshotDay]

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                FilterCapsule(title: "All", selected: true)
                FilterCapsule(title: "Completed", selected: false)
                FilterCapsule(title: "Missed", selected: false)
            }
            .padding(.top, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(days) { day in
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text(day.title)
                                    .font(.headline)
                                    .foregroundStyle(ScreenshotPalette.ink)

                                Spacer()

                                Text(day.progress)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(day.completed ? ScreenshotPalette.green : ScreenshotPalette.blue)
                            }

                            ForEach(Array(day.tasks.enumerated()), id: \.element.id) { index, task in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(task.isCompleted ? ScreenshotPalette.green : ScreenshotPalette.blue.opacity(0.45))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(index + 1). \(task.title)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(ScreenshotPalette.ink)

                                        if !task.note.isEmpty {
                                            Text(task.note)
                                                .font(.caption)
                                                .foregroundStyle(ScreenshotPalette.muted)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(ScreenshotPalette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 22)
        .background(ScreenshotPalette.background)
    }
}

private struct ScreenshotWatchView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Top 3")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(ScreenshotPalette.ink)

                Spacer()

                Text("2/3")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(ScreenshotPalette.blue)
            }

            ForEach(Array(ScreenshotSamples.watchTasks.enumerated()), id: \.element.id) { index, task in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(task.isCompleted ? ScreenshotPalette.green : ScreenshotPalette.blue.opacity(0.45))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(index + 1). \(task.title)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(ScreenshotPalette.ink)
                            .lineLimit(2)

                        if !task.note.isEmpty {
                            Text(task.note)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(ScreenshotPalette.muted)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ScreenshotPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Text("Check off tasks from your wrist")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(ScreenshotPalette.red)
                )
        }
        .padding(12)
        .background(ScreenshotPalette.background)
    }
}

private struct CircleButton: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(ScreenshotPalette.blue)
            .frame(width: 34, height: 34)
            .background(
                Circle()
                    .fill(ScreenshotPalette.blue.opacity(0.12))
            )
    }
}

private struct FilterCapsule: View {
    let title: String
    let selected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(selected ? .white : ScreenshotPalette.muted)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(selected ? ScreenshotPalette.blue : ScreenshotPalette.card)
            )
    }
}

private enum ScreenshotPalette {
    static let background = Color(red: 0.97, green: 0.98, blue: 0.99)
    static let card = Color.white
    static let blue = Color(red: 0.21, green: 0.43, blue: 0.93)
    static let red = Color(red: 0.91, green: 0.24, blue: 0.25)
    static let green = Color(red: 0.35, green: 0.67, blue: 0.47)
    static let ink = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let muted = Color(red: 0.46, green: 0.5, blue: 0.57)
}

private enum ScreenshotSamples {
    static let todayTasks = [
        ScreenshotTask(title: "Finish project proposal", note: "Send final draft before 3 PM", isCompleted: false),
        ScreenshotTask(title: "30-minute workout", note: "Core and mobility session", isCompleted: false),
        ScreenshotTask(title: "Call mom", note: "Check in before dinner", isCompleted: false)
    ]

    static let progressOneTasks = [
        ScreenshotTask(title: "Finish project proposal", note: "Sent to the team", isCompleted: true),
        ScreenshotTask(title: "30-minute workout", note: "Core and mobility session", isCompleted: false),
        ScreenshotTask(title: "Call mom", note: "Check in before dinner", isCompleted: false)
    ]

    static let progressTwoTasks = [
        ScreenshotTask(title: "Finish project proposal", note: "Sent to the team", isCompleted: true),
        ScreenshotTask(title: "30-minute workout", note: "Completed at lunch", isCompleted: true),
        ScreenshotTask(title: "Call mom", note: "Check in before dinner", isCompleted: false)
    ]

    static let doneTasks = [
        ScreenshotTask(title: "Finish project proposal", note: "Sent to the team", isCompleted: true),
        ScreenshotTask(title: "30-minute workout", note: "Completed at lunch", isCompleted: true),
        ScreenshotTask(title: "Call mom", note: "Talked for 15 minutes", isCompleted: true)
    ]

    static let notesTasks = [
        ScreenshotTask(title: "Study chapter 5", note: "Focus on summary notes and diagrams", isCompleted: false),
        ScreenshotTask(title: "Email professor", note: "Ask about the project timeline", isCompleted: false),
        ScreenshotTask(title: "Pick up groceries", note: "Fruit, pasta, yogurt", isCompleted: false)
    ]

    static let calmTasks = [
        ScreenshotTask(title: "Prepare tomorrow's lesson", note: "Print worksheets and examples", isCompleted: true),
        ScreenshotTask(title: "Family calendar update", note: "Add weekend plans", isCompleted: false),
        ScreenshotTask(title: "10-minute tidy up", note: "", isCompleted: false)
    ]

    static let editorTasks = [
        ScreenshotTask(title: "Finish project proposal", note: "Send final draft before 3 PM", isCompleted: false),
        ScreenshotTask(title: "30-minute workout", note: "Core and mobility session", isCompleted: false),
        ScreenshotTask(title: "Call mom", note: "Check in before dinner", isCompleted: false)
    ]

    static let historyDays = [
        ScreenshotDay(
            title: "March 13, 2026",
            progress: "3/3",
            tasks: doneTasks,
            completed: true
        ),
        ScreenshotDay(
            title: "March 12, 2026",
            progress: "2/3",
            tasks: progressTwoTasks,
            completed: false
        ),
        ScreenshotDay(
            title: "March 11, 2026",
            progress: "3/3",
            tasks: [
                ScreenshotTask(title: "Review budget", note: "15-minute check-in", isCompleted: true),
                ScreenshotTask(title: "Walk 5,000 steps", note: "Afternoon walk", isCompleted: true),
                ScreenshotTask(title: "Read 20 pages", note: "Before bed", isCompleted: true)
            ],
            completed: true
        )
    ]

    static let watchTasks = [
        ScreenshotTask(title: "Finish proposal", note: "Due 3 PM", isCompleted: true),
        ScreenshotTask(title: "30-min workout", note: "Core", isCompleted: true),
        ScreenshotTask(title: "Call mom", note: "Tonight", isCompleted: false)
    ]
}

#Preview("iPhone 01") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Focus on just 3 tasks",
        subtitle: "Start each day with clear priorities.",
        detail: "Choose only what matters most",
        variant: .emptyState
    )
}

#Preview("iPhone 02") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Plan your day in seconds",
        subtitle: "A simple editor keeps you intentional.",
        detail: "Three tasks. No clutter.",
        variant: .editor
    )
}

#Preview("iPhone 03") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "See your top priorities",
        subtitle: "Your day is always clear at a glance.",
        detail: "One screen. Three focus items.",
        variant: .homeReady
    )
}

#Preview("iPhone 04") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Track progress instantly",
        subtitle: "Stay motivated with clear visual progress.",
        detail: "Know exactly where you stand",
        variant: .progressOne
    )
}

#Preview("iPhone 05") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Keep momentum all day",
        subtitle: "Two done, one left. Finish strong.",
        detail: "Small wins feel satisfying",
        variant: .progressTwo
    )
}

#Preview("iPhone 06") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Notes without the noise",
        subtitle: "Add just enough context for each task.",
        detail: "Helpful details, still minimal",
        variant: .notes
    )
}

#Preview("iPhone 07") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Reorder what matters most",
        subtitle: "Adjust your priorities as the day changes.",
        detail: "Keep the top task on top",
        variant: .reorder
    )
}

#Preview("iPhone 08") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "A calm daily layout",
        subtitle: "Less overwhelm, more clarity and focus.",
        detail: "Built for a quieter workflow",
        variant: .calmLayout
    )
}

#Preview("iPhone 09") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Finish your top 3",
        subtitle: "Celebrate progress at the end of the day.",
        detail: "Completion feels rewarding",
        variant: .celebration
    )
}

#Preview("iPhone 10") {
    AppStoreScreenshotScene(
        device: .phone,
        title: "Review your focus history",
        subtitle: "Look back at what you completed over time.",
        detail: "See consistency build up",
        variant: .history
    )
}

#Preview("iPad 01") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "A calmer way to plan",
        subtitle: "Use a larger canvas to focus on less.",
        detail: "Intentional by design",
        variant: .emptyState
    )
}

#Preview("iPad 02") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Choose only 3 priorities",
        subtitle: "Set the three tasks that deserve your attention.",
        detail: "Make your day easier to start",
        variant: .editor
    )
}

#Preview("iPad 03") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Your day at a glance",
        subtitle: "Greeting, date, progress, and tasks in one view.",
        detail: "Everything important is visible",
        variant: .homeReady
    )
}

#Preview("iPad 04") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Big cards, clear focus",
        subtitle: "Readable task cards make the day feel lighter.",
        detail: "Easy to scan, easy to act",
        variant: .calmLayout
    )
}

#Preview("iPad 05") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Progress that feels good",
        subtitle: "Watch your day move from intention to done.",
        detail: "Momentum stays visible",
        variant: .progressOne
    )
}

#Preview("iPad 06") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Designed to reduce overwhelm",
        subtitle: "No endless list. Just your top three.",
        detail: "A simpler daily planner",
        variant: .emptyState
    )
}

#Preview("iPad 07") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Edit tasks anytime",
        subtitle: "Change titles, notes, and order in seconds.",
        detail: "Flexible when plans shift",
        variant: .reorder
    )
}

#Preview("iPad 08") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Celebrate what you finish",
        subtitle: "Completing your top three feels genuinely satisfying.",
        detail: "End the day on a win",
        variant: .celebration
    )
}

#Preview("iPad 09") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Build consistency over time",
        subtitle: "History helps you spot progress and patterns.",
        detail: "Stay accountable with less friction",
        variant: .history
    )
}

#Preview("iPad 10") {
    AppStoreScreenshotScene(
        device: .pad,
        title: "Minimal planner for real life",
        subtitle: "Useful for work, school, home, or everyday focus.",
        detail: "Simple enough to use daily",
        variant: .progressTwo
    )
}

#Preview("Watch 01") {
    AppStoreScreenshotScene(
        device: .watch,
        title: "Stay focused",
        subtitle: "Your top 3 on Apple Watch.",
        detail: "Quick progress at a glance",
        variant: .watchSummary
    )
}
