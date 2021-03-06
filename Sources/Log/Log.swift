//
//  Log.swift
//
//
//  Created by s1mple wang on 2022/6/22.
//

import Foundation

/**
 โโ ๏ธ๐๐ซ๐ขโป๏ธ๐๐ถโ๏ธโโโโโน๏ธ๐ฅ๐ฅถ
 ๐ด๐ก๐ ๐ข๐ต๐ฃโช๏ธ๐คโฅ๏ธโฆ๏ธโฃ๏ธโ ๏ธ๐ฏ๐ญ๐ฌโก๏ธ๐โ๏ธโญ๏ธ๐งโ๏ธโ๏ธโ๏ธโ๏ธ๐๐ฆ๐ง
 ๐๐๐๐โนโบ๐๐ฃ๐งฒโโ๏ธ๐ฉ๐จ๐ง๐๐ฅ๐ค๐๐โ๏ธ๐๐
 ๐๐โ๏ธโฏ๏ธ๐ฏโก๏ธโ๏ธโ๏ธโ๏ธโฎ๏ธโช๏ธโ๏ธโ๏ธ๐ณโข๏ธ๐ฒ๐ณโจ๏ธ๐โ ๏ธ๐ธ
 ๐น๐ฏ๏ธโณ๏ธโ๏ธ๐๐๐๐ถ๐ฝ๐ท๐ฝ๐งท๐๐ฆ๐๐๐๐ท๐ฏ๐ชฒ๐ชณ๐๐๐๐๐๐๐ฎ๐งง๐๐ช
 ๐๐๐ณ๐ชโ๏ธโณ๐ป๐ฒ๐ฑโ๏ธโจ๏ธ๐ฅโ๐จ๐ฑ๐ฒ๐น๐ฝ๐โ๏ธ๐๐ก๐ฃ๐๐๐ข๐ฌ๐ญ๐ฏ๐งฉ๐งช๐ก๐งน๐ช ๐งบ๐งป๐ฝ๐ฐ๐๐งผ๐งฌ๐๐ณ
 ๐๐ธ๐ผ๐ธ๐ฅ๐บ๐น๐ท๐๐ฒ๐๐๐ชฐ๐ฆ๐ฆ๐๐ข๐ ๐ธ๐ฆฃ
 ๐ค๐๐ป๐๐ป๐พ๏ธ๐พ๐๐๐๐ผโ๏ธโ๏ธ๐๐คฉ๐ถ๐ถ๐ถ๐๐ณ๐โ๏ธ
 โโโขโนโโโโโ โก๏ธโฉ๐โก๏ธโฉโญโช๏ธโฏ๐๐๐๐ฅโ๏ธโก๏ธ๐ฅ๐๐จ๐ฌ๐ญ
 */

extension Log {
    public enum Marker: String {
        case standard = "โ"
        case info = "๐"
        case debug = "๐"
        case test = "๐งช"
        case warning = "โ ๏ธ"
        case error = "โ"
        case success = "๐๐ป"
        case fail = "๐๐ป"
        case alloc = "โ๏ธ"
        case dealloc = "โป๏ธ"
        case garbage = "๐"
        case network = "๐"
        case request = "๐ค"
        case response = "๐ฅ"
        case unexpected = "โ๏ธ"
        case memoryLeak = "๐ฅถ"
        case wifi = "๐ถ"
        case cache = "๐ณ"

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
        case main = "๐ข"
        case global = "โ"
    }

    public enum XcodeConfig {
        case debug
        case release
        case all
    }

    public struct Config {
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

        public static var `default`: Config {
            Config(
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
    public static var config = Config.default

    private static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = config.dateFormat
        return formatter
    }

    fileprivate static func Logging(_ items: [Any], marker: Marker, file: String, function: String, line: Int) {
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

    fileprivate static func makeLog(_ items: [Any], marker: Marker, file: String, function: String, line: Int) {
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
    public static func log(_ items: Any..., marker: Marker = .standard, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func debug(_ items: Any..., marker: Marker = .debug, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func info(_ items: Any..., marker: Marker = .info, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func warning(_ items: Any..., marker: Marker = .warning, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func error(_ items: Any..., marker: Marker = .error, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func success(_ items: Any..., marker: Marker = .success, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func fail(_ items: Any..., marker: Marker = .fail, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func network(_ items: Any..., marker: Marker = .network, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func request(_ items: Any..., marker: Marker = .request, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
    public static func response(_ items: Any..., marker: Marker = .response, file: String = #file, line: Int = #line, function: String = #function) {
        Logging(items, marker: marker, file: file, function: function, line: line)
    }
}
