import SwiftUI
import Combine

struct TerminalOutputLine: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

class ShellState: ObservableObject {
    @Published var outputLines: [TerminalOutputLine] = []
    @Published var currentCommand: String = ""
    @Published var fileSystem: FileSystem
    @Published var commandHistory: [String] = []
    @Published var historyIndex: Int = -1
    @Published var currentTheme: TerminalTheme = .dark

    private var commandParser: CommandParser!

    var user: String = "swiftterm"
    var hostname: String = "ios"
    var promptSymbol: String = "$"

    var currentPrompt: String {
        let cwd = fileSystem.currentWorkingDirectory.replacingOccurrences(of: "/Users/guest", with: "~")
        return "\(user)@\(hostname):\(cwd) \(promptSymbol) "
    }

    init(fileSystem: FileSystem = FileSystem()) {
        self.fileSystem = fileSystem
        self.commandParser = CommandParser(shellState: self)
        appendOutput("Welcome to SwiftTerm!", color: .cyan)
    }

    func appendOutput(_ text: String, color: Color? = nil) {
        let outputColor = color ?? currentTheme.foreground
        let newLine = TerminalOutputLine(text: text, color: outputColor)
        outputLines.append(newLine)
    }
    
    func appendError(_ text: String) {
        let newLine = TerminalOutputLine(text: text, color: currentTheme.error)
        outputLines.append(newLine)
    }

    func executeCommand() {
        let commandToExecute = currentCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commandToExecute.isEmpty else { return }

        appendOutput(currentPrompt + commandToExecute, color: .green)

        if commandHistory.last != commandToExecute {
            commandHistory.append(commandToExecute)
        }
        historyIndex = commandHistory.count

        commandParser.parseAndExecute(commandToExecute)

        currentCommand = ""
    }

    func clearScreen() {
        DispatchQueue.main.async {
            self.outputLines.removeAll()
        }
    }

    func navigateHistory(up: Bool) {
        guard !commandHistory.isEmpty else { return }

        if up {
            if historyIndex > 0 {
                historyIndex -= 1
            } else if historyIndex == -1 || historyIndex == commandHistory.count {
                 historyIndex = commandHistory.count - 1
            } else {
                return
            }
        } else {
            if historyIndex < commandHistory.count - 1 {
                historyIndex += 1
            } else {
                 historyIndex = commandHistory.count
                 currentCommand = ""
                 return
            }
        }

        if historyIndex >= 0 && historyIndex < commandHistory.count {
             currentCommand = commandHistory[historyIndex]
        }
    }
}