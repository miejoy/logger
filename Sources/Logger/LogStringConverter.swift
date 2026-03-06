//
//  LogStringConverter.swift
//  
//
//  Created by 黄磊 on 2022/10/7.
//

import Foundation

/// 其他数据转字符串转化器
public struct LogStringConverter<Data>: Sendable {
    let convert: @Sendable (Data) -> String
    
    public func callAsFunction(_ data: Data) -> String {
        convert(data)
    }
    
    public init(convert: @Sendable @escaping (Data) -> String) {
        self.convert = convert
    }
    
    /// 用当前转化器连接另外一个字符串转换器。可参考 leftPadding 方法
    public func connect(to otherConverter: LogStringConverter<String>) -> LogStringConverter<Data> {
        .init { data in
            otherConverter(self.convert(data))
        }
    }
}

// MARK: - LoggerInfo Key
extension LogStringConverter {
    
    /// 构造将 LogContent 属性转字符串的转化器
    ///
    /// - Parameter keyPath: 需要转换的 LogContent 中的属性对应的 KeyPath
    /// - Parameter converter: 可以将对应属性转化为字符串的转化器
    /// - Returns LogStringConverter<LogContent>: 返回构造好的转化器
    public static func convert<Key>(
        _ keyPath: KeyPath<LogContent, Key>,
        with converter: LogStringConverter<Key>
    ) -> LogStringConverter<LogContent> {
        .init { loggerInfo in
            converter.convert(loggerInfo[keyPath: keyPath])
        }
    }
    
    // MARK: -Date
    
    /// 默认日志时间转化器。传入 nil 的话，使用默认格式 "yyyy-MM-dd HH:mm:ss.SSSZ"
    public static func defaultDateConverter(_ dateFormatter: DateFormatter? = nil) -> LogStringConverter<Date> {
        .init { date in
            (dateFormatter ?? s_defaultDateFormat).string(from: date)
        }
    }
    
    
    // MARK: -LogLevel
    
    /// 默认日志等级转化器
    public static func defaultLevelConverter() -> LogStringConverter<LogLevel> {
        .init { level in
            switch level {
            case .trace:    return "🐾 Trace  "
            case .debug:    return "🔍 Debug  "
            case .info:     return "📗 Info   "
            case .notice:   return "📣 Notice "
            case .warning:  return "⚠️ Warning"
            case .error:    return "‼️ Error  "
            case .fault:    return "🚫 Fault  "
            }
        }
    }
    
    // MARK: -labels
    
    /// 默认日志消息转化器
    public static func defaultLabelsConverter() -> LogStringConverter<[String]> {
        .init { labels in
            if labels.isEmpty {
                return ""
            }
            return labels.map {"[\($0)]"}.joined(separator: "").appending(" ")
        }
    }
    
    // MARK: -messages
    
    /// 默认日志消息转化器
    public static func defaultMessagesConverter(_ separator: String = " ") -> LogStringConverter<[String]> {
        .init { messages in
            messages.joined(separator: separator)
        }
    }
    
    // MARK: -location
    
    /// 默认调用日志位置转化器，包含 文件名、行数、方法名称
    public static func defaultLocationConverter() -> LogStringConverter<LogContent> {
        .init { logContent in
            let lineAndMethodStr = "(\(logContent.line)).\(logContent.method)"
            if let index = logContent.file.lastIndex(of: "/") {
                return logContent.file.suffix(from: logContent.file.index(index, offsetBy: 1)) + lineAndMethodStr
            }
            return logContent.file + lineAndMethodStr
        }
    }
    
    // MARK: -file
    
    /// 默认调用日志文件转化器
    public static func defaultFileConverter(fixLength: Int = 30) -> LogStringConverter<String> {
        .init { file in
            URL(fileURLWithPath: file).lastPathComponent
        }
        .rightPadding(to: fixLength, withPad: "·")
    }
    
    // MARK: -line
    
    /// 默认调用日志文件对应的行数转化器
    public static func defaultLineConverter(minLength: Int = 4) -> LogStringConverter<Int> {
        .init { line in
            "\(line)"
        }
        .leftPadding(to: minLength)
    }
    
    // MARK: -method
    
    /// 默认调用日志对应方法转化器
    public static func defaultMethodConverter() -> LogStringConverter<String> {
        .init { method in
            ".\(method)"
        }
    }
}


// MARK: - String Utils

extension LogStringConverter {
    
    /// 头部填充字符
    ///
    /// - Parameter length: 最少的长度，传入字符串如果超过这个长度，将不做填充，如传小于等于 0 时，将直接返回传入数据
    /// - Parameter character: 填充字符串，默认是空格
    /// - Returns Self: 返回新的转化器
    public func leftPadding(
        to length: Int,
        withPad character: Character = " "
    ) -> Self {
        self.connect(to: .init(convert: { data in
            if data.count >= length {
                return data
            }
            return String(repeating: character, count: length - data.count) + data
        }))
    }
    
    /// 尾部填充字符
    ///
    /// - Parameter length: 最少的长度，传入字符串如果超过这个长度，将不做填充，如传小于等于 0 时，将直接返回传入数据
    /// - Parameter character: 填充字符串，默认是空格
    /// - Returns Self: 返回新的转化器
    public func rightPadding(
        to length: Int,
        withPad character: Character = " "
    ) -> Self {
        self.connect(to: .init(convert: { data in
            if data.count >= length {
                return data
            }
            return data + String(repeating: character, count: length - data.count)
        }))
    }
    
    public func maxLength(to length: UInt) -> Self {
        self.connect(to: .init(convert: { data in
            if data.count <= length || data.count <= 3 {
                return data
            }
            let endIndex = data.index(data.startIndex, offsetBy: Int(length) - 3)
            return data[..<endIndex] + "..."
        }))
    }
}

extension KeyPath: @retroactive @unchecked Sendable where Root == LogContent {
}

/// 默认日志日期格式
let s_defaultDateFormat : DateFormatter = {
    let dateFormat : DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
    return dateFormat
}()
