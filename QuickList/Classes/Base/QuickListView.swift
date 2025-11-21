//
//  QuickListView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import UIKit
import SnapKit

open class QuickListView: UICollectionView {
    /**
     * 当前装饰控件（扩展属性）
     * Current decoration control (extension property)
     */
    var currentDecorationView: UIView?
    /**
     * 当前全局背景（扩展属性)
     * Current global background (extension property)
     */
    var currentBackgroundView: UIView?
    
    /**
     * 添加全局装饰控件到全局背景之上，如果没有全局背景，则放在最底层
     * Add global decoration control above global background, if no global background, place at bottom layer
     */
    public func addDecorationViewIfNeeded(_ view: UIView) {
        if currentDecorationView != nil, currentDecorationView == view {
            return
        }
        if currentDecorationView != view {
            currentDecorationView?.removeFromSuperview()
        }
        addSubview(view)
    }
    
    /**
     * 添加全局背景到最底层
     * Add global background to bottom layer
     */
    public func addBackgroundViewIfNeeded(_ view: UIView?) {
        if currentBackgroundView != nil, currentBackgroundView == view {
            return
        }
        if currentBackgroundView != view {
            currentBackgroundView?.removeFromSuperview()
        }
        guard let view = view else { return }
        view.layer.zPosition = 0
        addSubview(view)
    }
    
    public func scrollToItem(_ item: Item, at scrollPosition: UICollectionView.ScrollPosition, animation: Bool) {
        guard let indexPath = item.indexPath else { return }
        self.scrollToItem(at: indexPath, at: scrollPosition, animated: animation)
    }
    
    /**
     * handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
     * Handler delegate, including cell value change callbacks and scrollviewDelegate related methods
     */
    public weak var handerDelegate: FormViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    /**
     * collectionView代理处理类
     * CollectionView delegate handler class
     */
    public var handler = FormViewHandler()
    public var form: Form {
        get {
            handler.form
        }
        set {
            handler.form = newValue
        }
    }
    
    open override func adjustedContentInsetDidChange() {
        if self.bounds.size.width == 0 || self.bounds.size.height == 0 {
            needReload = true
            return
        }
        self.handler.layout.reloadAll()
    }
    
    /**
     * 滚动方向,默认为竖直方向滚动
     * Scroll direction, default is vertical scrolling
     */
    open var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            handler.scrollDirection = scrollDirection
        }
    }
    
    /**
     * 列表总尺寸变化回调
     * List total size change callback
     */
    public var listSizeChangedBlock: ((CGSize) -> Void)?
    private var currentContentSize: CGSize = .zero
    
    
    // MARK:- Initialization methods
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
        
        handler.layout.add(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if needReload {
            needReload = false
            reload()
            needUpdateLayout = false
            firstUpdateSection = .max
        } else if needUpdateLayout, firstUpdateSection < form.count {
            handler.updateLayout(sections: nil, othersInAnimation: updateLayoutInAnimation)
            firstUpdateSection = .max
            updateLayoutInAnimation = nil
        }
    }
    
    private var needUpdateLayout = true
    private var updateLayoutInAnimation: ListReloadAnimation?
    private var firstUpdateSection: Int = .max
    public func setNeedUpdateLayout(afterSection: Int, animation: ListReloadAnimation? = nil) {
        needUpdateLayout = true
        firstUpdateSection = min(firstUpdateSection, afterSection)
        updateLayoutInAnimation = animation ?? updateLayoutInAnimation
        setNeedsLayout()
    }
    
    private var needReload = true {
        didSet {
            setNeedsLayout()
        }
    }
    
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

extension QuickListView: QuickListCollectionLayoutDelegate {
    public func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout) {
        if currentContentSize != layout.collectionViewContentSize {
            currentContentSize = layout.collectionViewContentSize
            if let block = self.listSizeChangedBlock {
                block(layout.collectionViewContentSize)
            }
        }
    }
}
