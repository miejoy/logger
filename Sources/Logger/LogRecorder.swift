//
//  File.swift
//  
//
//  Created by 黄磊 on 2022/10/8.
//

import Foundation

/// 日志记录协议，主要是输出日志记录器
public protocol LogRecorder {
    /// 记录器下入日志方法
    func write(log: String, of logContent: LogContent)
}

// 控制台日志输出
public struct ConsoleRecorder: LogRecorder {
    public func write(log: String, of logContent: LogContent) {
        print(log)
    }
}
