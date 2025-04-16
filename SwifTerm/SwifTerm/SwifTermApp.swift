import SwiftUI

@main
struct SwiftTermApp: App {
    @StateObject private var shellState = ShellState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shellState)
        }
    }
}
