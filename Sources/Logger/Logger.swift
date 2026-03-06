//
//  Logger.swift
//  
//
//  Created by 黄磊 on 2022/10/3.
//

import Foundation

/// 日志等级
public enum LogLevel : Int, Comparable, Sendable {
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
public struct LogContent: Sendable {
    /// 日志记录时间
    public let date: Date
    /// 日志等级
    public let level: LogLevel
    /// 当前使用 Logger 的标签列表
    public let labels: [String]
    /// 日志消息列表
    public let messages: [String]
    /// 日志用户信息，可用于传入定制内容
    public let userInfo: [String: Sendable]
    /// 调用日志文件名
    public let file: String
    /// 调用日志文件对应行数
    public let line: Int
    /// 调用日志文件对应方法名
    public let method: String
}

/// 日志记录单例
public final class Logger: Sendable {
    /// 日志记录共享单例
    public static let shared = Logger()
    
    class Storage: @unchecked Sendable {
        /// Logger 包含的标识列表
        var labels: [String]
        /// 日志等级
        var logLevel: LogLevel
        /// 日志片段列表
        var logSegments: [LogSegment]
        /// 日志记录器，默认控制台输出
        var recorder: LogRecorder
        /// 默认抛出 LogFault，默认抛出异常
        var throwFault: Bool
        
        init(labels: [String], logLevel: LogLevel, logSegments: [LogSegment], recorder: LogRecorder, throwFault: Bool) {
            self.labels = labels
            self.logLevel = logLevel
            self.logSegments = logSegments
            self.recorder = recorder
            self.throwFault = throwFault
        }
    }
    
    let storage: Storage
    
    /// Logger 包含的标识列表
    public var labels: [String] {
        get { DispatchQueue.syncOnLoggerQueue { storage.labels } }
        set { DispatchQueue.syncOnLoggerQueue { storage.labels = newValue } }
    }
    
    /// 日志等级
    public var logLevel: LogLevel {
        get { DispatchQueue.syncOnLoggerQueue { storage.logLevel } }
        set { DispatchQueue.syncOnLoggerQueue { storage.logLevel = newValue } }
    }
    
    /// 日志片段列表
    public var logSegments: [LogSegment] {
        get { DispatchQueue.syncOnLoggerQueue { storage.logSegments } }
        set { DispatchQueue.syncOnLoggerQueue { storage.logSegments = newValue } }
    }
        
    /// 日志记录器，默认控制台输出
    public var recorder: LogRecorder {
        get { DispatchQueue.syncOnLoggerQueue { storage.recorder } }
        set { DispatchQueue.syncOnLoggerQueue { storage.recorder = newValue } }
    }
        
    /// 默认抛出 LogFault，默认抛出异常
    public var throwFault: Bool {
        get { DispatchQueue.syncOnLoggerQueue { storage.throwFault } }
        set { DispatchQueue.syncOnLoggerQueue { storage.throwFault = newValue } }
    }
    
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
        recorder: LogRecorder = OSRecorder(),
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
        recorder: LogRecorder = OSRecorder(),
        throwFault: Bool = true
    ) {
        self.storage = .init(labels: labels, logLevel: logLevel, logSegments: logSegments, recorder: recorder, throwFault: throwFault)
    }
    
    /// 派生一个子 日志记录 实例，子实例除 labels 以外参数与原实例相同
    /// - Parameter label: 子 日志记录 实例 添加的标识
    /// - Returns: 返回新的子 日志记录 实例
    public func deriveLoggerWith(label: String) -> Logger {
        var newLabels = labels
        newLabels.append(label)
        return .init(
            labels: newLabels,
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
        userInfo : [String: Sendable] = [:],
        _ file: String = #fileID,
        _ line: Int = #line,
        _ method: String = #function
    ) {
        guard logLevel <= level else {
            return
        }
        let logMessage = message()
        let messages = (logMessage as? [Any] ?? [logMessage]).map { "\($0)" }
        
        DispatchQueue.syncOnLoggerQueue {
            let logContent: LogContent = .init(
                date: Date(),
                level: level,
                labels: storage.labels,
                messages: messages,
                userInfo: userInfo,
                file: file,
                line: line,
                method: method
            )
            let logStr = storage.logSegments.reduce(into: "") { partialResult, segment in
                switch segment {
                case .string(let str):
                    partialResult += str
                case .content(let converter):
                    partialResult += converter(logContent)
                }
            }
            storage.recorder.write(log: logStr, of: logContent)
            #if DEBUG
            if level == .fault && storage.throwFault { fatalError(messages.map {"\($0)"}.joined(separator: " ")) }
            #endif
        }
    }
}


extension Logger {
    @inlinable
    public func trace(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.trace, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func debug(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.debug, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func info(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.info, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func notice(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.notice, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func warning(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.warning, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func error(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.error, message(), userInfo: userInfo, file, line, method)
    }
    
    @inlinable
    public func fault(_ message: @autoclosure () -> Any, userInfo : [String: Sendable] = [:], file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
        record(.error, message(), userInfo: userInfo, file, line, method)
    }
}


extension DispatchQueue {
    
    // MARK: - LoggerQueue
    
    static let loggerQueueDispatchSpecificKey: DispatchSpecificKey<String> = .init()
    /// 共享 日志 队列
    static let loggerQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "logger.logger_queue")
        queue.setSpecific(key: loggerQueueDispatchSpecificKey, value: queue.label)
        return queue
    }()
    
    /// 检查是否允许在当前 queue 上，并同步执行代码
    static func syncOnLoggerQueue<T>(execute work: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: Self.loggerQueueDispatchSpecificKey) == Self.loggerQueue.label {
            return try work()
        }
        return try Self.loggerQueue.sync(execute: work)
    }
}
