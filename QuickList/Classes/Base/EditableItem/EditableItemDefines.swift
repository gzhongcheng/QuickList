//
//  EditableItemDefines.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/30.
//

import Foundation

// MARK: - EditableItemMoveAnimation
/**
 * 移动动画逻辑
 * Move animation logic
 */
public enum EditableItemMoveAnimation {
    /**
     * 直接交换
     * Direct exchange
     */
    case exchange
    /**
     * 展示目标位置指示条，用户拖拽到目标位置后，再进行交换
     * Show target position indicator, user drags to the target position, then exchange
     */
    case indicator(arrowColor: UIColor, arrowSize: CGSize, lineColor: UIColor, lineWidth: CGFloat)
}

// MARK: - EditableItemEditType
/**
 * 编辑类型
 * Edit type
 */
public enum EditableItemEditType {
    /**
     * 移动
     * Move
     */
    case move(_ moveAnimation: EditableItemMoveAnimation = .exchange)
    /**
     * 删除
     * Delete
     */
    case delete
}

// MARK: - EditableItemEditContentCompression
/**
 * 编辑时，内容的压缩方式
 * When editing, the compression method of the content
 */
public enum EditableItemEditContentCompression {
    /**
     * 不压缩容器，整体左移
     * No compression container, move as a whole to the left
     */
    case noCompression
    /**
     * 压缩容器
     * Compress
     */
    case compression
}

// MARK: - EditableItemType
// EditableItemType
public protocol EditableItemType: Item {
    /**
     * 编辑代理
     * Edit delegate
     */
    var delegate: EditableItemDelegate? { get set }
    /**
     * 开始编辑
     * Begin editing
     */
    func beginEditing(animation: Bool)
    /**
     * 结束编辑
     * End editing
     */
    func endEditing(animation: Bool)
    /**
     * 编辑类型
     * Edit type
     */
    var editType: EditableItemEditType { get set }
    /**
     * 编辑时，内容的压缩方式
     * When editing, the compression method of the content
     */
    var editContentCompression: EditableItemEditContentCompression { get }
    /**
     * 编辑图标
     * Edit icon
     */
    var editIcon: UIImage? { get set }
    /**
     * 编辑图标颜色
     * Edit icon color
     */
    var editIconColor: UIColor { get set }
    /**
     * 编辑图标大小
     * Edit icon size
     */
    var editIconSize: CGSize { get set }
    /**
     * 编辑容器展开宽度
     * Edit container expanded width
     */
    var editContainerWidth: CGFloat { get set }
    /**
     * 编辑状态, 控制是否展示操作按钮
     * Edit state, control whether to show the operation buttons
     */
    var isEditing: Bool { get set }
    /**
     * 是否正在拖拽
     * Whether is dragging
     */
    var isDragging: Bool { get set }
}

// MARK: - EditableItemDelegate
// EditableItemDelegate
public protocol EditableItemDelegate: AnyObject {
    /**
     * 删除操作
     * Delete action
     */
    func onDeleteAction(item: EditableItemType)
    
    /**
     * 是否可以交换位置
     * Whether can exchange position
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - targetItem: 要移动到的目标Item位置，目标位置将会被交换 / The item to move to, the target position will be exchanged
     * - Returns: 是否可以交换位置 / Whether can exchange position
     */
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool
    
    /**
     * 交换完成
     * Exchange finished
     * - Parameters:
     *   - item: 交换的Item / The item to exchange
     *   - targetItem: 交换到的目标Item / The item to exchange to
     */
    func didFinishExchange(item: EditableItemType)

    /**
     * cell截图移动前的预处理
     * Pre-process the cell screenshot before moving
     * - Parameters:
     *   - view: 要预处理的Cell截图 / The cell screenshot to pre-process
     */
    func preProcessScreenshot(view: UIView)
}

extension EditableItemDelegate where Self: AnyObject {
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool {
        return true
    }
    func didFinishExchange(item: EditableItemType) {
        // Do nothing by default
    }
    func preProcessScreenshot(view: UIView) {
        var blurEffect: UIBlurEffect = UIBlurEffect(style: .regular)
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layer.shadowColor = UIColor.systemGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 2
    }
}
