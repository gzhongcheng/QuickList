//
//  FormCompressibleHeaderFooterView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/8/20.
//

import Foundation
import SnapKit

// MARK: - 自动调整内容大小的HeaderFooterView
open class FormCompressibleHeaderFooterView: UICollectionReusableView {
    // MARK: - Public
    /// 展示内容尺寸变化的方法，子类中可以在这里做内容的压缩、拉伸等处理
    open func didChangeDispalySize(to visibleSize: CGSize) {
        // 默认实现不做任何处理
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
    
    /// 设置UI布局
    open func setupUI() {
        // 默认实现不做任何UI设置
    }
    
    // MARK: Private
}
