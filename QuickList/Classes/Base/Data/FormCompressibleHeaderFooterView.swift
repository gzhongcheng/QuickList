//
//  FormCompressibleHeaderFooterView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/20.
//

import Foundation
import SnapKit

// MARK: - Auto-adjusting content size HeaderFooterView
open class FormCompressibleHeaderFooterView: UICollectionReusableView {
    // MARK: - Public
    /**
     * 展示内容尺寸变化的方法，子类中可以在这里做内容的压缩、拉伸等处理
     * Method for display content size changes, subclasses can handle content compression, stretching, etc. here
     */
    open func didChangeDispalySize(to visibleSize: CGSize) {
        // 默认实现不做任何处理
        // Default implementation does nothing
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
    
    /**
     * 设置UI布局
     * Setup UI layout
     */
    open func setupUI() {
        // 默认实现不做任何UI设置
        // Default implementation does no UI setup
    }
    
    // MARK: Private
}
