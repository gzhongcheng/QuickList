//
//  QuickSegmentPageViewController.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation

/**
 * 分段页面控制器协议，用于展示分段页面内容
 * Segment page controller protocol, used to display the content of the segmented page
 */
public protocol QuickSegmentPageViewDelegate: UIViewController {
    var pageTabItem: Item { get }
    
    func listScrollView() -> QuickSegmentPageScrollViewType?
}
