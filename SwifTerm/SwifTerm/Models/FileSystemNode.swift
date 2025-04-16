import Foundation

enum FileSystemNode {
    case file(name: String, content: String)
    case directory(name: String, children: [String: FileSystemNode])

    var name: String {
        switch self {
        case .file(let name, _):
            return name
        case .directory(let name, _):
            return name
        }
    }

    var isDirectory: Bool {
        if case .directory = self { return true }
        return false
    }

    var isFile: Bool {
        if case .file = self { return true }
        return false
    }
}