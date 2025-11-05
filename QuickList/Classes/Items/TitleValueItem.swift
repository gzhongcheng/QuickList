//
//  TitleValueItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit


/**
 * item的左侧标题样式
 * Item left title style
 */
public enum TitlePosition: Equatable {
    /**
     * 居左，自动宽度
     * Left, automatic width
     */
    case left
    /**
     * 居左，固定宽度
     * Left, fixed width
     */
    case width(_ width: CGFloat)
}

// MARK: - LabelCell
open class CollectionLabelCell: ItemCell {
    let titleLabel: UILabel = UILabel()
    let valueLabel: UILabel = UILabel()

    open override func setup() {
        super.setup()
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .gray
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(15).priority(.high)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        })
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-15).priority(.high)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        }
    }
}

// MARK: - TitleValueItem
public final class TitleValueItem: AutolayoutItemOf<CollectionLabelCell>, ItemType {
    // 样式设置
    /**
     * 竖直方向排列方式
     * Vertical alignment
     */
    public enum VerticalAlignment {
        /**
         * 顶部对齐
         * Top alignment
         */
        case top
        /**
         * 居中对齐
         * Center alignment
         */
        case center
        /**
         * 底部对齐
         * Bottom alignment
         */
        case bottom
    }
    
    public var verticalAlignment: VerticalAlignment = .center
    
    // MARK: - title
    public var titlePosition: TitlePosition = .left
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleHighlightColor: UIColor?
    public var titleLines: Int = 0
    public var titleAlignment: NSTextAlignment = .left
    /**
     * 富文本标题，如果设置了，则会替换掉title显示这个
     * Rich text title, if set, will replace title display this
     */
    public var attributeTitle: NSAttributedString?
    
    // MARK: - value
    public enum ValuePosition {
        case left(_ spaceToTitle: CGFloat)
        case center
        case right
    }
    /**
     * Value和Title的间距
     * Space between Value and Title
     */
    public var spaceBetweenTitleAndValue: CGFloat = 0
    public var valueFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var valueColor: UIColor = UIColor.gray
    public var valueHighlightColor: UIColor?
    public var valueLines: Int = 0
    public var valueAlignment: NSTextAlignment = .right
    
    /**
     * 值
     * Value
     */
    public var value: String?
    /**
     * 富文本value，如果设置了，则会替换掉value显示这个
     * Rich text value, if set, will replace value display this
     */
    public var attributeValue: NSAttributedString?
    
    
    public convenience init(title: String? = nil, value: String? = nil, tag: String? = nil, weight: Int = 1, _ initializer: (TitleValueItem) -> Void = { _ in }) {
        self.init(title, tag: tag, weight: weight)
        self.value = value
        initializer(self)
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? CollectionLabelCell else {
            return
        }
        
        updateCellData(cell)
    }
    
    public override func updateCellData(_ cell: CollectionLabelCell) {
        if attributeTitle != nil {
            cell.titleLabel.attributedText = attributeTitle
        } else {
            cell.titleLabel.attributedText = nil
            cell.titleLabel.text = title
        }
        if attributeValue != nil {
            cell.valueLabel.attributedText = attributeValue
        } else {
            cell.valueLabel.attributedText = nil
            cell.valueLabel.text = value
        }
        
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.valueLabel.numberOfLines = valueLines
        cell.valueLabel.font = valueFont
        cell.valueLabel.textColor = valueColor
        cell.valueLabel.textAlignment = valueAlignment
        
        if title == nil, attributeTitle == nil {
            cell.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(contentInsets.left - spaceBetweenTitleAndValue)
                make.top.equalTo(contentInsets.top)
                make.width.height.equalTo(0)
            })
        } else {
            switch titlePosition {
                case .left:
                    switch verticalAlignment {
                        case .top:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.equalTo(contentInsets.top)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.centerY.equalToSuperview()
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                                make.bottom.equalTo(-contentInsets.bottom).priority(.high)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                    }
                case .width(let width):
                    switch verticalAlignment {
                        case .top:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.equalTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.centerY.equalToSuperview()
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.equalTo(-contentInsets.bottom)
                            })
                    }
            }
        }
        
        if value == nil, attributeValue == nil {
            cell.valueLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(cell.titleLabel.snp.right)
                make.top.equalTo(contentInsets.top)
                make.right.equalTo(-contentInsets.right)
            })
        } else {
            switch verticalAlignment {
                case .top:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.equalTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                    })
                case .center:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.greaterThanOrEqualTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                        make.centerY.equalToSuperview()
                    })
                case .bottom:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.greaterThanOrEqualTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.equalTo(-contentInsets.bottom)
                    })
            }
        }
    }
    
    public override func customHighlightCell() {
        super.customHighlightCell()
        guard let cell = cell as? CollectionLabelCell else {
            return
        }
        cell.titleLabel.textColor = titleHighlightColor ?? titleColor
        cell.valueLabel.textColor = valueHighlightColor ?? valueColor
    }
    
    public override func customUnHighlightCell() {
        super.customUnHighlightCell()
        guard let cell = cell as? CollectionLabelCell else {
            return
        }
        cell.titleLabel.textColor = titleColor
        cell.valueLabel.textColor = valueColor
    }
    
    public override var identifier: String {
        return "TitleValueItem"
    }
}
