//
//  DataToStringConverter.swift
//  
//
//  Created by 黄磊 on 2022/10/7.
//

import Foundation

/// 其他数据转字符串转化器
public struct DataToStringConverter<Data> {
    let convert: (Data) -> String
    
    public func callAsFunction(_ data: Data) -> String {
        convert(data)
    }
    
    public init(convert: @escaping (Data) -> String) {
        self.convert = convert
    }
    
    /// 用当前转化器连接另外一个字符串转换器。可参考 leftPadding 方法
    public func connect(to otherConverter: DataToStringConverter<String>) -> DataToStringConverter<Data> {
        .init { data in
            otherConverter(self.convert(data))
        }
    }
}

// MARK: - LoggerInfo Key
extension DataToStringConverter {
    
    /// 构造将 LogContent 属性转字符串的转化器
    ///
    /// - Parameter keyPath: 需要转换的 LogContent 中的属性对应的 KeyPath
    /// - Parameter converter: 可以将对应属性转化为字符串的转化器
    /// - Returns DataToStringConverter<LogContent>: 返回构造好的转化器
    public static func convert<Key>(
        _ keyPath: KeyPath<LogContent, Key>,
        with converter: DataToStringConverter<Key>
    ) -> DataToStringConverter<LogContent> {
        .init { loggerInfo in
            converter.convert(loggerInfo[keyPath: keyPath])
        }
    }
    
    // MARK: -LogLevel
    
    /// 默认日志等级转化器
    public static func defaultLevelConverter() -> DataToStringConverter<LogLevel> {
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
    
    // MARK: -messages
    
    /// 默认日志消息转化器
    public static func defaultMessagesConverter(_ separator: String = " ") -> DataToStringConverter<[Any]> {
        .init { messages in
            messages.map {"\($0)"}.joined(separator: separator)
        }
    }
    
    // MARK: -location
    
    /// 默认调用日志位置转化器，包含 文件名、行数、方法名称
    public static func defaultLocationConverter() -> DataToStringConverter<LogContent> {
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
    public static func defaultFileConverter(fixLength: Int = 30) -> DataToStringConverter<String> {
        .init { file in
            URL(fileURLWithPath: file).lastPathComponent
        }
        .rightPadding(to: fixLength, withPad: "·")
    }
    
    // MARK: -line
    
    /// 默认调用日志文件对应的行数转化器
    public static func defaultLineConverter(minLength: Int = 4) -> DataToStringConverter<Int> {
        .init { line in
            "\(line)"
        }
        .leftPadding(to: minLength)
    }
    
    // MARK: -method
    
    /// 默认调用日志对应方法转化器
    public static func defaultMethodConverter() -> DataToStringConverter<String> {
        .init { method in
            ".\(method)"
        }
    }
}


// MARK: - String Utils

extension DataToStringConverter {
    
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
}
