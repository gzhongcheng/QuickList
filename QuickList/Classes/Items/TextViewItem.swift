//
//  TextViewItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit

// MARK: TextViewCell
open class CollectionTextViewCell : ItemCell {
    
    let boxView: UIView = UIView()
    
    let titleLabel: UILabel = UILabel()
    
    let markInput: PlaceholderTextView = {
        let textView = PlaceholderTextView(placeholder: nil, placeholderColor: nil)
        textView.isShowCountLabel = false
        textView.placeholderInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        return textView
    }()
    
    open override func setup() {
        super.setup()
        contentView.addSubview(boxView)
        boxView.addSubview(titleLabel)
        boxView.addSubview(markInput)
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override open var canBecomeFirstResponder: Bool {
        return !(item?.isDisabled ?? false)
    }
}

// MARK: TextViewItem
/**
 * textview输入框Item，可展示左侧标题和右侧的输入框，同时提供自定义标题、输入框样式，自动调整高度,  不推荐在横向的Collection中使用
 * TextView input field item, can display left title and right input field, provide custom title, input field style, automatic height adjustment, not recommended in horizontal Collection
 */
public final class TextViewItem : ItemOf<CollectionTextViewCell>, ItemType {
    public override var identifier: String {
        return "TextViewItem"
    }
    
    /**
     * 已输入的文本
     * Text that has been input
     */
    var value: String?
    
    // MARK: - cell settings
    /**
     * 是否自动高度
     * Whether to automatically adjust height
     */
    public var autoHeight: Bool = true
    
    /**
     * 最小高度
     * Minimum height
     */
    public var minHeight: CGFloat = 44 {
        didSet {
            realHeight = max(minHeight, realHeight)
        }
    }
    /**
     * 实际高度
     * Actual height
     */
    var realHeight: CGFloat = 44
    
    // MARK: - Box settings
    /**
     * 边框宽度
     * Border width
     */
    public var boxBorderWidth: CGFloat = 0
    /**
     * 边框颜色
     * Border color
     */
    public var boxBorderColor: UIColor = .clear
    /**
     * 圆角
     * Corner radius
     */
    public var boxCornerRadius: CGFloat = 0
    /**
     * box到cell的边距
     * Box to cell insets
     */
    public var boxInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    /**
     * 内容到box的边距
     * Content to box insets
     */
    public var boxPadding: UIEdgeInsets = UIEdgeInsets.zero
    /**
     * box的背景色
     * Box background color
     */
    public var boxBackgroundColor: UIColor = .clear
    
    // MARK: - Title settings
    /**
     * 富文本标题，如果设置了，则会替换掉title显示这个
     * Rich text title, if set, will replace title display this
     */
    public var attributeTitle: NSAttributedString?
    /**
     * 标题设置
     * Title settings
     */
    public var titlePosition: TitlePosition = .left
    /**
     * 标题字体
     * Title font
     */
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    /**
     * 标题颜色
     * Title color
     */
    public var titleTextColor: UIColor = UIColor.black
    /**
     * 标题字体行数
     * Title font line count
     */
    public var titleLines: Int = 0
    /**
     * 标题对齐方式
     * Title alignment
     */
    public var titleAlignment: NSTextAlignment = .left
    
    // MARK: - Input settings
    /**
     * 输入框与标题的间距
     * Input field to title spacing
     */
    public var inputSpaceToTitle: CGFloat = 5
    /**
     * 输入内容到输入框的边距
     * Input content to input field insets
     */
    public var inputContentPadding: UIEdgeInsets = UIEdgeInsets.zero
    /**
     * 提示文字
     * Placeholder text
     */
    public var placeholder: String?
    /**
     * 提示文字颜色
     * Placeholder text color
     */
    public var placeholderColor: UIColor = .gray
    /**
     * 是否显示字数限制
     * Whether to show character limit
     */
    public var showLimit: Bool = false
    /**
     * 限制输入个数   默认为999999，不限制输入
     * Limit input count, default is 999999, no limit input
     */
    public var limitWords: UInt = 999999
    /**
     * 背景色
     * Background color
     */
    public var inputBackgroundColor: UIColor = .white
    /**
     * 边框宽度
     * Border width
     */
    public var inputBorderWidth: CGFloat = 0
    /**
     * 边框颜色
     * Border color
     */
    public var inputBorderColor: UIColor = .clear
    /**
     * 圆角
     * Corner radius
     */
    public var inputCornerRadius: CGFloat = 0
    /**
     * 字体
     * Font
     */
    public var inputFont: UIFont = UIFont.systemFont(ofSize: 14)
    /**
     * 字体颜色
     * Font color
     */
    public var inputTextColor: UIColor = .black
    /**
     * 光标颜色
     * Cursor color
     */
    public var inputCursorColor: UIColor = UIColor.systemBlue
    
    public var inputAlignment: NSTextAlignment = .left
    public var keyboardType: UIKeyboardType = .default
    public var returnKeyType: UIReturnKeyType = .default
    
    /**
     * 是否正在编辑
     * Whether is editing
     */
    var isEditing: Bool = false
    /**
     * 编辑时box的边框颜色
     * Editing border color
     */
    public var boxEditingBorderColor: UIColor?
    public var boxEditingBorderWidth: CGFloat?
    public var inputEditingBorderColor: UIColor?
    public var inputEditingBorderWidth: CGFloat?
    
    /**
     * 值改变的回调事件
     * Value change callback event
     */
    var onTextDidChangeBlock: ((_ newText: String) -> Void)?
    
