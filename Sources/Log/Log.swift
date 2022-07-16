//
//  Log.swift
//
//
//  Created by s1mple wang on 2022/6/22.
//

import Foundation

/**
 ✅⚠️🌐🚫💢♻️📜📶⁉️❌❓❔❎ℹ️🥎🥶
 🔴🟡🟠🟢🔵🟣⚪️🟤♥️♦️♣️♠️🗯💭💬⚡️🌈☀️⭐️🌧☁️❄️☃️☂️🌊💦💧
 🔄🔂🔁🔀⏹⏺💊💣🧲⛓✉️📩📨📧💌📥📤📈📉✂️📌📍
 🉑🆔♓️☯️🔯✡️♐️♏️♊️☮️☪️♌️♍️📳☢️🈲🈳♨️🔞⚠️🚸
 💹🈯️✳️❇️🍓🍅🍆🌶🌽🐷🐽🧷🗑🦟🐛🐜🐞🕷📯🪲🪳🗂📖📒📔📗📘📮🧧🎁🪄
 💊💉💳🪙⌛️⏳💻📲📱⌚️⌨️🖥⌘🖨🖱🖲🕹💽🗜☎️🎞📡📣🔕🔔📢💬💭🗯🧩🧪🌡🧹🪠🧺🧻🚽🚰🛁🧼🧬🔋🌳
 🍀🌸🌼🌸🥀🌺🌹🌷🎋🌲🐓🐙🪰🦖🦋🐍🐢🐠🕸🦣
 🤝👎🏻👍🏻🅾️🚾🆖🆗🆙🚼☑️✔️🌈🤩📶📶📶🛄🗳📝❇️
 ☞☛⇢⟹→➜➙➞➠➡︎➩🔜➡️⏩⏭↪️⏯🔄🔀🌚🔥☄️⚡️💥🌈💨🌬💭
 */

extension Log {
    public enum LogMarker: String {
        case standard = "✅"
        case info = "🗂"
        case debug = "🐛"
        case test = "🧪"
        case warning = "⚠️"
        case error = "❌"
        case success = "👍🏻"
        case fail = "👎🏻"
        case alloc = "❇️"
        case dealloc = "♻️"
        case garbage = "🗑"
        case network = "🌐"
        case request = "📤"
        case response = "📥"
        case unexpected = "⁉️"
        case memoryLeak = "🥶"
        case wifi = "📶"
        case cache = "🗳"

        var needPrifix: Bool {
            switch self {
            case .network, .response, .request:
                return false
            default:
                return true
            }
        }
    }

    public enum ThreadMarker: String {
        case main = "🟢"
        case global = "⛓"
    }

    public enum XcodeConfig {
        case debug
        case release
        case all
    }

    public struct LogConfig {
        public var queue: String = Thread.isMainThread ? ThreadMarker.main.rawValue : ThreadMarker.global.rawValue

        public var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        public var itemsSeparator: String = " "

        public var twoLine: Bool = false
        public var lineSeparator: String {
            if twoLine {
                return "\n"
            } else {
                return " "
            }
        }

        public var terminator: String = "\n"

        public var Xcode: XcodeConfig = .debug

        public var handler: ((String) -> ())? = nil

        public static var `default`: LogConfig {
            LogConfig(
                dateFormat: "yyyy-MM-dd HH:mm:ss.SSS",
                itemsSeparator: " ",
                twoLine: false,
                terminator: "\n",
                Xcode: .debug,
                handler: nil
            )
        }
    }
}

public class Log {
    public static var config = LogConfig.default

    private static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = config.dateFormat
        return formatter
    }

    fileprivate static func Logging(_ items: [Any], marker: LogMarker, file: String, function: String, line: Int) {
        switch config.Xcode {
        case .debug:
#if DEBUG
            makeLog(items, marker: marker, file: file, function: function, line: line)
#endif
        case .release:
#if RELEASE
            makeLog(items, marker: marker, file: file, function: function, line: line)
#endif
        case .all:
            makeLog(items, marker: marker, file: file, function: function, line: line)
        }
    }

    fileprivate static func makeLog(_ items: [Any], marker: LogMarker, file: String, function: String, line: Int) {
        let lastSlashIndex: (String.Index) = (file.lastIndex(of: "/") ?? String.Index(utf16Offset: 0, in: file))
        let nextIndex: String.Index = file.index(after: lastSlashIndex)
        let filename: String = file.suffix(from: nextIndex).replacingOccurrences(of: ".swift", with: "")
        let fileDesc = "\(filename).\(function):\(line)"

        let dateString: String = formatter.string(from: Date())

        let prefix: String = "\(dateString) \(fileDesc) \(config.queue) "

        let message: String = items.map { "\($0)" }.joined(separator: config.itemsSeparator)

        let printText = "\(marker.needPrifix ? prefix : "")\(marker.rawValue)\(config.lineSeparator)\(message)"

        if let handler = config.handler {
            DispatchQueue.global().async {
                handler(printText)
            }
        }
        print(printText, terminator: config.terminator)
    }
}

extension Log {
    public static func log(_ items: Any..., marker: LogMarker = .standard, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func debug(_ items: Any..., marker: LogMarker = .debug, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func info(_ items: Any..., marker: LogMarker = .info, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func warning(_ items: Any..., marker: LogMarker = .warning, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func error(_ items: Any..., marker: LogMarker = .error, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func success(_ items: Any..., marker: LogMarker = .success, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func fail(_ items: Any..., marker: LogMarker = .fail, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func network(_ items: Any..., marker: LogMarker = .network, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func request(_ items: Any..., marker: LogMarker = .request, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func response(_ items: Any..., marker: LogMarker = .response, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
}
