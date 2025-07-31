//
//  LineItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit

// MARK:- LineCell
/// 分割线的cell
open class CollectionLineCell: ItemCell {
    let lineView: UIView = UIView()
    
    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero).priority(.low)
        }
    }
}

// MARK:- LineItem
/// 定义好的分割线Item，可自定义线的宽度、圆角、内容边距、线的颜色以及背景色
public final class LineItem: ItemOf<CollectionLineCell>, ItemType {
    
    /// 线的颜色
    public var lineColor: UIColor = .lightGray
    /// 线的圆角
    public var lineRadius: CGFloat = 0
    /// 线的宽度
    public var lineWidth: CGFloat = 0.5 {
        didSet {
            guard let indexPath = self.indexPath else { return }
            section?.form?.delegate?.formView?.reloadItems(at: [indexPath])
        }
    }
    
    public override var isDisabled: Bool {
        set {
        }
        get {
            true
        }
    }
    
    // 更新cell的布局
    public override func updateCell() {
        super.updateCell()
        guard let cell = cell as? CollectionLineCell else {
            return
        }
        cell.lineView.backgroundColor = lineColor
        cell.lineView.layer.cornerRadius = min(lineRadius, lineWidth * 0.5)
        cell.lineView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInsets).priority(.low)
        }
        cell.layoutIfNeeded()
    }
    
    public override var identifier: String {
        return "LineItem"
    }
    
    public convenience init(lineWidth: CGFloat = 0.5, lineColor: UIColor = .lightGray, lineRadius: CGFloat = 0, contentInsets: UIEdgeInsets = .zero) {
        self.init(title: nil, tag: nil)
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.lineRadius = lineRadius
        self.contentInsets = contentInsets
    }
    
    internal required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        contentInsets = .zero
    }
    
    /// 计算尺寸
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return CGSize(width: estimateItemSize.width, height: lineWidth + contentInsets.top + contentInsets.bottom)
        case .horizontal:
            return CGSize(width: lineWidth + contentInsets.left + contentInsets.right, height: estimateItemSize.height)
        case .free:
            return CGSize(width: lineWidth + contentInsets.left + contentInsets.right, height: lineWidth + contentInsets.top + contentInsets.bottom)
        }
    }
}
