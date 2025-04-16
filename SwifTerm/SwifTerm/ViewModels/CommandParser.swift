import Foundation
import SwiftUI

class CommandParser {
    weak var shellState: ShellState?

    init(shellState: ShellState) {
        self.shellState = shellState
    }

    func parseAndExecute(_ input: String) {
        guard let shellState = shellState else { return }

        let components = input.split(separator: " ", maxSplits: 1).map(String.init)
        let command = components.first?.lowercased() ?? ""
        var arguments = components.count > 1 ? String(components[1]) : ""

        switch command {
        case "ls":
            executeLs(arguments: arguments)
        case "cd":
            executeCd(arguments: arguments)
        case "pwd":
            executePwd()
        case "echo":
            executeEcho(arguments: arguments)
        case "cat":
            executeCat(arguments: arguments)
        case "mkdir":
            executeMkdir(arguments: arguments)
        case "touch":
            executeTouch(arguments: arguments)
        case "rm":
            executeRm(arguments: arguments)
        case "mv":
            executeMv(arguments: arguments)
        case "clear":
            shellState.clearScreen()
        case "help":
            executeHelp()
        case "":
            break
        default:
            shellState.appendError("SwiftTerm: command not found: \(command)")
        }
    }

    private func executeLs(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.isEmpty ? nil : arguments.trimmingCharacters(in: .whitespaces)

        let result = shellState.fileSystem.listContents(path: path)
        switch result {
        case .success(let items):
            if !items.isEmpty {
                shellState.appendOutput(items.joined(separator: "\t"), color: .white)
            }
        case .failure(let error):
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeCd(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
             let result = shellState.fileSystem.changeDirectory(path: "/")
             if case .failure(let error) = result {
                 shellState.appendError(error.localizedDescription)
             }
             return
        }

        let result = shellState.fileSystem.changeDirectory(path: path)
        if case .failure(let error) = result {
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executePwd() {
        guard let shellState = shellState else { return }
        shellState.appendOutput(shellState.fileSystem.currentWorkingDirectory, color: .white)
    }

    private func executeEcho(arguments: String) {
        guard let shellState = shellState else { return }

        if let redirectRange = arguments.range(of: ">") {
            let contentToEcho = String(arguments[..<redirectRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            let filePath = String(arguments[redirectRange.upperBound...]).trimmingCharacters(in: .whitespaces)

            if filePath.isEmpty {
                shellState.appendError("Error: Missing filename for redirection.")
                return
            }

            let result = shellState.fileSystem.writeToFile(path: filePath, content: contentToEcho)
            if case .failure(let error) = result {
                shellState.appendError(error.localizedDescription)
            }
        } else {
            shellState.appendOutput(arguments, color: .white)
        }
    }

    private func executeCat(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
            shellState.appendError("Usage: cat <filename>")
            return
        }

        let result = shellState.fileSystem.readFile(path: path)
        switch result {
        case .success(let content):
            shellState.appendOutput(content, color: .white)
        case .failure(let error):
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeMkdir(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
            shellState.appendError("Usage: mkdir <directory_name>")
            return
        }

        let result = shellState.fileSystem.createDirectory(path: path)
        if case .failure(let error) = result {
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeTouch(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
            shellState.appendError("Usage: touch <filename>")
            return
        }

        let result = shellState.fileSystem.createFile(path: path, content: "")
        if case .failure(let error) = result {
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeRm(arguments: String) {
        guard let shellState = shellState else { return }
        let path = arguments.trimmingCharacters(in: .whitespaces)

        if path.isEmpty {
            shellState.appendError("Usage: rm <file_or_directory>")
            return
        }

        if path == "/" || path == "." || path == ".." || shellState.fileSystem.resolvePath(path) == [] {
             shellState.appendError("Error: Cannot remove '\(path)': Invalid argument or protected path.")
             return
        }

        if let targetPath = shellState.fileSystem.resolvePath(path),
           targetPath == shellState.fileSystem.resolvePath(".") {
            shellState.appendError("Error: Cannot remove current directory '.'")
            return
        }

        let result = shellState.fileSystem.removeNode(path: path)
        if case .failure(let error) = result {
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeMv(arguments: String) {
        guard let shellState = shellState else { return }
        let parts = arguments.split(separator: " ", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }

        guard parts.count == 2 else {
            shellState.appendError("Usage: mv <source> <destination>")
            return
        }

        let sourcePath = String(parts[0])
        let destinationPath = String(parts[1])

        if sourcePath.isEmpty || destinationPath.isEmpty {
            shellState.appendError("Usage: mv <source> <destination>")
            return
        }
         if sourcePath == "/" || destinationPath == "/" {
             shellState.appendError("Error: Cannot move root directory.")
             return
         }

        let result = shellState.fileSystem.moveNode(sourcePath: sourcePath, destinationPath: destinationPath)
        if case .failure(let error) = result {
            shellState.appendError(error.localizedDescription)
        }
    }

    private func executeHelp() {
        guard let shellState = shellState else { return }
        let helpText = """
        SwiftTerm Basic Commands:
          ls [path]        List directory contents
          cd <directory>   Change directory
          pwd              Print working directory name
          echo <text>      Display text
          echo <text> > <file> Write text to file (overwrite)
          cat <file>       Display file content
          mkdir <directory> Create a directory
          touch <file>     Create an empty file
          rm <path>        Remove file or directory
          mv <source> <dest> Move/rename file or directory
          clear            Clear the terminal screen
          help             Show this help message
        """
        shellState.appendOutput(helpText, color: .cyan)
    }
}