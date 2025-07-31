//
//  QuickListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import UIKit
import SnapKit

open class QuickListView: UICollectionView {
    
    // handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
    public weak var handerDelegate: FormViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    // collectionView代理处理类
    public var handler = FormViewHandler()
    public var form: Form {
        get {
            handler.form
        }
        set {
            handler.form = newValue
        }
    }
    
    /// 滚动方向,默认为竖直方向滚动
    open var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            handler.scrollDirection = scrollDirection
        }
    }
    
    /// 列表总尺寸变化回调
    public var listSizeChangedBlock: ((CGSize) -> Void)?
    
    
    // MARK:- 初始化方法
    public convenience init(sections: [Section]? = nil) {
        self.init(frame: .zero)
        if let sections = sections {
            form.append(contentsOf: sections)
        }
    }
    
    public required init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: handler.layout)
        defaultSettings()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultSettings()
    }
    
    open func defaultSettings() {
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        handler.formView = self
        self.delegate = handler
        self.dataSource = handler
        cancelAdjustsScrollView()
        
        handler.layout.didFinishLayout = { [weak self] layout in
            if let block = self?.listSizeChangedBlock {
                block(layout.collectionViewContentSize)
            }
        }
    }
    
    /// 去除顶部留白
    public func cancelAdjustsScrollView() {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if needReload {
            needReload = false
            reload()
        }
        if !handler.addedLongTap {
            handler.addLongTapIfNeeded()
        }
    }
    
    private var needReload = true
    public func reload() {
        if self.superview == nil {
            needReload = true
            return
        }
        if self.bounds.size == .zero {
            needReload = true
            return
        }
        handler.reloadCollection()
    }
    
    public func selectItem(item: Item) {
        handler.selectItem(item: item)
    }
}


extension QuickListView: FormViewLongTapProtorol {
    
}
