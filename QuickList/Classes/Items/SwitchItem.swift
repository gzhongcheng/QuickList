//
//  SwitchItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit

// MARK:- SwitchCell
open class CollectionSwitchCell: ItemCell {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var switchDidChangeBlock: ((_ isOn: Bool, _ fromTouch: Bool) -> Void)?
    
    let titleLabel: UILabel = UILabel()
    let valueSwitch: SwitchView = SwitchView()

    open override func setup() {
        super.setup()
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueSwitch)
        
        valueSwitch.onSwitchChanged = { [weak self] (isOn, fromTouch) in
            self?.switchDidChangeBlock?(isOn, fromTouch)
        }
    }
}

// MARK:- SwitchItem
public final class SwitchItem: AutolayoutItemOf<CollectionSwitchCell>, ItemType {
    
    /**
     * 竖直方向对齐方式
     * Vertical alignment
     */
    public enum VerticalAlignment {
        case top
        case center
        case bottom
    }
    
    public var verticalAlignment: VerticalAlignment = .center
    
    // title
    public var titlePosition: TitlePosition = .left
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleLines: Int = 0
    public var titleAlignment: NSTextAlignment = .left
    /**
     * 富文本标题，如果设置了，则会替换掉title显示这个
     * Rich text title, if set, will replace title display this
     */
    public var attributeTitle: NSAttributedString?
    
    // switch
    /**
     * 开关的背景颜色
     * Switch background color
     */
    public var switchOffBackgroundColor: UIColor = .lightGray
    public var switchOnBackgroundColor: UIColor = .systemGreen
    /**
     * 开关的滑块颜色
     * Switch indicator color
     */
    public var switchOnIndicatorColor: UIColor = .white
    public var switchOffIndicatorColor: UIColor = .white
    /**
     * 开关滑块文字
     * Switch indicator text
     */
    public var switchOnIndicatorText: String?
    public var switchOffIndicatorText: String?
    /**
     * 开关未选中时文字
     * Switch off text
     */
    public var switchOffText: String?
    /**
     * 开关选中时文字
     * Switch on text
     */
    public var switchOnText: String?
    /**
     * 开关的滑块内文字颜色
     * Switch indicator text color
     */
    public var switchOffIndicatorTextColor: UIColor = .black
    public var switchOnIndicatorTextColor: UIColor = .white
    /**
     * 开关的最小尺寸（如果内容文本尺寸超过会撑大）
     * Minimum switch size (if content text size exceeds, it will expand)
     */
    public var minimumSwitchSize: CGSize = CGSize(width: 50, height: 30)
    /**
     * 开关内间距
     * Switch content insets
     */
    public var switchContentInsets: UIEdgeInsets = UIEdgeInsets(top: 1.5, left: 1.5, bottom: 1.5, right: 1.5)
    
    /**
     * 开关状态
     * Switch state
     */
    public var value: Bool = false
    
    public override var identifier: String {
        return "_SwitchItem"
    }
    
    /**
     * 更新cell
     * Update cell
     */
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? CollectionSwitchCell else {
            return
        }
        updateCellData(cell)
    }
    
    public override func updateCellData(_ cell: CollectionSwitchCell) {
        if attributeTitle != nil {
            cell.titleLabel.attributedText = attributeTitle
        } else {
            cell.titleLabel.attributedText = nil
            cell.titleLabel.text = title
        }
        
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.valueSwitch.setOn(self.value, animated: false)
        cell.valueSwitch.offBackgroundColor = switchOffBackgroundColor
        cell.valueSwitch.onBackgroundColor = switchOnBackgroundColor
        cell.valueSwitch.offIndicatorColor = switchOffIndicatorColor
        cell.valueSwitch.onIndicatorColor = switchOnIndicatorColor
        cell.valueSwitch.offIndicatorTextColor = switchOffIndicatorTextColor
        cell.valueSwitch.onIndicatorTextColor = switchOnIndicatorTextColor
        cell.valueSwitch.offIndicatorText = switchOffIndicatorText
        cell.valueSwitch.onIndicatorText = switchOnIndicatorText
        cell.valueSwitch.offText = switchOffText
        cell.valueSwitch.onText = switchOnText
        cell.valueSwitch.contentInsets = switchContentInsets
        cell.valueSwitch.minimumSize = minimumSwitchSize
        
        cell.switchDidChangeBlock = { [weak self] (isOn, fromTouch) in
            self?.value = isOn
            self?.callbackOnDataChange?()
        }
        
        if title == nil, attributeTitle == nil {
            cell.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(contentInsets.left)
                make.top.equalTo(contentInsets.top)
                make.right.lessThanOrEqualTo(-contentInsets.right)
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
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.bottom.equalTo(-contentInsets.bottom)
                                make.right.lessThanOrEqualTo(-contentInsets.right)
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
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.width.equalTo(width)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.centerY.equalToSuperview()
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.equalTo(-contentInsets.bottom)
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                    }
            }
        }
        
        switch verticalAlignment {
            case .top:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.equalTo(contentInsets.top)
                    make.right.equalTo(-contentInsets.right)
                    make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                })
            case .center:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.greaterThanOrEqualTo(contentInsets.top)
                    make.right.equalTo(-contentInsets.right)
                    make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                    make.centerY.equalToSuperview()
                })
            case .bottom:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.greaterThanOrEqualTo(contentInsets.top)
                    make.right.equalTo(-contentInsets.right)
                    make.bottom.equalTo(-contentInsets.bottom)
                })
        }
        cell.contentView.layoutIfNeeded()
    }
}
