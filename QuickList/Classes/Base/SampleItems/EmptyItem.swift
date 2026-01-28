//
//  EmptyItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

// MARK:- EmptyCell
/**
 * 分割线的cell
 * Separator line cell
 */
open class CollectionEmptyCell: ItemCell {
    
    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK:- LineRow
/**
 * 定义好的占位item
 * Predefined placeholder item
 */
public final class EmptyItem: ItemOf<CollectionEmptyCell> {
    
    public override var identifier: String {
        return "EmptyItem_\(tag ?? "")"
    }
    
    public override var isDisabled: Bool {
        set {
        }
        get {
            true
        }
    }
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
    
    // 优先级: 固定尺寸 > 固定宽/高度 > 固定比例 > 0 
    // Priority: Fixed size > Fixed width/height > Fixed ratio > 0
    /**
     * 固定尺寸
     * Fixed size
     */
    var itemSize: CGSize?
    /**
     * 固定高度
     * Fixed height
     */
    var itemHeight: CGFloat?
    /**
     * 固定宽度
     * Fixed width
     */
    var itemWidth: CGFloat?
    /**
     * 固定比例
     * Fixed ratio
     */
    var itemRatio: CGSize?
    
    /**
     * 固定尺寸创建
     * Create with fixed size
     * - Parameter size: 尺寸 / Size
     */
    public init(size: CGSize, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemSize = size
        self.isSelectable = false
        config?(self)
    }
    
    /**
     * 固定高度创建
     * Create with fixed height
     * - Parameter height: 高度 / Height
     */
    public init(height: CGFloat, weight: Int = 1, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        self.weight = weight
        itemHeight = height
        self.isSelectable = false
        config?(self)
    }
    
    /**
     * 固定宽度创建
     * Create with fixed width
     * - Parameter width: 宽度 / Width
     */
    public init(width: CGFloat, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemWidth = width
        self.isSelectable = false
        config?(self)
    }
    
    /**
     * 固定比例创建
     * Create with fixed ratio
     * - Parameter ratio: 比例 / Ratio
     */
    public init(ratio: CGSize, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemRatio = ratio
        self.isSelectable = false
        config?(self)
    }
    
    /**
     * 计算尺寸
     * Calculate size
     */
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        if let size = itemSize {
            return size
        }
        switch layoutType {
        case .vertical:
            if let heigh = itemHeight {
                return CGSize(width: estimateItemSize.width, height: heigh)
            }
            if let ratio = itemRatio {
                return CGSize(width: estimateItemSize.width, height: estimateItemSize.width * ratio.height / ratio.width)
            }
        case .horizontal:
            if let width = itemWidth {
                return CGSize(width: width, height: estimateItemSize.height)
            }
            if let ratio = itemRatio {
                return CGSize(width: estimateItemSize.height * ratio.width / ratio.height, height: estimateItemSize.height)
            }
        case .free:
            return CGSize(width: itemWidth ?? 0, height: itemHeight ?? 0)
        }
        return .zero
    }
}
