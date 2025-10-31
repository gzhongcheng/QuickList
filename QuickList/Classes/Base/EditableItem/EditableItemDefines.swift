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
     * 是否可以交换位置(当move的动画类型为exchange时，会调用此方法)
     * Whether can exchange position(when the move animation type is exchange, this method will be called)
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - targetItem: 要移动到的目标Item位置，目标位置将会被交换 / The item to move to, the target position will be exchanged
     * - Returns: 是否可以交换位置 / Whether can exchange position
     */
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool
    
    /**
     * 是否可以移动到某个Item前(当move的动画类型为indicator时，会调用此方法)
     * Whether can move to the item before(when the move animation type is indicator, this method will be called)
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - before: 要移动到的Item前 / The item before
     * - Returns: 是否可以移动 / Whether can move
     */
    func canMove(item: EditableItemType, before: Item) -> Bool
    /**
     * 是否可以移动到某个Item后(当move的动画类型为indicator时，会调用此方法)
     * Whether can move to the item after(when the move animation type is indicator, this method will be called)
     * Whether can move to the item after
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - after: 要移动到的Item后 / The item after
     * - Returns: 是否可以移动 / Whether can move
     */
    func canMove(item: EditableItemType, after: Item) -> Bool
}

extension EditableItemDelegate where Self: AnyObject {
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool {
        return true
    }
    func canMove(item: EditableItemType, before: Item) -> Bool {
        return true
    }
    func canMove(item: EditableItemType, after: Item) -> Bool {
        return true
    }
}
