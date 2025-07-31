//
//  EmptyItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

// MARK:- EmptyCell
/// 分割线的cell
open class CollectionEmptyCell: ItemCell {
    
    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK:- LineRow
/// 定义好的占位item
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
    /// 固定尺寸
    var itemSize: CGSize?
    /// 固定高度
    var itemHeight: CGFloat?
    /// 固定宽度
    var itemWidth: CGFloat?
    /// 固定比例
    var itemRatio: CGSize?
    
    /// 固定尺寸创建
    /// - Parameter size: 尺寸
    public init(size: CGSize, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemSize = size
        config?(self)
    }
    
    /// 固定高度创建
    /// - Parameter height: 高度
    public init(height: CGFloat, weight: Int = 1, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        self.weight = weight
        itemHeight = height
        config?(self)
    }
    
    /// 固定宽度创建
    /// - Parameter width: 宽度
    public init(width: CGFloat, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemWidth = width
        config?(self)
    }
    
    /// 固定比例创建
    /// - Parameter ratio: 比例
    public init(ratio: CGSize, config: ((EmptyItem) -> Void)? = nil) {
        super.init(title: nil, tag: nil)
        itemRatio = ratio
        config?(self)
    }
    
    /// 计算尺寸
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
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
