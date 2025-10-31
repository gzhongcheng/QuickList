//
//  EditableItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/29.
//

import UIKit

/**
 * 编辑类型
 * Edit type
 */
public enum EditableItemEditType {
    /**
     * 移动
     * Move
     */
    case move
    /**
     * 删除
     * Delete
     */
    case delete
}

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
     * 编辑状态, 控制是否展示操作按钮
     * Edit state, control whether to show the operation buttons
     */
    var isEditing: Bool { get set }
    /**
     * 是否正在拖拽
     * Whether is dragging
     */
    var isDragging: Bool { get set }

    /**
     * 配置编辑状态
     * Configure edit state
     */
    func configureEditable()
}

// MARK: - EditableItemDelegate
// EditableItemDelegate
public protocol EditableItemDelegate: Item {
    /**
     * 删除操作
     * Delete action
     */
    func onDeleteAction(item: EditableItemType)
    /**
     * 是否可以移动到某个Item前
     * Whether can move to the item before
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - before: 要移动到的Item前 / The item before
     * - Returns: 是否可以移动 / Whether can move
     */
    func canMove(item: EditableItemType, before: Item) -> Bool
    /**
     * 是否可以移动到某个Item后
     * Whether can move to the item after
     * - Parameters:
     *   - item: 要移动的Item / The item to move
     *   - after: 要移动到的Item后 / The item after
     * - Returns: 是否可以移动 / Whether can move
     */
    func canMove(item: EditableItemType, after: Item) -> Bool
}

// MARK: - EditableItemCell
// EditableItemCell
open class EditableItemCell: ItemCell {
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .move {
        didSet {
            switch editType {
            case .move:
                self.editContainer.removeGestureRecognizer(deleteGestureRecognizer)
                self.editContainer.addGestureRecognizer(moveGestureRecognizer)
            case .delete:
                self.editContainer.removeGestureRecognizer(moveGestureRecognizer)
                self.editContainer.addGestureRecognizer(deleteGestureRecognizer)
            }
        }
    }
    /**
     * 编辑时，内容的压缩方式
     * When editing, the compression method of the content
     */
    public var editContentCompression: EditableItemEditContentCompression = .noCompression
    /**
     * 编辑状态
     * Edit state
     */
    public var isEditing: Bool = false {
        didSet {
            if isEditing {
                beginEditing(animation: false)
            } else {
                endEditing(animation: false)
            }
        }
    }
    /**
     * 编辑图标
     * Edit icon
     */
    public var editIcon: UIImage? = nil {
        didSet {
            editButtonImage.image = editIcon
        }
    }
    /**
     * 编辑图标颜色
     * Edit icon color
     */
    public var editIconColor: UIColor = .black {
        didSet {
            editButtonImage.tintColor = editIconColor
        }
    }
    /**
     * 编辑图标大小
     * Edit icon size
     */
    public var editIconSize: CGSize = CGSize(width: 20, height: 20) {
        didSet {
            editButtonImage.snp.updateConstraints { make in
                make.size.equalTo(editIconSize)
            }
            editButtonImage.setNeedsUpdateConstraints()
        }
    }
    /**
     * 编辑容器展开宽度
     * Edit container expanded width
     */
    public var editContainerWidth: CGFloat = 40 {
        didSet {
            editContainer.snp.updateConstraints { make in
                make.width.equalTo(editContainerWidth)
            }
            editContainer.setNeedsUpdateConstraints()
        }
    }

