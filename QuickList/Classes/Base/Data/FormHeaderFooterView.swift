//
//  FormHeaderFooterView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/20.
//

import Foundation

open class FormHeaderFooterView: UIView {
    // MARK: - Public
    /// 是否使用自动布局计算尺寸
    open var useAutoLayout: Bool = false
    /// 高度（横向布局时为宽度），useAutoLayout设置以为true时无效
    open var height: ((CGSize, UICollectionView.ScrollDirection) -> CGFloat)?
    
    open func listOffsetChanged(to offset: CGPoint) {
        // Override this method to handle list offset changes
    }
    
    // MARK: - Life Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    open func setupUI() {
        
    }
    
    // MARK: Private
}
