//
//  Logger.swift
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
    /// 当前使用 Logger 的标签列表
    public let labels: [String]
    /// 日志消息列表
    public let messages: [Any]
    /// 日志用户信息，可用于传入定制内容
    public let userInfo: [String: Any]
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
    public static let shared = Logger()
    
    /// Logger 包含的标识列表
    public var labels: [String]
    
    /// 日志等级
    public var logLevel: LogLevel
    
    /// 日志片段列表
    public var logSegments: [LogSegment]
        
    /// 日志记录器，默认控制台输出
    public var recorder: LogRecorder
        
    /// 默认抛出 LogFault，默认抛出异常
    public var throwFault: Bool
    
    /// 构造一个新的 Logger
    /// - Parameters:
    ///   - label: Logger 对应标识
    ///   - logLevel: 日志等级
    ///   - logSegments: 日志片段列表
    ///   - recorder: 日志对应记录者
    ///   - throwFault: LogFault 是否抛出异常，默认抛出异常
    public convenience init(
        label: String? = nil,
        logLevel: LogLevel = .debug,
        logSegments: [LogSegment] = .defaultSegments,
        recorder: LogRecorder = ConsoleRecorder(),
        throwFault: Bool = true
    ) {
        if let label = label {
            self.init(
                labels: [label],
                logLevel: logLevel,
                logSegments: logSegments,
                recorder: recorder,
                throwFault: throwFault
            )
        } else {
            self.init(
                labels: [],
                logLevel: logLevel,
                logSegments: logSegments,
                recorder: recorder,
                throwFault: throwFault
            )
        }
    }
    
    init(
        labels: [String],
        logLevel: LogLevel = .debug,
        logSegments: [LogSegment] = .defaultSegments,
        recorder: LogRecorder = ConsoleRecorder(),
        throwFault: Bool = true
    ) {
        self.labels = labels
        self.logLevel = logLevel
        self.logSegments = logSegments
        self.recorder = recorder
        self.throwFault = throwFault
    }
    
    /// 派生一个子 日志记录 实例，子实例除 labels 以为参数与原实例相同
    /// - Parameter label: 子 日志记录 实例 添加的标识
    /// - Returns: 返回新的子 日志记录 实例
    public func deriveLoggerWith(label: String) -> Logger {
        var newLables = labels
        newLables.append(label)
        return .init(
            labels: newLables,
            logLevel: logLevel,
            logSegments: logSegments,
            recorder: recorder,
            throwFault: throwFault
        )
    }
    
    /// 记录对应日志
    ///
    /// - Parameter level: 日志等级
    /// - Parameter message: 日志消息列表
    /// - Parameter userInfo: 用户自定义信息
    /// - Parameter file: 调用日志文件名
    /// - Parameter line: 调用日志文件对应行数
    /// - Parameter method: 调用日志文件对应方法名
    /// - Returns Void
    @usableFromInline
    func record(
        _ level: LogLevel,
        _ message: @autoclosure () -> Any,
        userInfo : [String: Any] = [:],
        _ file: String = #fileID,
        _ line: Int = #line,
        _ method: String = #function
    ) {
        guard logLevel <= level else {
            return
        }
        let logMessage = message()
        let messages = logMessage as? [Any] ?? [logMessage]
        let logContent: LogContent = .init(
            level: level,
            labels: labels,
            messages: messages,
            userInfo: userInfo,
            file: file,
            line: line,
            method: method
        )
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


extension Logger {
    @inlinable
    func trace(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.trace, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func debug(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.debug, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func info(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.info, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func notice(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.notice, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func warning(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.warning, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func error(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.error, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    func fault(_ message: @autoclosure () -> Any, userInfo : [String: Any] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.error, message(), userInfo: userInfo, file, line, method)
    }
}
