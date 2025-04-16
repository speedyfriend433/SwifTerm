import SwiftUI

struct TerminalTheme {
    let name: String
    let background: Color
    let foreground: Color
    let prompt: Color
    let error: Color
    let cursor: Color
    let selection: Color
    
    static let dark = TerminalTheme(
        name: "Dark",
        background: Color.black,
        foreground: Color.white,
        prompt: Color.green,
        error: Color.red,
        cursor: Color.white.opacity(0.7),
        selection: Color.blue.opacity(0.5)
    )
    
    static let light = TerminalTheme(
        name: "Light",
        background: Color.white,
        foreground: Color.black,
        prompt: Color.blue,
        error: Color.red,
        cursor: Color.black.opacity(0.7),
        selection: Color.blue.opacity(0.3)
    )
    
    static let hacker = TerminalTheme(
        name: "Hacker",
        background: Color.black,
        foreground: Color.green,
        prompt: Color.green.opacity(0.8),
        error: Color.red,
        cursor: Color.green.opacity(0.7),
        selection: Color.green.opacity(0.3)
    )
    
    static let midnight = TerminalTheme(
        name: "Midnight",
        background: Color(red: 0.1, green: 0.1, blue: 0.2),
        foreground: Color(red: 0.8, green: 0.8, blue: 1.0),
        prompt: Color(red: 0.5, green: 0.8, blue: 1.0),
        error: Color(red: 1.0, green: 0.4, blue: 0.4),
        cursor: Color(red: 0.8, green: 0.8, blue: 1.0).opacity(0.7),
        selection: Color(red: 0.3, green: 0.3, blue: 0.6)
    )
    
    static let allThemes = [dark, light, hacker, midnight]
}