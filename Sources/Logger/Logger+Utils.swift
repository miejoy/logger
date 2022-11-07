//
//  Logger+Utils.swift
//  
//
//  Created by 黄磊 on 2022/10/6.
//

import Foundation

// MARK: - 公共方法

@inlinable
public func LogTrace(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.trace, message(), file, line, method)
}

@inlinable
public func LogDebug(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.debug, message(), file, line, method)
}

@inlinable
public func LogInfo(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.info, message(), file, line, method)
}

@inlinable
public func LogNotice(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.notice, message(), file, line, method)
}

@inlinable
public func LogWarning(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.warning, message(), file, line, method)
}

@inlinable
public func LogError(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.error, message(), file, line, method)
}

@inlinable
public func LogFault(_ message: @autoclosure () -> Any, file: String = #file, _ line: Int = #line, _ method: String = #function) {
    LogRecord(.fault, message(), file, line, method)
}

// MARK: - 私有方法

@usableFromInline
func LogRecord(_ level: LogLevel, _ message: @autoclosure () -> Any, _ file: String = #file, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.logLevel <= level ? Logger.shared.record(level, message() , file, line, method) : nil
}
