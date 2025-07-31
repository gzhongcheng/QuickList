//
//  TextView+Limit.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

/// 中英文混编长度限制
public extension UITextView {
    // 限制字符输入,按英文，数字来判断，中文算2个
    func limitTextCount(_ limitCount: Int, endEditing: Bool = true, closure: (() -> Void)? = nil) -> Int {
        // 总的数量
        let allCount = self.text.count
        // 高亮的数量
        var markedCount = 0
        if let markedRange = self.markedTextRange, let markedText = self.text(in: markedRange) {
            markedCount = markedText.count
        }
        // 剩下在显示的文本数量
        let remainCount = allCount - markedCount
        let remainText = String(self.text.prefix(remainCount))
        
        /// 计算总数
        let  (totalCount, showText) = remainText.textCount(limitCount)
        if totalCount > limitCount {
            self.text = showText
            closure?()
            if endEditing { self.endEditing(true) }
        }
        return totalCount
    }
    
    func maxTextCount(_ limitCount: Int, endEditing: Bool = true, closure: (() -> Void)?) -> Int {
        return limitTextCount(limitCount, endEditing: endEditing, closure: closure)
    }
}
