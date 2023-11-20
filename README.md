# Logger

Logger 是一个简单的日志输出工具，内部提供可自定义的日志输出格式

[![Swift](https://github.com/miejoy/logger/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/logger/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/logger/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/logger)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-5.7-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 15.0+ / macOS 12+
- Xcode 14.0+
- Swift 5.7+

## 简介

### 该日志工具主要分为三部分：

- 日志输入，即如何调用
  - Logger+Utils 提供方便的日志调用工具方法
  - 也可以直接调用 Logger 的相关方法记录日志
- 日志处理
  - 日志处理采用分片单独处理后再拼接的方式，可以高度自定义
  - LogSegment 即为日志的一个片段
  - LogStringConverter 提供方便日志分片处理功能
- 日志输出
  - LogRecorder 协议定义的日志输出的记录者，
  - 这里提供的默认输出是 ConsoleRecorder(控制台记录器)
  - 用户可自定义日志输出记录器，例如定义一个文件日志记录器 LogFileRecorder

### 日志有如下几个等级：

- trace: 追踪日志，显示非常详细
- debug: 调试日志，显示对调试有用的信息
- info: 信息日志，显示主要运行信息
- notice: 通知日志，显示需要用户注意的信息，比如模块加载
- warning: 警告日志，提示可能存在潜在错误，需要程序员注意
- error: 错误日志，发生了错误
- fault: 致命错误，debug 模式将中断程序

### 日志片段有如下几个定义：

- string: 普通字符串片段
- content: 可通过 日志内容 转字符串的片段

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/logger.git", from: "0.1.0"),
]
```

## 使用

### 日志工具设置

- logLevel: 设置当前日志等级，默认是 debug
- logSegments: 设置日志片段列表，这里提供默认的片段配置，用户可以进行高度定制，
- recorder: 日志记录器，默认是控制台输出
- throwFault: 是否将 fault 日志抛出异常，默认是

```swift
import Logger

// 设置日志等级
Logger.shared.logLevel = .info
// 设置日志片段列表
Logger.shared.logSegments = [.content(.convert(\.messages, with: .defaultMessagesConverter()))]
// 设置日志输出记录器
Logger.shared.recorder = LogFileRecorder()
```

### 调用日志打印方法

- 有如下两类打印工具方法:
  - 使用直接传参方式的打印方法。如：LogTrace、LogDebug、LogInfo、LogNotice、LogWarning、LogError、LogFault
  - 使用 Block 回调方式传入打印信息的打印方法（这种方式只有在对应日志可以被打印时调用 block）。如：LogTrace、LogDebug、LogInfo、LogNotice

```swift
import Logger

let logStr = "test"

// 打印日志
LogTrace(logStr)
// 可传入多个参数
LogDebug([logStr, logStr])
LogInfo(logStr)
LogNotice(logStr)
LogWarning(logStr)
LogError(logStr)
LogFault(logStr)
```

### 派生子日志工具

```swift
import Logger

// 派生子日志工具
let subLogger = Logger.shared.deriveLoggerWith(label: "Sub") 

// 使用子日志工具打印日志
let logStr = "test"
subLogger.info(logStr)
```

### 日志片段列表设置详情

```swift
import Logger

Logger.shared.logSegments = [
    .content(.convert(\.date, with: .defaultDateConverter())),                  // 时间片段，如：2022-10-09 22:55:44.220+0800
    .string("|"),                                                               // 字符串片段，输出：|
    .content(.convert(\.file, with: .defaultFileConverter(fixLength: 0))),      // 调用日志文件片段，如：LoggerTests.swift
    .string("("),                                                               // 字符串片段，输出：(
    .content(.convert(\.line, with: .defaultLineConverter(minLength: 0))),      // 调用日志文件对应行数片段，如：224
    .string(")"),                                                               // 字符串片段，输出：)
    .content(.convert(\.method, with: .defaultMethodConverter())),              // 调用日志文件对应方法片段，如：testLogSegment()
    .string(": "),                                                              // 字符串片段，输出：': '
    .content(.convert(\.messages, with: .defaultMessagesConverter("\n")))
]

LogInfo("test")
// 最终日志输出如下：
// 2022-10-09 23:35:52.909+0800|LoggerTests.swift(224).testLogSegment(): test
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

Logger is available under the MIT license. See the LICENSE file for more info.
