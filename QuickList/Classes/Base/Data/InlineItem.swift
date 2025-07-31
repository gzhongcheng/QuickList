//
//  InlineItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation

// 内联Row协议基类
public protocol  BaseInlineItemType {
    /// 展开（打开）内联行
    func expandInlineItem()

    /// 折叠（关闭）内联行
    func collapseInlineItem()

    /// 更改内联行的状态（展开/折叠）
    func toggleInlineItem()
}
