//
//  Logger+Utils.swift
//  
//
//  Created by 黄磊 on 2022/10/6.
//

import Foundation

/// 日志消息构造器
@resultBuilder
public struct LogMessageBuilder {
    public static func buildBlock(_ messages: Any...) -> [Any] {
        messages
    }
}

// MARK: - 公共方法

@inlinable
public func LogTrace(@LogMessageBuilder _ messages: () -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.trace, messages, file, line, method)
}

@inlinable
public func LogDebug(@LogMessageBuilder _ messages: () -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.debug, messages, file, line, method)
}

@inlinable
public func LogInfo(@LogMessageBuilder _ messages: () -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.info, messages, file, line, method)
}

@inlinable
public func LogNotice(@LogMessageBuilder _ messages: () -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.notice, messages, file, line, method)
}

//@inlinable
//public func LogWarning(@LogMessageBuilder _ messages: (Any...) -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
//    LogRecord(.warning, messages, file, line, method)
//}
//
//@inlinable
//public func LogError(@LogMessageBuilder _ messages: (Any...) -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
//    LogRecord(.error, messages, file, line, method)
//}
//
//@inlinable
//public func LogFault(@LogMessageBuilder _ messages: (Any...) -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
//    #if DEBUG
//    fatalError(messages().map {"\($0)"}.joined(separator: " "))
//    #endif
//    LogRecord(.fault, messages, file, line, method)
//}

/// 跟踪流程时使用
@inlinable
public func LogTrace(_ messages: Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.trace, messages, file, line, method)
}

@inlinable
public func LogDebug(_ messages: Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.debug, messages, file, line, method)
}

@inlinable
public func LogInfo(_ messages: Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.info, messages, file, line, method)
}

@inlinable
public func LogNotice(_ messages: Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.notice, messages, file, line, method)
}

@inlinable
public func LogWarning(_ messages: Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.warning, messages, file, line, method)
}

@inlinable
public func LogError(_ messages:Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.error, messages, file, line, method)
}

@inlinable
public func LogFault(_ messages:Any..., file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.fault, messages, file, line, method)
}


// MARK: - 私有方法

@usableFromInline
func LogRecord(_ level: LogLevel, @LogMessageBuilder _ messages: () -> [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.logLevel <= level ? Logger.shared.record(level, messages(), file, line, method) : nil
}

@usableFromInline
func LogRecord(_ level: LogLevel, _ messages: [Any], _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.logLevel <= level ? Logger.shared.record(level, messages, file, line, method) : nil
}
