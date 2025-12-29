//
//  QuickScrollViewCell.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

/// 自定义滚动视图的可重用单元格基类
/// Base class for reusable cell in custom scroll view
open class QuickScrollViewCell: UIView {
    
    // MARK: - Properties
    
    /// 复用标识符
    /// Reuse identifier
    public internal(set) var reuseIdentifier: String = ""
    
    /// 是否已经setUp
    /// Whether already set up
    public internal(set) var isSetup: Bool = false
    
    /// 内容视图（私有存储）
    /// Content view (private storage)
    private let _contentView: UIView = UIView()
    
    /// 内容视图（子类可覆盖）
    /// Content view (subclasses can override)
    open var contentView: UIView {
        return _contentView
    }
    
    /// 是否高亮
    /// Whether highlighted
    open var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                setHighlighted(isHighlighted, animated: true)
            }
        }
    }
    
    /// 是否选中
    /// Whether selected
    open var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                setSelected(isSelected, animated: true)
            }
        }
    }
    
    /// IndexPath
    public internal(set) var indexPath: IndexPath?
    
    /// 是否正在展示
    /// Whether is displaying
    public internal(set) var isShow: Bool = false
    
    /// 布局属性
    /// Layout attributes
    public internal(set) var layoutAttributes: QuickScrollViewLayoutAttributes?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        backgroundColor = .clear
    }
    
    // MARK: - Lifecycle Methods
    
    /// setUp, 子类中重写进行布局和一些永久性的配置
    /// setUp, override in subclasses for layout and some permanent configuration
    open func setup() {
        isSetup = true
    }
    
    /// 准备重用
    /// Prepare for reuse
    open func prepareForReuse() {
        isHighlighted = false
        isSelected = false
        indexPath = nil
    }
    
    /// 展示
    /// Will display
    open func willDisplay() {
        isShow = true
    }
    
    /// 结束展示
    /// Did end display
    open func didEndDisplay() {
        isShow = false
    }
    
    /// 选中时调用
    /// Called when selected
    open func didSelect() {}
    
    /// 设置高亮状态
    /// Set highlighted state
    open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // 子类可重写
        // Subclasses can override
    }
    
    /// 设置选中状态
    /// Set selected state
    open func setSelected(_ selected: Bool, animated: Bool) {
        // 子类可重写
        // Subclasses can override
    }
    
    /// 应用布局属性（QuickScrollView 专用）
    /// Apply layout attributes (for QuickScrollView)
    open func apply(_ layoutAttributes: QuickScrollViewLayoutAttributes) {
        self.layoutAttributes = layoutAttributes
        self.frame = layoutAttributes.frame
        self.alpha = layoutAttributes.alpha
        self.transform = layoutAttributes.transform
        self.layer.zPosition = CGFloat(layoutAttributes.zIndex)
        self.isHidden = layoutAttributes.isHidden
    }
    
    /// 应用 UICollectionView 布局属性（兼容 UICollectionView）
    /// Apply UICollectionView layout attributes (compatible with UICollectionView)
    open func applyCollectionViewLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
        self.alpha = layoutAttributes.alpha
        self.transform = layoutAttributes.transform
        self.layer.zPosition = CGFloat(layoutAttributes.zIndex)
        self.isHidden = layoutAttributes.isHidden
    }
    
    // MARK: - Touch Handling
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }
    
    // MARK: - ScrollObserverCellType
    
    /// 开始滚动/拖动
    /// Begin scrolling/dragging
    open func willBeginScrolling() {
        // 子类可重写
        // Subclasses can override
    }
    
    /// 滚动/拖动已结束
    /// Scrolling/dragging has ended
    open func didEndScrolling() {
        // 子类可重写
        // Subclasses can override
    }
}

// MARK: - ScrollObserverCellType Conformance

extension QuickScrollViewCell: ScrollObserverCellType {}