    /**
     * 会跟随编辑状态改变尺寸的内容视图
     * Content view that follows edit state
     */
    public var editContentView: UIView = UIView()
    /**
     * 编辑容器
     * Edit container
     */
    public lazy var editContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.addSubview(editButtonImage)
        editButtonImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        return view
    }()
    /**
     * 编辑按钮图片
     * Edit button image
     */
    public var editButtonImage: UIImageView = UIImageView()

    /**
     * 删除事件手势
     * Delete event gesture
     */
    public var deleteGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    /**
     * 移动事件手势
     * Move event gesture
     */
    public var moveGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()

    open override func setup() {
        super.setup()

        self.clipsToBounds = true
        self.contentView.addSubview(editContentView)
        self.contentView.addSubview(editContainer)

        editContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        editContainer.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(self.editContainerWidth)
        }

        self.editContainer.isUserInteractionEnabled = true
        deleteGestureRecognizer.addTarget(self, action: #selector(handleDeleteGestureRecognizer(_:)))
        moveGestureRecognizer.addTarget(self, action: #selector(handleMoveGestureRecognizer(_:)))

        /**
         * 直接添加到contentView中的内容不会跟随编辑状态改变尺寸
         * 需要跟随编辑状态改变尺寸的内容请添加到editContentView中
         * Content added to contentView will not follow the edit state
         * Content that needs to follow the edit state should be added to editContentView
         */
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }

    open func beginEditing(animation: Bool) {
        let changeBlock = {
            switch self.editContentCompression {
            case .noCompression:
                self.editContentView.snp.remakeConstraints { make in
                    make.trailing.equalToSuperview().offset(-self.editContainerWidth)
                    make.top.bottom.equalToSuperview()
                    make.width.equalToSuperview()
                }
            case .compression:
                self.editContentView.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-self.editContainerWidth)
                }
            }
            self.editContainer.snp.remakeConstraints { make in
                make.top.bottom.trailing.equalToSuperview()
                make.width.equalTo(self.editContainerWidth)
            }
            self.contentView.layoutIfNeeded()
        }
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                changeBlock()
            })
        } else {
            changeBlock()
        }
    }
    open func endEditing(animation: Bool) {
        let changeBlock = {
            self.editContentView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview()
            }
            self.editContainer.snp.remakeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalTo(self.editContainerWidth)
            }
            self.contentView.layoutIfNeeded()
        }

        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                changeBlock()
            })
        } else {
            changeBlock()
        }
    }

    @objc private func handleDeleteGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        guard let item = self.item as? EditableItemType else { return }
        item.delegate?.onDeleteAction(item: item)
    }

    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        guard let item = self.item as? EditableItemType else { return }
        let pointInSelf = gesture.location(in: self)
        let pointInWindow = gesture.location(in: UIApplication.shared.keyWindow)
        switch gesture.state {
        case .began:
            ItemMovingHandlerMaskView.shared.item = item
            ItemMovingHandlerMaskView.shared.startMoveAnimation(pointInCell: pointInSelf, pointInWindow: pointInWindow)
        case .changed:
            ItemMovingHandlerMaskView.shared.updateMoveAnimationSnapshot(pointInWindow: pointInWindow)
        case .ended, .cancelled:
            ItemMovingHandlerMaskView.shared.endMoveAnimation()
        default:
            ItemMovingHandlerMaskView.shared.endMoveAnimation()
        }
    }
}

// MARK: - EditableItem
// EditableItem
open class EditableItem: ItemOf<EditableItemCell>, EditableItemType {
    public weak var delegate: EditableItemDelegate?
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .move
    /**
     * 编辑时，内容的压缩方式
     * When editing, the compression method of the content
     */
    public var editContentCompression: EditableItemEditContentCompression = .noCompression
    /**
     * 编辑状态
     * Edit state
     */
    public var isEditing: Bool = false
    /**
     * 是否正在拖拽
     * Whether is dragging
     */
    public var isDragging: Bool = false
    /**
     * 编辑图标
     * Edit icon
     */
    public var editIcon: UIImage? = nil
    /**
     * 编辑图标颜色
     * Edit icon color
     */
    public var editIconColor: UIColor = .black
    /**
     * 编辑图标大小
     * Edit icon size
     */
    public var editIconSize: CGSize = CGSize(width: 20, height: 20)
    /**
     * 编辑容器展开宽度
     * Edit container expanded width
     */
    public var editContainerWidth: CGFloat = 40
    