    public func onTextDidChanged(_ callBack: @escaping ((_ item: TextViewItem, _ newText: String) -> Void)) {
        onTextDidChangeBlock = { [weak self] (newText) in
            callBack(self!, newText)
        }
    }
    
    /**
     * 计算高度
     * Calculate height
     */
    public func cellHeight(for width: CGFloat) -> CGFloat {
        return realHeight
    }
    
    /**
     * 更新cell的布局
     * Update cell layout
     */
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? CollectionTextViewCell else {
            return
        }
        cell.markInput.inputTextView.text = value
        cell.markInput.checkShowHiddenPlaceholder()
        cell.markInput.beginEditingBlock = { [weak self] in
            guard
                let strongSelf = self,
                let strongCell = strongSelf.cell as? CollectionTextViewCell
            else { return }
            if strongSelf.isDisabled {
                strongCell.markInput.endEditing(true)
                return
            }
            strongSelf.isEditing = true
            strongCell.boxView.layer.borderColor = strongSelf.boxEditingBorderColor?.cgColor ?? strongSelf.boxBorderColor.cgColor
            strongCell.boxView.layer.borderWidth = strongSelf.boxEditingBorderWidth ?? strongSelf.boxBorderWidth
            strongCell.markInput.layer.borderColor = strongSelf.inputEditingBorderColor?.cgColor ?? strongSelf.inputBorderColor.cgColor
            strongCell.markInput.layer.borderWidth = strongSelf.inputEditingBorderWidth ?? strongSelf.inputBorderWidth
        }
        cell.markInput.endEditingBlock = { [weak self] (newHeight) in
            guard
                let strongSelf = self,
                let strongCell = strongSelf.cell as? CollectionTextViewCell
            else { return }
            strongSelf.isEditing = false
            strongSelf.autoHeightIfNeeded(newHeight)
            strongCell.boxView.layer.borderColor = strongSelf.boxBorderColor.cgColor
            strongCell.boxView.layer.borderWidth = strongSelf.boxBorderWidth
            strongCell.markInput.layer.borderColor = strongSelf.inputBorderColor.cgColor
            strongCell.markInput.layer.borderWidth = strongSelf.inputBorderWidth
        }
        cell.markInput.textDidChangeBlock = { [weak self] (text, newHeight) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.value = text
            strongSelf.autoHeightIfNeeded(newHeight)
            strongSelf.onTextDidChangeBlock?(text)
        }
        
        cell.markInput.backgroundColor = inputBackgroundColor
        cell.markInput.tintColor = inputCursorColor
        cell.markInput.inputTextView.textAlignment = inputAlignment
        cell.markInput.inputTextView.returnKeyType = returnKeyType
        cell.markInput.inputTextView.keyboardType = keyboardType
        cell.markInput.inputTextView.textColor = inputTextColor
        cell.markInput.inputTextView.font = inputFont
        cell.markInput.plaleLabel.font = inputFont
        cell.markInput.plaleLabel.textAlignment = inputAlignment
        cell.markInput.placeholderGlobal = placeholder
        cell.markInput.placeholderColorGlobal = placeholderColor
        cell.markInput.limitWords = limitWords
        cell.markInput.isShowCountLabel = showLimit
        cell.markInput.contentInset = inputContentPadding
        cell.markInput.layer.borderColor = isEditing ? (inputEditingBorderColor?.cgColor ?? inputBorderColor.cgColor) : inputBorderColor.cgColor
        cell.markInput.layer.borderWidth = isEditing ? (inputEditingBorderWidth ?? inputBorderWidth) : inputBorderWidth
        cell.markInput.layer.cornerRadius = inputCornerRadius
        
        cell.boxView.backgroundColor = boxBackgroundColor
        cell.boxView.layer.borderColor = isEditing ? (boxEditingBorderColor?.cgColor ?? boxBorderColor.cgColor) : boxBorderColor.cgColor
        cell.boxView.layer.borderWidth = isEditing ? (boxEditingBorderWidth ?? boxBorderWidth) : boxBorderWidth
        cell.boxView.layer.cornerRadius = boxCornerRadius
        
        cell.titleLabel.text = title
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleTextColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.boxView.snp.remakeConstraints { (make) in
            make.edges.equalTo(boxInsets)
        }
        
        switch titlePosition {
            case .left:
                cell.titleLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(boxPadding.top)
                    make.left.equalTo(boxPadding.left)
                })
            case .width(let width):
                cell.titleLabel.snp.remakeConstraints({ (make) in
                    make.left.equalTo(boxPadding.left)
                    make.top.equalTo(boxPadding.top)
                    make.width.equalTo(width)
                })
        }
        
        let space = title?.count ?? 0 > 0 ? inputSpaceToTitle : 0
        cell.markInput.snp.remakeConstraints({ (make) in
            make.left.equalTo(cell.titleLabel.snp.right).offset(space)
            make.top.equalTo(boxPadding.top - inputContentPadding.top)
            make.bottom.equalTo(-boxPadding.bottom + inputContentPadding.bottom)
            make.right.equalTo(-boxPadding.right)
        })
        
        cell.layoutIfNeeded()
    }
    
    func autoHeightIfNeeded(_ newHeight: CGFloat) {
        let height = max(newHeight + boxPadding.top + boxPadding.bottom + boxInsets.top + boxInsets.bottom , minHeight)
        if Int(realHeight) != Int(height), autoHeight {
            realHeight = height
            updateLayout(animation: ListReloadAnimation.fade)
        }
    }
    
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        return CGSize(width: estimateItemSize.width, height: realHeight)
    }
}
