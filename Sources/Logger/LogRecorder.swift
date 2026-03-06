//
//  LogRecorder.swift
//
//
//  Created by 黄磊 on 2022/10/8.
//

import Foundation
import OSLog

/// 日志记录协议，主要是输出日志记录器
public protocol LogRecorder {
    /// 记录器写入日志方法
    func write(log: String, of logContent: LogContent)
}

/// 混合日志输出
public struct CombineRecorder: LogRecorder {

    let recorders: [LogRecorder]

    public init(_ recorders: LogRecorder...) {
        self.recorders = recorders
    }

    public func write(log: String, of logContent: LogContent) {
        recorders.forEach { $0.write(log: log, of: logContent) }
    }
}

/// 系统日志输出
public struct OSRecorder: LogRecorder {

    let logger: os.Logger

    public init(logger: os.Logger = os.Logger(subsystem: "com.miejoy.logger", category: "default")) {
        self.logger = logger
    }

    public func write(log: String, of logContent: LogContent) {
        switch logContent.level {
        case .trace, .debug:
            logger.debug("\(log)")
        case .info:
            logger.info("\(log)")
        case .notice:
            logger.notice("\(log)")
        case .warning:
            logger.warning("\(log)")
        case .error:
            logger.error("\(log)")
        case .fault:
            logger.critical("\(log)")
        }
    }
}
