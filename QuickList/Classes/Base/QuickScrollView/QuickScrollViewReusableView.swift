//
//  QuickScrollViewReusableView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

/// 自定义滚动视图的可重用补充视图基类
/// Base class for reusable supplementary view in custom scroll view
open class QuickScrollViewReusableView: UIView {
    
    // MARK: - Properties
    
    /// 复用标识符
    /// Reuse identifier
    public internal(set) var reuseIdentifier: String = ""
    
    /// 元素类型
    /// Element kind
    public internal(set) var elementKind: String = ""
    
    /// IndexPath
    public internal(set) var indexPath: IndexPath?
    
    /// 布局属性
    /// Layout attributes
    public internal(set) var layoutAttributes: QuickScrollViewLayoutAttributes?
    
    // MARK: - Initialization
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    // MARK: - Lifecycle Methods
    
    /// 准备重用
    /// Prepare for reuse
    open func prepareForReuse() {
        indexPath = nil
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
}
