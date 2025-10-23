//
//  QuickSegmentHorizontalMenuItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/29.
//

import Foundation
import SnapKit

// MARK: - QuickSegmentHorizontalMenuItemCell
// QuickSegmentHorizontalMenuItemCell
class QuickSegmentHorizontalMenuItemCell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
    }
}

// MARK: - QuickSegmentHorizontalMenuItem
// QuickSegmentHorizontalMenuItem
final class QuickSegmentHorizontalMenuItem: ItemOf<QuickSegmentHorizontalMenuItemCell>, ItemType {
    
    var pageContainerHeight: CGFloat?
    
    var config: QuickSegmentHorizontalMenuConfig?
    
    weak var menuTabList: QuickListView?
    
    convenience init(
        identifier: String,
        pageContainerHeight: CGFloat? = nil,
        config: QuickSegmentHorizontalMenuConfig,
        menuTabList: QuickListView
    ) {
        self.init(title: nil, tag: nil)
        self._identifier = identifier
        self.pageContainerHeight = pageContainerHeight
        self.config = config
        self.menuTabList = menuTabList
    }
    
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? QuickSegmentHorizontalMenuItemCell else {
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
    
    private var _identifier: String = "QuickSegmentHorizontalMenuItem"
    override var identifier: String {
        return _identifier
    }
    
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        return CGSize(width: pageContainerHeight ?? view.bounds.width, height: config?.menuHeight ?? 44)
    }
}

