//
//  ThreeItemDailyToDoListApp.swift
//  ThreeItemDailyToDoList
//
//  Created by Tam Le on 3/12/26.
//

import SwiftUI
import SwiftData

@main
struct ThreeItemDailyToDoListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DailyPlan.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct AppRootView: View {
    @State private var showSplashScreen = true

    var body: some View {
        ZStack {
            ContentView()

            if showSplashScreen {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            guard showSplashScreen else {
                return
            }

            try? await Task.sleep(for: .seconds(2))

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashScreen = false
            }
        }
    }
}

private struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.98, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.9, green: 0.2, blue: 0.22).opacity(0.12))
                .frame(width: 240, height: 240)
                .offset(x: 110, y: -240)
                .blur(radius: 6)

            Circle()
                .fill(Color(red: 0.11, green: 0.35, blue: 0.86).opacity(0.14))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: 260)
                .blur(radius: 8)

            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 168, height: 168)
                        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 16)

                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(Color(red: 0.11, green: 0.35, blue: 0.86))
                        .frame(width: 132, height: 132)

                    Text("3")
                        .font(.system(size: 70, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color(red: 0.9, green: 0.2, blue: 0.22))
                        .background(Circle().fill(.white).frame(width: 34, height: 34))
                        .offset(x: 48, y: 48)
                }

                VStack(spacing: 10) {
                    Text("Three Item Daily To-Do List")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color(red: 0.12, green: 0.14, blue: 0.18))

                    Text("Choose 3 things. Finish what matters.")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.46, green: 0.5, blue: 0.57))
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
