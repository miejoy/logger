//
//  Logger+Utils.swift
//  
//
//  Created by 黄磊 on 2022/10/6.
//

import Foundation

// MARK: - 公共方法

@inlinable
public func LogTrace(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.trace, message(), file, line, method)
}

@inlinable
public func LogDebug(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.debug, message(), file, line, method)
}

@inlinable
public func LogInfo(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.info, message(), file, line, method)
}

@inlinable
public func LogNotice(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.notice, message(), file, line, method)
}

@inlinable
public func LogWarning(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.warning, message(), file, line, method)
}

@inlinable
public func LogError(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.error, message(), file, line, method)
}

@inlinable
public func LogFault(_ message: @autoclosure () -> Any, file: String = #fileID, _ line: Int = #line, _ method: String = #function) {
    Logger.shared.record(.fault, message(), file, line, method)
}
