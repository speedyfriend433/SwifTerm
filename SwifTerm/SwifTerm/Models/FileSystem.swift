import Foundation

class FileSystem {
    private var root: FileSystemNode
    private var currentDirectoryPath: [String]

    var currentWorkingDirectory: String {
        "/" + currentDirectoryPath.joined(separator: "/")
    }

    private var currentDirectoryNode: FileSystemNode? {
        getNode(at: currentDirectoryPath)
    }

    init() {
        self.root = .directory(name: "", children: [
            "Documents": .directory(name: "Documents", children: [:]),
            "Downloads": .directory(name: "Downloads", children: [:]),
            "README.md": .file(name: "README.md", content: "Welcome to SwiftTerm!")
        ])
        self.currentDirectoryPath = []
    }

    func resolvePath(_ path: String) -> [String]? {
        let components: [String]
        if path.starts(with: "/") {
            components = path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
        } else {
            var currentPath = currentDirectoryPath
            let relativeComponents = path.split(separator: "/").map(String.init).filter { !$0.isEmpty }

            for component in relativeComponents {
                if component == "." {
                    continue
                } else if component == ".." {
                    if !currentPath.isEmpty {
                        currentPath.removeLast()
                    }
                } else {
                    currentPath.append(component)
                }
            }
            components = currentPath
        }
        return components
    }

    private func getNode(at pathComponents: [String]) -> FileSystemNode? {
        var currentNode = root
        for component in pathComponents {
            guard case .directory(_, var children) = currentNode else {
                return nil
            }
            guard let nextNode = children[component] else {
                return nil
            }
            currentNode = nextNode
        }
        return currentNode
    }

    private func getParentNode(for pathComponents: [String]) -> (parent: FileSystemNode?, targetName: String?) {
        guard !pathComponents.isEmpty else { return (nil, nil) }

        let parentPath = Array(pathComponents.dropLast())
        let targetName = pathComponents.last!

        var parentNode = root
        for component in parentPath {
            guard case .directory(_, let children) = parentNode else {
                return (nil, nil)
            }
            guard let nextNode = children[component] else {
                return (nil, nil)
            }
            parentNode = nextNode
        }

        guard case .directory = parentNode else {
            return (nil, nil)
        }

        return (parentNode, targetName)
    }

    private func updateNode(at pathComponents: [String], with newNode: FileSystemNode) -> Bool {
        var nodesToUpdate: [(path: [String], node: FileSystemNode)] = []
        var current = root
        var currentPath: [String] = []

        for (index, component) in pathComponents.enumerated() {
            guard case .directory(let name, var children) = current else { return false }

            if index == pathComponents.count - 1 {
                children[component] = newNode
                let updatedParent = FileSystemNode.directory(name: name, children: children)
                nodesToUpdate.append((path: currentPath, node: updatedParent))
                break
            } else {
                 guard let nextNode = children[component], nextNode.isDirectory else { return false }
                 nodesToUpdate.append((path: currentPath, node: current))
                 current = nextNode
                 currentPath.append(component)
            }
        }

        var finalRoot = root
        for updateInfo in nodesToUpdate.reversed() {
             if updateInfo.path.isEmpty {
                 finalRoot = updateInfo.node
             } else {
                 var parentPath = updateInfo.path
                 let childName = parentPath.removeLast()
                 var ancestor = getNode(at: parentPath)
                 self.root = recursivelyUpdateNode(in: self.root, at: pathComponents, with: newNode) ?? self.root
                 return true
             }
        }
         self.root = finalRoot
         return true
    }

    private func recursivelyUpdateNode(in node: FileSystemNode, at path: [String], with newNode: FileSystemNode) -> FileSystemNode? {
        guard !path.isEmpty else { return newNode }

        guard case .directory(let name, var children) = node, node.isDirectory else {
            return nil
        }

        let currentComponent = path.first!
        let remainingPath = Array(path.dropFirst())

        guard let childNode = children[currentComponent] else {
            return nil
        }

        if let updatedChild = recursivelyUpdateNode(in: childNode, at: remainingPath, with: newNode) {
            children[currentComponent] = updatedChild
            return .directory(name: name, children: children)
        } else {
            return nil
        }
    }

     private func insertNode(_ newNode: FileSystemNode, into parentPathComponents: [String]) -> Bool {
        var parentNode = root
        var currentPath: [String] = []

        for component in parentPathComponents {
            guard case .directory(_, let children) = parentNode else { return false }
            guard let nextNode = children[component], nextNode.isDirectory else { return false }
            parentNode = nextNode
            currentPath.append(component)
        }

        guard case .directory(let parentName, var children) = parentNode else { return false }

        if children[newNode.name] != nil {
            return false
        }

        children[newNode.name] = newNode
        let updatedParentDirectory = FileSystemNode.directory(name: parentName, children: children)

        if parentPathComponents.isEmpty {
             self.root = updatedParentDirectory
             return true
        } else {
            self.root = recursivelyUpdateNode(in: self.root, at: parentPathComponents, with: updatedParentDirectory) ?? self.root
             guard let checkNode = getNode(at: parentPathComponents), case .directory(_, let finalChildren) = checkNode else { return false }
             return finalChildren[newNode.name]?.name == newNode.name
        }
    }

