# SwiftTerm - A Modern Terminal Emulator for iOS

SwiftTerm is a feature-rich terminal emulator built entirely in SwiftUI, designed to provide a native terminal experience on iOS devices with modern UI/UX enhancements.

## ✨ Features

- **Full Terminal Emulation** with command history and navigation
- **Virtual File System** with common Unix commands:
  - `ls`, `cd`, `pwd`, `mkdir`, `touch`
  - `cat`, `echo`, `rm`, `mv`
  - `clear`, `help`
- **Customizable UI** with multiple themes:
  - Dark, Light, Hacker, and Midnight themes
  - Dynamic color schemes for all UI elements
- **Intuitive Gestures**:
  - Swipe up/down for command history navigation
  - Tap to focus command input
- **Modern Terminal Features**:
  - Command auto-completion (planned)
  - Tab support (planned)
  - Session persistence (planned)

## 🛠️ Technical Implementation

Built using:
- **SwiftUI** for declarative UI
- **Combine** for reactive state management
- **Custom Virtual File System** implementation
- **EnvironmentObject** for shared state
- **MVVM** architecture pattern

## 📦 Installation

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Building from Source
1. Clone the repository:
```bash
git clone https://github.com/speedyfriend433/SwifTerm.git
cd SwifTerm
```

2. Open in Xcode:
```bash
xed .
```

3. Build and run on your simulator or device

## 🎨 Customization

### Adding New Themes
1. Edit `TerminalTheme.swift` to add new theme configurations
2. Implement theme selection in `ThemeSelectorView.swift`

### Adding New Commands
1. Extend `CommandParser.swift` with new command logic
2. Add corresponding file system operations in `FileSystem.swift`

## 🚀 Roadmap

- [ ] Add SSH client capabilities
- [ ] Implement command auto-completion
- [ ] Add tab support for multiple sessions
- [ ] Support for external keyboard shortcuts
- [ ] Persistent session history

## 🤝 Contributing

We welcome contributions! Please follow these steps:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

SwiftTerm is released under the MIT License. See [LICENSE](LICENSE) for details.

## 👏 Acknowledgments

- Inspired by traditional Unix terminals
- Built with ❤️ using SwiftUI
- Special thanks to the Swift community