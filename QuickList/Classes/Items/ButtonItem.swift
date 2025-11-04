//
//  ButtonItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit

// MARK: ButtonCell
open class CollectionButtonCell: ItemCell {
    
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let rightView = UIView()
    let arrowImageView = UIImageView()
    
    open override func setup() {
        super.setup()
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightView)
        contentView.addSubview(arrowImageView)
        
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        rightView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(iconImageView.snp.right)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        })
        
        rightView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(arrowImageView.snp.left)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
    }
    
}

// MARK: ButtonItem
/**
 * 按钮Item（整个Item为一个按钮），点击可以任意操作（如点击跳转到新的界面）
 * 支持自定义标题样式、右侧箭头样式，同时可添加左侧图标，以及右侧箭头前的自定义View
 * 文字内容展示为row.title，如需更改可以继承这个类并在super.customUpdateCell()之后设置cell.titleLabel.text为想要的值
 * 
 * Button Item (entire Item is a button), click can perform any operation (e.g., click to jump to new interface)
 * Supports custom title style, right arrow style, can add left icon, and custom View before right arrow
 * Text content displays as row.title, if you need to change, inherit this class and set cell.titleLabel.text to desired value after super.customUpdateCell()
 */
public final class ButtonItem: AutolayoutItemOf<CollectionButtonCell>, TypedCollectionValueItemType, ItemType {
    public var sendValue: String?
    
    /**
     * 定义了点击如何后跳转控制器的属性，可以不传
     * Property that defines how to jump to controller after click, can be omitted
     */
    public var presentationMode: PresentationMode<UIViewController>?
    
    /**
     * 箭头样式
     * Arrow style
     */
    public enum ArrowType: Equatable {
        /**
         * 不带箭头
         * No arrow
         */
        case none
        /**
         * 自定义
         * Custom
         */
        case custom(_ image: UIImage?, size: CGSize)
    }
    public var arrowType: ArrowType = .none
    
    /**
     * 左侧图标
     * Left icon
     */
    public var iconImage: UIImage?
    public var iconSize: CGSize = .zero
    
    /**
     * 标题样式
     * Title style
     */
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleHighlightColor: UIColor?
    public var titleAlignment: NSTextAlignment = .left
    
    /**
     * 右侧视图
     * Right view
     */
    public var rightView: UIView?
    public var rightViewSize: CGSize = .zero
    
    /**
     * 间距设置
     * Spacing settings
     */
    public var spaceBetweenIconAndTitle: CGFloat = 0
    public var spaceBetweenTitleAndRightView: CGFloat = 0
    public var spaceBetweenRightViewAndArrow: CGFloat = 0
    
    public override var identifier: String {
        return "ButtonItem"
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if
                let presentationMode = presentationMode,
                let cell = cell,
                let viewController = cell.getViewController()
            {
                if let controller = presentationMode.makeController() {
                    presentationMode.present(controller, item: self, presentingController: viewController)
                } else {
                    presentationMode.present(nil, item: self, presentingController: viewController)
                }
            }
        }
    }

    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? CollectionButtonCell else {
            return
        }
        switch arrowType {
            case .none:
                cell.arrowImageView.image = nil
                cell.arrowImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(CGSize.zero)
                }
            case .custom(let image, let size):
                cell.arrowImageView.image = image
                cell.arrowImageView.snp.updateConstraints { (make) in 
                    make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(size)
                }
        }
        
        cell.titleLabel.textAlignment = titleAlignment
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.font = titleFont
        cell.titleLabel.text = title
        cell.titleLabel.snp.updateConstraints { (make) in
            make.left.equalTo(cell.iconImageView.snp.right).offset(spaceBetweenIconAndTitle)
        }
        
        if iconImage != nil {
            cell.iconImageView.image = iconImage
            cell.iconImageView.snp.updateConstraints { (make) in
                make.size.equalTo(iconSize)
                make.left.equalTo(contentInsets.left)
            }
        } else {
            cell.iconImageView.image = nil
            cell.iconImageView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize.zero)
                make.left.equalTo(contentInsets.left)
            }
        }
        
        cell.rightView.snp.updateConstraints { (make) in
            make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndRightView)
            make.right.equalTo(cell.arrowImageView.snp.left).offset(-spaceBetweenRightViewAndArrow)
        }
        
        if rightView != nil {
            for v in cell.rightView.subviews {
                v.isHidden = v != rightView
            }
            if rightView?.superview != cell.rightView {
                rightView?.removeFromSuperview()
                cell.rightView.addSubview(rightView!)
                rightView?.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            cell.rightView.snp.updateConstraints { (make) in
                make.size.equalTo(rightViewSize)
            }
        } else {
            rightView?.isHidden = true
            cell.rightView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize.zero)
            }
        }
    }
    
    public override func customHighlightCell() {
        super.customHighlightCell()
        guard let cell = cell as? CollectionButtonCell else {
            return
        }
        cell.titleLabel.textColor = titleHighlightColor ?? titleColor
    }
    
    public override func customUnHighlightCell() {
        super.customUnHighlightCell()
        guard let cell = cell as? CollectionButtonCell else {
            return
        }
        cell.titleLabel.textColor = titleColor
    }

    public func prepare(for segue: UIStoryboardSegue) {
        (segue.destination as? ItemControllerType)?.onDismissCallback = presentationMode?.onDismissCallback
    }
}

