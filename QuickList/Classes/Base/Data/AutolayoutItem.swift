//
//  AutolayoutItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation
import UIKit
import SnapKit

protocol AutolayoutItemProtocol: Item {
    var cacheEstimateItemSize: CGSize { get set }
    var cacheLayoutType: ItemCellLayoutType { get set }
}
/**
 * 使用自动布局自动计算尺寸的Iteml（如果可能，建议还是手动计算尺寸）
 * Item using autolayout to automatically calculate size (if possible, manual size calculation is still recommended)
 */
open class AutolayoutItemOf<Cell: ItemCell>: ItemOf<Cell>, AutolayoutItemProtocol {
    public override var cellSize: CGSize {
        didSet {
            if self.cellSize.width > 0, self.cellSize.height > 0 {
                /**
                 * 如果计算出来的尺寸还是0，就还需重新计算
                 * If the calculated size is still 0, it needs to be recalculated
                 */
                needReSize = false
            }
        }
    }
    
    /**
     * 估算的尺寸，用于初始计算
     * Estimated size, used for initial calculation
     */
    open var estimateSize: CGSize = CGSize(width: 100, height: 100)
    
    var cacheEstimateItemSize: CGSize = .zero
    var cacheLayoutType: ItemCellLayoutType = .vertical
    open override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        self.cacheEstimateItemSize = estimateItemSize
        self.cacheLayoutType = layoutType
        switch layoutType {
        case .vertical:
            if needReSize {
                return CGSize(width: estimateItemSize.width, height: self.estimateSize.height)
            } else {
                return CGSize(width: estimateItemSize.width, height: self.cellSize.height)
            }
        case .horizontal:
            if needReSize {
                return CGSize(width: self.estimateSize.width, height: estimateItemSize.height)
            } else {
                return CGSize(width: self.cellSize.width, height: estimateItemSize.height)
            }
        case .free:
            if needReSize {
                return self.estimateSize
            } else {
                return self.cellSize
            }
        }
    }
}
