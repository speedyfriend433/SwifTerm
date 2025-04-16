import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var shellState: ShellState
    @State private var scrollToBottom: UUID?
    @State private var showThemeSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SwiftTerm")
                    .font(.headline)
                    .foregroundColor(shellState.currentTheme.foreground)
                
                Spacer()
                
                Button(action: {
                    showThemeSelector.toggle()
                }) {
                    Image(systemName: "paintpalette")
                        .foregroundColor(shellState.currentTheme.foreground)
                }
                .popover(isPresented: $showThemeSelector) {
                    ThemeSelectorView()
                        .frame(width: 200, height: 200)
                        .environmentObject(shellState)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(shellState.currentTheme.background.opacity(0.9))
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(shellState.outputLines) { line in
                            Text(line.text)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(line.color)
                                .padding(.horizontal, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(line.id)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onChange(of: shellState.outputLines.count) { _ in
                    if let lastLineId = shellState.outputLines.last?.id {
                        scrollToBottom = lastLineId
                        withAnimation {
                            proxy.scrollTo(scrollToBottom, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastLineId = shellState.outputLines.last?.id {
                        scrollToBottom = lastLineId
                        proxy.scrollTo(scrollToBottom, anchor: .bottom)
                    }
                }
            }
            
            CommandInputView()
        }
        .background(shellState.currentTheme.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ThemeSelectorView: View {
    @EnvironmentObject var shellState: ShellState
    
    var body: some View {
        List {
            ForEach(TerminalTheme.allThemes, id: \.name) { theme in
                Button(action: {
                    shellState.currentTheme = theme
                }) {
                    HStack {
                        Circle()
                            .fill(theme.background)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(theme.foreground, lineWidth: 1)
                            )
                        
                        Text(theme.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if shellState.currentTheme.name == theme.name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    let previewState = ShellState()
    previewState.appendOutput("➜ ~ $ ls", color: .green)
    previewState.appendOutput("Documents Downloads README.md", color: .white)
    previewState.appendError("Error: File not found")

    return TerminalView()
        .environmentObject(previewState)
}