    func listContents(path: String?) -> Result<[String], Error> {
        let targetPathComponents: [String]
        if let path = path, !path.isEmpty {
            guard let resolved = resolvePath(path) else {
                return .failure(FileSystemError.invalidPath(path))
            }
            targetPathComponents = resolved
        } else {
            targetPathComponents = currentDirectoryPath
        }

        guard let node = getNode(at: targetPathComponents) else {
            return .failure(FileSystemError.notFound(path ?? currentWorkingDirectory))
        }

        guard case .directory(_, let children) = node else {
            return .failure(FileSystemError.notADirectory(path ?? currentWorkingDirectory))
        }

        return .success(children.keys.sorted())
    }

    func changeDirectory(path: String) -> Result<Void, Error> {
        guard let targetPathComponents = resolvePath(path) else {
            return .failure(FileSystemError.invalidPath(path))
        }

        guard let node = getNode(at: targetPathComponents) else {
            return .failure(FileSystemError.notFound(path))
        }

        guard node.isDirectory else {
            return .failure(FileSystemError.notADirectory(path))
        }

        self.currentDirectoryPath = targetPathComponents
        return .success(())
    }

    func createDirectory(path: String) -> Result<Void, Error> {
        guard let fullPathComponents = resolvePath(path) else {
            return .failure(FileSystemError.invalidPath(path))
        }

        guard !fullPathComponents.isEmpty else {
            return .failure(FileSystemError.invalidOperation("Cannot create directory at root"))
        }

        let parentPath = Array(fullPathComponents.dropLast())
        let newDirName = fullPathComponents.last!

        guard let parentNode = getNode(at: parentPath), parentNode.isDirectory else {
             return .failure(FileSystemError.notFound("Parent directory does not exist"))
        }

        if getNode(at: fullPathComponents) != nil {
            return .failure(FileSystemError.alreadyExists(path))
        }

        let newDirectory = FileSystemNode.directory(name: newDirName, children: [:])

        if insertNode(newDirectory, into: parentPath) {
            return .success(())
        } else {
            return .failure(FileSystemError.unknown("Failed to create directory"))
        }
    }

     func createFile(path: String, content: String = "") -> Result<Void, Error> {
        guard let fullPathComponents = resolvePath(path) else {
            return .failure(FileSystemError.invalidPath(path))
        }

        guard !fullPathComponents.isEmpty else {
            return .failure(FileSystemError.invalidOperation("Cannot create file at root"))
        }

        let parentPath = Array(fullPathComponents.dropLast())
        let newFileName = fullPathComponents.last!

        guard let parentNode = getNode(at: parentPath), parentNode.isDirectory else {
             return .failure(FileSystemError.notFound("Parent directory does not exist"))
        }

        if let existingNode = getNode(at: fullPathComponents) {
             if existingNode.isDirectory {
                 return .failure(FileSystemError.invalidOperation("Cannot overwrite directory with file"))
             }
        }

        let newFile = FileSystemNode.file(name: newFileName, content: content)

        if insertNode(newFile, into: parentPath) {
             self.root = recursivelyUpdateNode(in: self.root, at: fullPathComponents, with: newFile) ?? self.root
             if let checkNode = getNode(at: fullPathComponents), checkNode.isFile {
                 return .success(())
             } else {
                 if insertNode(newFile, into: parentPath) {
                     return .success(())
                 } else {
                    return .failure(FileSystemError.unknown("Failed to create or update file"))
                 }
             }
        } else {
             self.root = recursivelyUpdateNode(in: self.root, at: fullPathComponents, with: newFile) ?? self.root
             if let checkNode = getNode(at: fullPathComponents), checkNode.isFile {
                 return .success(())
             } else {
                 return .failure(FileSystemError.unknown("Failed to create or update file"))
             }
        }
    }

    func readFile(path: String) -> Result<String, Error> {
        guard let targetPathComponents = resolvePath(path) else {
            return .failure(FileSystemError.invalidPath(path))
        }

        guard let node = getNode(at: targetPathComponents) else {
            return .failure(FileSystemError.notFound(path))
        }

        guard case .file(_, let content) = node else {
            return .failure(FileSystemError.notAFile(path))
        }

        return .success(content)
    }

    func writeToFile(path: String, content: String) -> Result<Void, Error> {
        return createFile(path: path, content: content)
    }

