//
//  QuickSegmentSinglePageItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
import SnapKit

// 单个页面的Item
// MARK:- QuickSegmentSinglePageItemCell
class QuickSegmentSinglePageItemCell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
    }
}

// MARK:- QuickSegmentSinglePageItem
final class QuickSegmentSinglePageItem: ItemOf<QuickSegmentSinglePageItemCell>, ItemType {
    var pageViewController: QuickSegmentPageViewDelegate?
    convenience init(
        pageViewController: QuickSegmentPageViewDelegate,
        _ initializer: ((QuickSegmentSinglePageItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewController = pageViewController
        initializer?(self)
    }
    
    // 更新cell的布局
    override func updateCell() {
        super.updateCell()
        guard let cell = cell as? QuickSegmentSinglePageItemCell else {
            return
        }
        
    }
    
    override var identifier: String {
        return "QuickSegmentSinglePageItem"
    }
    
    
    /// 计算尺寸
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return CGSize(width: estimateItemSize.width, height: self.section?.form?.delegate?.getViewSize().height ?? 0)
        case .horizontal:
            return CGSize(width: self.section?.form?.delegate?.getViewSize().width ?? 0, height: estimateItemSize.height)
        case .free:
            return CGSize(width: self.section?.form?.delegate?.getViewSize().width ?? 0, height: self.section?.form?.delegate?.getViewSize().height ?? 0)
        }
    }
}

