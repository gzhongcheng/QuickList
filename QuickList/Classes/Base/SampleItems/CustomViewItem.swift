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
/// 用于将已有的View快速包装成Item的容器
public final class CustomViewItem: AutolayoutItemOf<CustomViewItemCell>, ItemType {
    var customIdentifier: String = "CustomViewItemCell"
    /// 当前的自定义view
    public var customView: UIView?
    /// 自定义view的布局逻辑
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
    
    // 更新cell的布局
    public override func updateCell() {
        super.updateCell()
        guard let cell = cell as? CustomViewItemCell else {
            return
        }
        updateCellData(cell)
    }
    
    /// 自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸，所以上面的updateCell方法直接转调这个方法
    public override func updateCellData(_ cell: CustomViewItemCell) {
        guard let customView = customView else { return }
        cell.addCustomViewIfNeeded(customView)
        customViewLayoutBuilder?(customView)
    }
    
    public override var identifier: String {
        return customIdentifier
    }
}