    func removeNode(path: String) -> Result<Void, Error> {
        guard let fullPathComponents = resolvePath(path) else {
            return .failure(FileSystemError.invalidPath(path))
        }

        guard !fullPathComponents.isEmpty else {
            return .failure(FileSystemError.invalidOperation("Cannot remove root directory"))
        }

        guard getNode(at: fullPathComponents) != nil else {
            return .failure(FileSystemError.notFound(path))
        }

        let parentPath = Array(fullPathComponents.dropLast())
        let targetName = fullPathComponents.last!

        guard var parentNode = getNode(at: parentPath), case .directory(let parentDirName, var children) = parentNode else {
             return .failure(FileSystemError.unknown("Could not find parent directory for removal"))
        }

        children.removeValue(forKey: targetName)

        let updatedParentDirectory = FileSystemNode.directory(name: parentDirName, children: children)

        if parentPath.isEmpty {
            self.root = updatedParentDirectory
            return .success(())
        } else {
            self.root = recursivelyUpdateNode(in: self.root, at: parentPath, with: updatedParentDirectory) ?? self.root
            if getNode(at: fullPathComponents) == nil {
                return .success(())
            } else {
                return .failure(FileSystemError.unknown("Failed to remove node"))
            }
        }
    }

    func moveNode(sourcePath: String, destinationPath: String) -> Result<Void, Error> {
        guard let sourceComponents = resolvePath(sourcePath) else {
            return .failure(FileSystemError.invalidPath(sourcePath))
        }
        guard let destinationComponents = resolvePath(destinationPath) else {
            return .failure(FileSystemError.invalidPath(destinationPath))
        }

        guard !sourceComponents.isEmpty else {
            return .failure(FileSystemError.invalidOperation("Cannot move root directory"))
        }

        guard let nodeToMove = getNode(at: sourceComponents) else {
            return .failure(FileSystemError.notFound(sourcePath))
        }

        var finalDestComponents = destinationComponents
        var finalNodeName = nodeToMove.name

        if let destNode = getNode(at: destinationComponents) {
            if destNode.isDirectory {
                finalDestComponents = destinationComponents
                finalDestComponents.append(nodeToMove.name)
            } else {
                return .failure(FileSystemError.alreadyExists(destinationPath + " (cannot overwrite file)"))
            }
        } else {
             finalNodeName = destinationComponents.last ?? nodeToMove.name
             finalDestComponents = Array(destinationComponents.dropLast())
        }

         if getNode(at: finalDestComponents + [finalNodeName]) != nil {
              if getNode(at: destinationComponents + [nodeToMove.name]) != nil && getNode(at: destinationComponents)?.isDirectory ?? false {
                   return .failure(FileSystemError.alreadyExists("\(destinationPath)/\(nodeToMove.name)"))
              } else if getNode(at: destinationComponents) != nil && !(getNode(at: destinationComponents)?.isDirectory ?? false) {
                   return .failure(FileSystemError.alreadyExists(destinationPath))
              } else if getNode(at: finalDestComponents + [finalNodeName]) != nil {
                   return .failure(FileSystemError.alreadyExists(destinationPath))
              }
         }

        let removeResult = removeNode(path: sourcePath)
        guard case .success = removeResult else {
            return removeResult
        }

        let nodeToAdd: FileSystemNode
        switch nodeToMove {
        case .file(_, let content):
            nodeToAdd = .file(name: finalNodeName, content: content)
        case .directory(_, let children):
            nodeToAdd = .directory(name: finalNodeName, children: children)
        }

        let parentPathOfFinalDest = Array(finalDestComponents)
        if insertNode(nodeToAdd, into: parentPathOfFinalDest) {
             let finalFullPath = parentPathOfFinalDest + [finalNodeName]
             if getNode(at: finalFullPath) != nil {
                 return .success(())
             } else {
                 return .failure(FileSystemError.unknown("Move failed: Node disappeared after insertion"))
             }
        } else {
            return .failure(FileSystemError.unknown("Move failed: Could not insert node at destination \(parentPathOfFinalDest.joined(separator: "/"))"))
        }
    }
}

enum FileSystemError: Error, LocalizedError {
    case notFound(String)
    case notADirectory(String)
    case notAFile(String)
    case invalidPath(String)
    case alreadyExists(String)
    case invalidOperation(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let path): return "Error: No such file or directory: \(path)"
        case .notADirectory(let path): return "Error: Not a directory: \(path)"
        case .notAFile(let path): return "Error: Not a file: \(path)"
        case .invalidPath(let path): return "Error: Invalid path: \(path)"
        case .alreadyExists(let path): return "Error: File or directory already exists: \(path)"
        case .invalidOperation(let reason): return "Error: Invalid operation: \(reason)"
        case .unknown(let reason): return "Error: An unknown file system error occurred: \(reason)"
        }
    }
}