    open func beginEditing(animation: Bool) {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.beginEditing(animation: animation)
        isEditing = true
    }
    open func endEditing(animation: Bool) {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.endEditing(animation: animation)
        isEditing = false
    }

    public func configureEditable() {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.editType = editType
        cell.editContentCompression = editContentCompression
        cell.editIcon = editIcon
        cell.editIconColor = editIconColor
        cell.editIconSize = editIconSize
        cell.editContainerWidth = editContainerWidth
    }
}

// MARK: - AutolayoutEditableItemOf
// AutolayoutEditableItemOf
open class AutolayoutEditableItemOf<Cell: EditableItemCell>: AutolayoutItemOf<Cell>, EditableItemType {
    public weak var delegate: EditableItemDelegate?
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .move
    /**
     * 编辑时，内容的压缩方式
     * When editing, the compression method of the content
     */
    public var editContentCompression: EditableItemEditContentCompression = .noCompression
    /**
     * 编辑状态
     * Edit state
     */
    public var isEditing: Bool = false
    /**
     * 是否正在拖拽
     * Whether is dragging
     */
    public var isDragging: Bool = false
    /**
     * 编辑图标
     * Edit icon
     */
    public var editIcon: UIImage? = nil
    /**
     * 编辑图标颜色
     * Edit icon color
     */
    public var editIconColor: UIColor = .black
    /**
     * 编辑图标大小
     * Edit icon size
     */
    public var editIconSize: CGSize = CGSize(width: 20, height: 20)
    /**
     * 编辑容器展开宽度
     * Edit container expanded width
     */
    public var editContainerWidth: CGFloat = 40
    
    open func beginEditing(animation: Bool) {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.beginEditing(animation: animation)
        isEditing = true
    }
    open func endEditing(animation: Bool) {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.endEditing(animation: animation)
        isEditing = false
    }

    public func configureEditable() {
        guard let cell = self.cell as? EditableItemCell else { return }
        cell.editType = editType
        cell.editContentCompression = editContentCompression
        cell.editIcon = editIcon
        cell.editIconColor = editIconColor
        cell.editIconSize = editIconSize
        cell.editContainerWidth = editContainerWidth
    }
}

// MARK: - MovingHandlerMaskView
// MovingHandlerMaskView
public class ItemMovingHandlerMaskView: UIView {
    /**
     * 要移动的Item
     * The item to move
     */
    public var item: EditableItemType? = nil
    /**
     * 移动的截图
     * The screenshot of the move
     */
    public var moveSnapshot: UIView? = nil {
        didSet {
            for view in self.subviews {
                view.removeFromSuperview()
            }
            if let snapshot = moveSnapshot {
                self.addSubview(snapshot)
            }
            self.layoutIfNeeded()
        }
    }
    /**
     * 移动开始的点在Item中的位置
     * The start point in Item
     */
    public var moveStartPointInItem: CGPoint = .zero
    /**
     * 移动开始的点在window中的位置
     * The start point in window
     */
    public var moveStartPointInWindow: CGPoint = .zero

    // MARK: - Single Instance
    public private(set) static var _sharedInstance: ItemMovingHandlerMaskView?
    
    /// 自动滚动的timer
    private var autoScrollTimer: Timer?
    /// 自动滚动的目标位置
    private var autoScrollTargetPoint: CGPoint?
    
