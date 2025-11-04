//
//  CustomViewItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/11/22.
//

import Foundation
import SnapKit

// MARK:- CustomViewItemCell
public class CustomViewItemCell: ItemCell {
    
    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func addCustomViewIfNeeded(_ view: UIView) {
        guard contentView.subviews.first != view else {
            return
        }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        contentView.addSubview(view)
    }
}

// MARK:- CustomViewItem
/**
 * 用于将已有的View快速包装成Item的容器
 * Container for quickly wrapping existing Views into Items
 */
public final class CustomViewItem: AutolayoutItemOf<CustomViewItemCell>, ItemType {
    var customIdentifier: String = "CustomViewItemCell"
    /**
     * 当前的自定义view
     * Current custom view
     */
    public var customView: UIView?
    /**
     * 自定义view的布局逻辑
     * Custom view layout logic
     */
    public var customViewLayoutBuilder: ((UIView) -> Void)? = { view in
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public init(identifier: String, viewCreator: () -> UIView, _ initializer: (CustomViewItem) -> Void) {
        super.init()
        customIdentifier = identifier
        customView = viewCreator()
        initializer(self)
    }
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
    
    /**
     * 更新cell的布局
     * Update cell layout
     */
    public override func updateCell() {
        super.updateCell()
        guard
            let cell = cell as? CustomViewItemCell,
            let customView = customView
        else {
            return
        }
        cell.addCustomViewIfNeeded(customView)
        customViewLayoutBuilder?(customView)
    }
    
    public override var identifier: String {
        return customIdentifier
    }
}
