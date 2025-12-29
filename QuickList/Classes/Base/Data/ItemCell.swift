//
//  ItemCell.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import UIKit

/// 滚动观察者协议
/// Scroll observer protocol
public protocol ScrollObserverCellType {
    /**
     * 开始滚动/拖动
     * Begin scrolling/dragging
     */
    func willBeginScrolling()
    
    /**
     * 滚动/拖动已结束
     * Scrolling/dragging has ended
     */
    func didEndScrolling()
}

/// ItemCell 基类 - 直接继承自 QuickScrollViewCell
/// ItemCell base class - directly inherits from QuickScrollViewCell
open class ItemCell: QuickScrollViewCell {
    
    // MARK: - Properties
    
    /**
     * cell关联的item
     * Item associated with cell
     */
    public internal(set) weak var item: Item?
    
    // MARK: - Initialization
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    /**
     * setUp, 子类中重写进行布局和一些永久性的配置, 建议使用如下方式调用：
     * setUp, override in subclasses for layout and some permanent configuration, recommended to call as follows:
     * open override func setup() {
     *     super.setup()
     *     // ...
     * }
     */
    open override func setup() {
        super.setup()
    }
    
    /**
     * 准备重用
     * Prepare for reuse
     */
    open override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
    }
    
    /**
     * 展示
     * Will display
     */
    open override func willDisplay() {
        super.willDisplay()
    }
    
    /**
     * 结束展示
     * Did end display
     */
    open override func didEndDisplay() {
        super.didEndDisplay()
    }
    
    /**
     * cell 选中时调用，子类中可重写该方法做改变样式等操作
     * Called when cell is selected, subclasses can override this method to change styles and other operations
     */
    open override func didSelect() {
        super.didSelect()
    }
    
    // MARK: - Layout Attributes
    
    /**
     * 应用 QuickScrollView 布局属性
     * Apply QuickScrollView layout attributes
     */
    open override func apply(_ layoutAttributes: QuickScrollViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
    
    /**
     * 应用 UICollectionView 布局属性（兼容旧接口）
     * Apply UICollectionView layout attributes (compatible with old interface)
     */
    open override func applyCollectionViewLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyCollectionViewLayoutAttributes(layoutAttributes)
    }
}