    /**
     获取单例
     Get single instance object
     */
    public static var shared: ItemMovingHandlerMaskView {
        guard let instance = _sharedInstance else {
            let newView = ItemMovingHandlerMaskView()
            let moveGesture = UIPanGestureRecognizer(target: newView, action: #selector(handleMoveGestureRecognizer(_:)))
            moveGesture.delegate = _sharedInstance
            newView.addGestureRecognizer(moveGesture)
            _sharedInstance = newView
            return _sharedInstance!
        }
        return instance
    }
    
    /**
     释放单例对象
     Destruction of single instance object
     */
    public static func destroy() {
        _sharedInstance?.stopAutoScroll()
        _sharedInstance?.moveSnapshot?.removeFromSuperview()
        _sharedInstance?.moveSnapshot = nil
        _sharedInstance?.item = nil
        _sharedInstance?.moveStartPointInItem = .zero
        _sharedInstance?.moveStartPointInWindow = .zero
        _sharedInstance?.restoreScroll()
        _sharedInstance?.removeFromSuperview()
        _sharedInstance = nil
    }

    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        guard self.item != nil else {
            ItemMovingHandlerMaskView.destroy()
            return 
        }
    }

    public func startMoveAnimation(pointInCell: CGPoint, pointInWindow: CGPoint) {
        if moveSnapshot != nil {
            return
        }
        guard let item = self.item, let cell = item.cell, let indexPath = item.indexPath else {
            ItemMovingHandlerMaskView.destroy()
            return 
        }
        item.isDragging = true
        item.form?.listLayout.layoutAttributesForItem(at: indexPath)?.alpha = 0
        cell.alpha = 0
        
        prohibitScroll(for: cell)

        moveStartPointInItem = pointInCell
        moveStartPointInWindow = pointInWindow
        moveSnapshot = cell.snapshotView(afterScreenUpdates: false)
        moveSnapshot?.frame = CGRect(x: pointInWindow.x - pointInCell.x, y: pointInWindow.y - pointInCell.y, width: cell.frame.width, height: cell.frame.height)
        UIApplication.shared.keyWindow?.addSubview(ItemMovingHandlerMaskView.shared)
    }

    public func updateMoveAnimationSnapshot(pointInWindow: CGPoint) {
        guard let moveSnapshot = self.moveSnapshot else {
            return
        }
        moveSnapshot.frame = CGRect(x: pointInWindow.x - moveStartPointInItem.x, y: pointInWindow.y - moveStartPointInItem.y, width: moveSnapshot.frame.width, height: moveSnapshot.frame.height)

        guard 
            let listView = self.item?.section?.form?.delegate?.formView 
        else { return }
        let pointInScrollView = listView.convert(pointInWindow, from: UIApplication.shared.keyWindow)
        switch listView.scrollDirection {
        case .vertical:
            if pointInScrollView.y <= listView.contentOffset.y {
                autoScrollTo(point: .zero)
            } else if pointInScrollView.y >= listView.contentOffset.y + listView.bounds.height - 50 {
                autoScrollTo(point: CGPoint(x: 0, y: listView.contentSize.height - listView.bounds.height))
            } else {
                stopAutoScroll()
                updateTargetPointer(point: pointInScrollView)
            }
        case .horizontal:
            if pointInScrollView.x <= listView.contentOffset.x {
                autoScrollTo(point: .zero)
            } else if pointInScrollView.x >= listView.contentOffset.x + listView.bounds.width - 50 {
                autoScrollTo(point: CGPoint(x: listView.contentSize.width - listView.bounds.width, y: 0))
            } else {
                stopAutoScroll()
                updateTargetPointer(point: pointInScrollView)
            }
        default:
            return
        }
    }

    public func endMoveAnimation() {
        guard let item = self.item else { return }
        stopAutoScroll()
        restoreScroll()
        guard let indexPath = item.indexPath else { return }
        let itemAttr = item.form?.listLayout.layoutAttributesForItem(at: indexPath)
        let itemFrame = itemAttr?.frame ?? .zero
        let itemPointInWindow = item.form?.delegate?.formView?.convert(itemFrame.origin, to: UIApplication.shared.keyWindow) ?? .zero
        UIView.animate(withDuration: 0.3, animations: {
            self.moveSnapshot?.frame = CGRect(x: itemPointInWindow.x, y: itemPointInWindow.y, width: itemFrame.width, height: itemFrame.height)
        }, completion: { _ in
            itemAttr?.alpha = 1
            self.item?.cell?.alpha = 1
            self.moveSnapshot?.removeFromSuperview()
            self.moveSnapshot = nil
            item.isDragging = false
        })
    }
    
