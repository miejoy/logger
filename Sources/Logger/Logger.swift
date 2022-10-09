//
//  LoggerInfo.swift
//  
//
//  Created by 黄磊 on 2022/10/3.
//

import Foundation

/// 日志等级
public enum LogLevel : Int, Comparable {
    /// 追踪日志，显示非常详细
    case trace = 0
    /// 调试日志，显示对调试有用的信息
    case debug
    /// 信息日志，显示主要运行信息
    case info
    /// 通知日志，显示需要用户注意的信息，比如模块加载
    case notice
    /// 警告日志，提示可能存在潜在错误，需要程序员注意
    case warning
    /// 错误日志，发生了错误
    case error
    /// 致命错误，debug 模式将中断程序
    case fault
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// 日志内容
public struct LogContent {
    /// 日志等级
    public let level: LogLevel
    /// 日志消息列表
    public let messages: [Any]
    /// 日志用户信息，可用于传入定制内容
    public let userInfo: [String: String]
    /// 调用日志文件名
    public let file: String
    /// 调用日志文件对应行数
    public let line: Int
    /// 调用日志文件对应方法名
    public let method: String
}

/// 日志记录单例
public final class Logger {
    /// 日志记录共享单例
    public static var shared = Logger()
    
    /// 日志等级
    public var logLevel: LogLevel = .debug
    
    /// 日志片段列表
    public var logSegments: [LogSegment] = [
        .dateTime(s_defaultDateFormat),
        .string(" ["),
        .logContent(.convert(\.level, with: .defaultLevelConverter())),
        .string("] "),
        .logContent(.defaultLocationConverter()),
        .string(" ↔️ "),
        .logContent(.convert(\.messages, with: .defaultMessagesConverter()))
    ]
        
    /// 日志记录器，默认控制台输出
    public var recorder: LogRecorder = ConsoleRecorder()
        
    /// 默认抛出 LogFault，默认抛出异常
    public var throwFault: Bool = true
    
    /// 记录对应日志
    ///
    /// - Parameter level: 日志等级
    /// - Parameter messages: 日志消息列表
    /// - Parameter userInfo: 用户自定义信息
    /// - Parameter file: 调用日志文件名
    /// - Parameter line: 调用日志文件对应行数
    /// - Parameter method: 调用日志文件对应方法名
    /// - Returns DataToStringConverter<LogContent>: 返回构造好的转化器
    public func record(
        _ level: LogLevel,
        _ messages: [Any],
        userInfo : [String: String] = [:],
        _ file: String = #file,
        _ line: Int = #line,
        _ method: String = #function
    ) {
        let logContent: LogContent = .init(level: level, messages: messages, userInfo: userInfo, file: file, line: line, method: method)
        let logStr = logSegments.reduce(into: "") { partialResult, segment in
            switch segment {
            case .string(let str):
                partialResult += str
            case .logContent(let converter):
                partialResult += converter(logContent)
            case .dateTime(let format):
                partialResult += format.string(from: Date())
            }
        }
        recorder.write(log: logStr, of: logContent)
        #if DEBUG
        if level == .fault && throwFault { fatalError(messages.map {"\($0)"}.joined(separator: " ")) }
        #endif
    }
}

/// 默认日志日期格式
let s_defaultDateFormat : DateFormatter = {
    let dateFormat : DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
    return dateFormat
}()
