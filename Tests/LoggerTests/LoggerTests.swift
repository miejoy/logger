//
//  LoggerTests.swift
//  
//
//  Created by 黄磊 on 2022/10/8.
//

import XCTest
@testable import Logger

final class LoggerTests: XCTestCase {
    
    func clearAll() {
        Logger.shared.logLevel = .debug
        Logger.shared.logSegments = .defaultSegments
        Logger.shared.recorder = ConsoleRecorder()
        Logger.shared.throwFault = true
    }
    
    func testLogInfo() {
        clearAll()
        LogInfo("test")
    }
    
    func testLoggerUtils() {
        clearAll()
        Logger.shared.logLevel = .trace
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
        Logger.shared.throwFault = false
        
        let logStr = "test"
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        var index = 0
        
        LogTrace(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        LogDebug([logStr, logStr])
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr + " " + logStr)
        index += 1
        
        LogInfo(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        LogNotice(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        LogWarning(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        LogError(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        LogFault(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
    }
    
    func testLogTraceWithBlock() {
        clearAll()
        var test = Test()
        Logger.shared.logLevel = .trace
        Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        LogTrace(test.call())
        
        XCTAssertEqual(test.isCall, true)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], test.call())
        
        Logger.shared.logLevel = .debug
        test.isCall = false
        LogTrace {
            test.call()
        }
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(test.isCall, false)
    }
    
    func testLogDebugWithBlock() {
        clearAll()
        var test = Test()
        Logger.shared.logLevel = .debug
        Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        LogDebug(test.call())
        
        XCTAssertEqual(test.isCall, true)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], test.call())
        
        Logger.shared.logLevel = .info
        test.isCall = false
        LogDebug([test.call(), test.call(), ""])
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(test.isCall, false)
    }
    
    func testLogInfoWithBlock() {
        clearAll()
        var test = Test()
        Logger.shared.logLevel = .info
        Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        LogInfo(test.call())
        
        XCTAssertEqual(test.isCall, true)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], test.call())
        
