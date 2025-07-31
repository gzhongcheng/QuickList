//
//  ItemCell.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation

public protocol ScrollObserverCellType {
    /// 开始滚动/拖动
    func willBeginScrolling()
    
    /// 滚动/拖动已结束
    func didEndScrolling()
}

open class ItemCell: UICollectionViewCell {
    // cell关联的item
    public internal(set) weak var item: Item?
    // 是否已经setUp
    public internal(set) var isSetup: Bool = false
    
    /** setUp, 子类中重写进行布局和一些永久性的配置, 建议使用如下方式调用：
    open override func setup() {
        super.setup()
        // ...
    }
    */
    open func setup() {
        isSetup = true
    }
    
    /// 展示 / 结束展示
    public var isShow: Bool = false
    open func willDisplay() {
        isShow = true
    }
    open func didEndDisplay() {
        isShow = false
    }
    
    // cell 选中时调用，子类中可重写该方法做改变样式等操作
    open func didSelect() {}
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }
}