    // MARK: - auto scroll behavior
    private func autoScrollTo(point: CGPoint) {
        guard 
            autoScrollTimer == nil
        else {
            return
        }
        guard
            let listView = self.item?.section?.form?.delegate?.formView
        else {
            stopAutoScroll()
            return
        }
        switch listView.scrollDirection {
        case .vertical:
            if point.y == listView.contentOffset.y {
                return
            }
        case .horizontal:
            if point.x == listView.contentOffset.x {
                return
            }
        default:
            return
        }
        autoScrollTargetPoint = point
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(scrollScrollView), userInfo: nil, repeats: true)
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc private func scrollScrollView() {
        guard 
            let listView = self.item?.section?.form?.delegate?.formView, 
            let targetPoint = self.autoScrollTargetPoint else {
            return
        }
        switch listView.scrollDirection {
        case .vertical:
            var newScrollContent = listView.contentOffset.y
            if targetPoint.y < newScrollContent {
                newScrollContent -= 1
                newScrollContent = max(0, newScrollContent)
                listView.setContentOffset(CGPoint(x: 0, y: newScrollContent), animated: false)
                updateTargetPointer(point: listView.contentOffset)
            } else {
                newScrollContent += 1
                newScrollContent = min(max(0, listView.contentSize.height - listView.bounds.height), newScrollContent)
                listView.setContentOffset(CGPoint(x: 0, y: newScrollContent), animated: false)
                updateTargetPointer(point: CGPoint(x: 0, y: listView.contentOffset.y + listView.bounds.height))
            }
            if newScrollContent == 0 || newScrollContent == max(0, listView.contentSize.height - listView.bounds.height) {
                stopAutoScroll()
            }
        case .horizontal:
            var newScrollContent = listView.contentOffset.x
            if targetPoint.x < newScrollContent {
                newScrollContent -= 1
                newScrollContent = max(0, newScrollContent)
                listView.contentOffset = CGPoint(x: newScrollContent, y: 0)
                updateTargetPointer(point: listView.contentOffset)
            } else {
                newScrollContent += 1
                newScrollContent = min(max(0, listView.contentSize.width - listView.bounds.width), newScrollContent)
                listView.contentOffset = CGPoint(x: newScrollContent, y: 0)
                updateTargetPointer(point: CGPoint(x: listView.contentOffset.x + listView.bounds.width, y: 0))
            }
            if newScrollContent == 0 || newScrollContent == max(0, listView.contentSize.width - listView.bounds.width) {
                stopAutoScroll()
            }
        default:
            return
        }
    }

    private func updateTargetPointer(point: CGPoint) {
    }

    // MARK: - control scroll behavior
    private var prohibitedScrollViews: NSHashTable<UIScrollView> = NSHashTable.weakObjects()
    public func prohibitScroll(for view: UIView) {
        if view is UIWindow {
            return
        }
        if
            let scrollView = view as? UIScrollView,
            scrollView.isScrollEnabled
        {
            prohibitedScrollViews.add(scrollView)
            scrollView.isScrollEnabled = false
        }
        guard let superview = view.superview else { return }
        prohibitScroll(for: superview)
    }
    public func restoreScroll() {
        for scrollView in prohibitedScrollViews.allObjects {
            scrollView.isScrollEnabled = true
        }
        prohibitedScrollViews.removeAllObjects()
    }
}

extension ItemMovingHandlerMaskView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let cell = self.item?.cell as? EditableItemCell else { return false }
        if otherGestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer.view === cell.editContainer {
            return true
        }
        return false
    }
}
