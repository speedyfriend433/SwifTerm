import SwiftUI

struct CommandInputView: View {
    @EnvironmentObject var shellState: ShellState
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(shellState.currentPrompt)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(shellState.currentTheme.prompt)
                .padding(.leading, 5)

            TextField("", text: $shellState.currentCommand)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(shellState.currentTheme.foreground)
                .tint(shellState.currentTheme.cursor)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused($isTextFieldFocused)
                .onSubmit {
                    shellState.executeCommand()
                    isTextFieldFocused = true
                }
                .padding(.vertical, 8)
        }
        .background(shellState.currentTheme.background.opacity(0.8))
        .onAppear {
            isTextFieldFocused = true
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    if abs(value.translation.height) > abs(value.translation.width) * 2 {
                        if value.translation.height < 0 {
                            shellState.navigateHistory(up: true)
                        } else if value.translation.height > 0 {
                            shellState.navigateHistory(up: false)
                        }
                    }
                }
        )
        .onTapGesture {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    CommandInputView()
        .environmentObject(ShellState())
        .background(Color.black)
}