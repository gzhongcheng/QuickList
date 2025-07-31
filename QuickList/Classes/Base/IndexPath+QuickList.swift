//
//  IndexPath+QuickList.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/10.
//

import Foundation

extension IndexPath {
    /// 获取section
    func safeSection() -> Int? {
        if self.count == 0 {
            return nil
        }
        if self.count == 1 {
            return self[0]
        }
        return section
    }
}
