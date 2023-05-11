//
//  LogSegment.swift
//  
//
//  Created by 黄磊 on 2022/10/4.
//

import Foundation

/// 日志片段
public enum LogSegment {
    /// 普通字符串片段
    case string(String)
    /// 可通过 日志内容 转字符串的片段
    case content(LogStringConverter<LogContent>)
}

extension Array where Element == LogSegment {
    public static let defaultSegments: [LogSegment] = [
        .content(.convert(\.date, with: .defaultDateConverter())),
        .string(" ["),
        .content(.convert(\.level, with: .defaultLevelConverter())),
        .string("] "),
        .content(.defaultLocationConverter()),
        .string(" ↔️ "),
        .content(.convert(\.labels, with: .defaultLabelsConverter())),
        .content(.convert(\.messages, with: .defaultMessagesConverter()))
    ]
}
