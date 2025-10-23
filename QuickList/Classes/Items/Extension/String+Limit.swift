//
//  String+Limit.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

/**
 * 中英文混编字符串长度计算
 * Calculate string length of mixed Chinese and English characters
 */
public extension String {
    /**
     * 计算字符串长度（中文算2，英文算1）
     * Calculate string length (Chinese characters are 2, English characters are 1)
     * - Returns: 文字长度
     */
    func textCount() -> Int {
        return textCount(Int.max).0
    }
    
    /**
     * 限制字符输入, 计算字符串长度（中文算2，英文算1）
     * Limit character input, calculate string length (Chinese characters are 2, English characters are 1)
     * - Returns: ( 文字长度，限制后的文字 )
     */
    func textCount(_ limitCount: Int) -> (Int, String) {
        var totalCount = 0
        var showText = ""
        let patternChinese = "[\\u4e00-\\u9fa5]|[\\u3000-\\u301e\\ufe10-\\ufe19\\ufe30-\\ufe44\\ufe50-\\ufe6b\\uFF01-\\uFFEE]"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: patternChinese, options: .caseInsensitive)
        } catch {
            
        }
        for char in self {
            var addCount = char.utf8.count
            let checkStr = String(char)
            
            if let _ = regex?.firstMatch(in: checkStr, options: [], range: NSRange(location: 0, length: checkStr.count)) {
                addCount = 2
            }
            
            totalCount += addCount
            
            if totalCount <= limitCount {
                showText.append(char)
            }
        }
        return (totalCount, showText)
    }
}
