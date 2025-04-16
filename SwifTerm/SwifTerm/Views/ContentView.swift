import SwiftUI

struct ContentView: View {
    @EnvironmentObject var shellState: ShellState

    var body: some View {
        TerminalView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ShellState())
}