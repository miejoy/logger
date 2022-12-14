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
    case logContent(DataToStringConverter<LogContent>)
    /// 日志记录时间片段
    case dateTime(DateFormatter)
}