        Logger.shared.logLevel = .notice
        test.isCall = false
        LogInfo {
            test.call()
        }
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(test.isCall, false)
    }
    
    func testLogNoticeWithBlock() {
        clearAll()
        var test = Test()
        Logger.shared.logLevel = .notice
        Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        LogNotice(test.call())
        
        XCTAssertEqual(test.isCall, true)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], test.call())
        
        Logger.shared.logLevel = .warning
        test.isCall = false
        LogNotice {
            test.call()
        }
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(test.isCall, false)
    }
    
    func testLogSegment() {
        clearAll()
        let fakeRecorder = FakeRecoder()
        Logger.shared.recorder = fakeRecorder
        Logger.shared.logSegments = [
            .content(.convert(\.file, with: .defaultFileConverter(fixLength: 0))),
            .string("("),
            .content(.convert(\.line, with: .defaultLineConverter(minLength: 0))),
            .string(")"),
            .content(.convert(\.method, with: .defaultMethodConverter())),
            .string(": "),
            .content(.convert(\.messages, with: .defaultMessagesConverter("\n")))
        ]
        
        let logString1 = "test1"
        let logString2 = "test2"
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        var line = #line
        LogInfo(logString1)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], "LoggerTests.swift(\(line + 1)).testLogSegment(): \(logString1)")
        
        line = #line
        LogInfo([logString1, logString2])
        XCTAssertEqual(fakeRecorder.logList.count, 2)
        XCTAssertEqual(fakeRecorder.logList[1], "LoggerTests.swift(\(line + 1)).testLogSegment(): \(logString1)\n\(logString2)")
    }
    
    func testCustomLogSegment() {
        clearAll()
        let fakeRecorder = FakeRecoder()
        let sharedLabel = "Shared"
        Logger.shared.labels = [sharedLabel]
        Logger.shared.recorder = fakeRecorder
        Logger.shared.logSegments = [
            .content(.defaultFileAndLineConverter()),
            .string(": "),
            .content(.convert(\.labels, with: .defaultLabelsConverter())),
            .content(.convert(\.messages, with: .defaultMessagesConverter("\n")))
        ]
        
        let logString1 = "test1"
        let logString2 = "test2"
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        var line = #line
        LogInfo(logString1)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], "LoggerTests.swift(\(line + 1))·············: [\(sharedLabel)] \(logString1)")
        
        line = #line
        LogInfo([logString1, logString2])
        XCTAssertEqual(fakeRecorder.logList.count, 2)
        XCTAssertEqual(fakeRecorder.logList[1], "LoggerTests.swift(\(line + 1))·············: [\(sharedLabel)] \(logString1)\n\(logString2)")
    }
    
    func testLoggerPerformance() {
        clearAll()
        let logger = Logger.shared
        logger.recorder = NullRecorder()
        logger.throwFault = false
        
        let startTime1 = Date()
        for _ in 0 ... 1000 {
            logger.recordSimple(.trace, ["test"])
            logger.recordSimple(.debug, ["test"])
            logger.recordSimple(.info, ["test"])
            logger.recordSimple(.notice, ["test"])
            logger.recordSimple(.warning, ["test"])
            logger.recordSimple(.error, ["test"])
            logger.recordSimple(.fault, ["test"])
        }
        let endTime1 = Date()
        let dTime1 = endTime1.timeIntervalSince1970 - startTime1.timeIntervalSince1970
        
        let startTime = Date()
        for _ in 0 ... 1000 {
            logger.record(.trace, ["test"])
            logger.record(.debug, ["test"])
            logger.record(.info, ["test"])
            logger.record(.notice, ["test"])
            logger.record(.warning, ["test"])
            logger.record(.error, ["test"])
            logger.record(.fault, ["test"])
        }
        let endTime = Date()
        let dTime = endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
                
        print("Direct \(dTime/dTime1)")
    }
    
    func testLoggerIndependent() {
        let fakeRecorder = FakeRecoder()
        let logger = Logger(label: "label", logLevel: .trace, logSegments: [.content(.convert(\.messages, with: .defaultMessagesConverter()))], recorder: fakeRecorder, throwFault: false)
        
        let logStr = "test"
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        var index = 0
        
        logger.trace(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        logger.debug([logStr, logStr])
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr + " " + logStr)
        index += 1
        
        logger.info(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        logger.notice(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        logger.warning(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        logger.error(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
        
        logger.fault(logStr)
        XCTAssertEqual(fakeRecorder.logList.count, index + 1)
        XCTAssertEqual(fakeRecorder.logList[index], logStr)
        index += 1
    }
    
    func testDeriveLogger() {
        let fakeRecorder = FakeRecoder()
        let logSegments = [LogSegment]([LogSegment].defaultSegments.dropFirst())
        let firstLabel = "First"
        let logger = Logger(label: firstLabel, logLevel: .trace, logSegments: logSegments, recorder: fakeRecorder, throwFault: false)
        
        let secondLabel = "Second"
        let subLogger = logger.deriveLoggerWith(label: secondLabel)
        
        XCTAssertEqual(fakeRecorder.logList.count, 0)
        
        let logString1 = "test1"
        let line = #line
        subLogger.trace(logString1)
        XCTAssertEqual(fakeRecorder.logList.count, 1)
        XCTAssertEqual(fakeRecorder.logList[0], " [🐾 Trace  ] LoggerTests.swift(\(line + 1)).testDeriveLogger() ↔️ [\(firstLabel)][\(secondLabel)] \(logString1)")
    }
    
    func testCombineRecorder() {
        clearAll()
        let logger = Logger.shared
        logger.logLevel = .trace
        let fakeRecorder1 = FakeRecoder()
        let fakeRecorder2 = FakeRecoder()
        logger.recorder = CombineRecorder(fakeRecorder1, ConsoleRecorder(), fakeRecorder2)
        logger.logSegments = [
            .content(.convert(\.messages, with: .defaultMessagesConverter(" ")))
        ]
        
        XCTAssertEqual(fakeRecorder1.logList.count, 0)
        XCTAssertEqual(fakeRecorder2.logList.count, 0)
        
        let logString1 = "test1"
        logger.trace(logString1)
        XCTAssertEqual(fakeRecorder1.logList.count, 1)
        XCTAssertEqual(fakeRecorder2.logList.count, 1)
        XCTAssertEqual(fakeRecorder1.logList[0], "\(logString1)")
        XCTAssertEqual(fakeRecorder2.logList[0], "\(logString1)")
    }
}


struct NullRecorder: LogRecorder {
    func write(log: String, of logContent: LogContent) {
    }
}

struct Test {
    var isCall = false
    
    mutating func call() -> String {
        self.isCall = true
        return "test"
    }
}

class FakeRecoder: LogRecorder {
    var logList: [String] = []
    func write(log: String, of logContent: LogContent) {
        logList.append(log)
    }
}

extension Logger {
    func recordSimple(
        _ level: LogLevel,
        _ messages: [Any],
        userInfo : [String: String] = [:],
        _ file: String = #file,
        _ line: Int = #line,
        _ method: String = #function
    ) {
        var levelStr: String
        switch level {
        case .trace:    levelStr = "🐾 Trace  "
        case .debug:    levelStr = "🔍 Debug  "
        case .info:     levelStr = "📗 Info   "
        case .notice:   levelStr = "📣 Notice "
        case .warning:  levelStr = "⚠️ Warning"
        case .error:    levelStr = "‼️ Error  "
        case .fault:    levelStr = "🚫 Fault  "
        }
        let logContent: LogContent = .init(date: Date(), level: level, labels: labels, messages: messages, userInfo: userInfo, file: file, line: line, method: method)
        let logStr = s_defaultDateFormat.string(from: Date()) + " [\(levelStr)] " + file.suffix(from: file.lastIndex(of: "/") ?? file.startIndex) + "(\(line)).\(method)" +  " ↔️ " + messages.map( { "\($0)" }).joined(separator: " ")
        recorder.write(log: logStr, of: logContent)
    }
}

extension LogStringConverter {
    public static func defaultFileAndLineConverter(fixLength: Int = 35) -> LogStringConverter<LogContent> {
        .init { logContent in
            let line = "(\(logContent.line))"
            if let index = logContent.file.lastIndex(of: "/") {
                return logContent.file.suffix(from: logContent.file.index(index, offsetBy: 1)) + line
            }
            return logContent.file + line
        }
        .rightPadding(to: fixLength, withPad: "·")
    }
}
