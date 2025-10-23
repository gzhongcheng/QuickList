//
//  QuickSegmentVerticalMenuItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/9/1.
//

import Foundation
import SnapKit

// MARK: - QuickSegmentVerticalMenuItemCell
// QuickSegmentVerticalMenuItemCell
class QuickSegmentVerticalMenuItemCell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
    }
}

// MARK: - QuickSegmentVerticalMenuItem
// QuickSegmentVerticalMenuItem
final class QuickSegmentVerticalMenuItem: ItemOf<QuickSegmentVerticalMenuItemCell>, ItemType {
    /**
     * 计算得到的最大宽度
     * Calculated maximum width
     */
    var maxItemWidth: CGFloat?
    /**
     * 配置
     * Configuration
     */
    var config: QuickSegmentVerticalMenuConfig?
    /**
     * 页面容器高度
     * Page container height
     */
    var pageContainerHeight: CGFloat?
    
    weak var menuTabList: QuickListView?
    
    convenience init(
        identifier: String,
        pageContainerHeight: CGFloat? = nil,
        config: QuickSegmentVerticalMenuConfig,
        menuTabList: QuickListView
    ) {
        self.init(title: nil, tag: nil)
        self._identifier = identifier
        self.config = config
        self.pageContainerHeight = pageContainerHeight
        self.menuTabList = menuTabList
    }
    
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? QuickSegmentVerticalMenuItemCell else {
            return
        }
        if let menuTabList = menuTabList, menuTabList.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            if
                let menuBackground = config?.menuBackground
            {
                cell.contentView.addSubview(menuBackground)
                menuBackground.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            cell.contentView.addSubview(menuTabList)
            menuTabList.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private var _identifier: String = "QuickSegmentVerticalMenuItem"
    override var identifier: String {
        return _identifier
    }
    
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        let height = pageContainerHeight ?? view.bounds.height
        guard let config = config else {
            return CGSize(width: 200, height: height)
        }
        switch config.menuWidthType {
        case .fixed(let width):
            return CGSize(width: width, height: height)
        case .auto(let maxWidth):
            if let maxItemWidth = maxItemWidth {
                return CGSize(width: min(maxItemWidth, maxWidth), height: height)
            } else {
                return CGSize(width: maxWidth, height: height)
            }
        }
    }
}

