//
//  GCD.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

/// 在主线程执行代码块
/// Execute code block on main thread
/// - Parameters:
///   - after: 延迟时间 / Delay time
///   - execute: 在主线程执行的代码块 / Code block to execute on main thread
public func mainThread(after: Double = 0.0, main execute: @escaping () -> Void) {
    if Thread.isMainThread {
        execute()
    } else if after == 0 {
        DispatchQueue.main.async(execute: execute)
    } else {
        let deadline = DispatchTime.now() + after
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: execute)
    }
}
