//
//  QuickSegmentPageViewController.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation

/// 分段页面控制器协议，用于展示分段页面内容
public protocol QuickSegmentPageViewDelegate: UIViewController {
    var pageTabItem: Item { get }
    
    func listScrollView() -> QuickSegmentPageScrollViewType?
}
