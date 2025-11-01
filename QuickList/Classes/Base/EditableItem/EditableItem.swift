//
//  EditableItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/29.
//

import UIKit

// MARK: - EditableItemCell
// EditableItemCell
open class EditableItemCell: ItemCell {
    
    private weak var currentItem: Item?
    public override var item: Item? {
        didSet {
            guard let eItem = item as? EditableItemType, eItem != currentItem else { return }
            currentItem = item
            self.editType = eItem.editType
            self.editContentCompression = eItem.editContentCompression
            self.editIcon = eItem.editIcon
            self.editIconColor = eItem.editIconColor
            self.editIconSize = eItem.editIconSize
            self.editContainerWidth = eItem.editContainerWidth
        }
    }
    
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .delete {
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
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(self.editContainerWidth)
        }

        self.editContainer.isUserInteractionEnabled = true
        deleteGestureRecognizer.addTarget(self, action: #selector(handleDeleteGestureRecognizer(_:)))
        moveGestureRecognizer.addTarget(self, action: #selector(handleMoveGestureRecognizer(_:)))
//        moveGestureRecognizer.delegate = self

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
        guard let item = self.item as? EditableItemType, !item.isDragging else { return }
        let pointInSelf = gesture.location(in: self)
        let pointInWindow = gesture.location(in: UIApplication.shared.keyWindow)
        switch gesture.state {
        case .began:
            ItemMovingHandlerMaskView.shared.item = item
            ItemMovingHandlerMaskView.shared.startMoveAnimation(pointInCell: pointInSelf, pointInWindow: pointInWindow)
//        case .changed:
//            ItemMovingHandlerMaskView.shared.updateMoveAnimationSnapshot(pointInWindow: pointInWindow)
//        case .ended, .cancelled:
//            ItemMovingHandlerMaskView.shared.endMoveAnimation()
        default:
//            ItemMovingHandlerMaskView.shared.endMoveAnimation()
            return
        }
    }
}

extension EditableItemCell: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view == ItemMovingHandlerMaskView._sharedInstance
    }
}

// MARK: - EditableItem
// EditableItem
open class EditableItemOf<Cell: EditableItemCell>: ItemOf<Cell>, EditableItemType {
    public weak var delegate: EditableItemDelegate?
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .delete
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
}

// MARK: - AutolayoutEditableItemOf
// AutolayoutEditableItemOf
open class AutolayoutEditableItemOf<Cell: EditableItemCell>: AutolayoutItemOf<Cell>, EditableItemType {
    public weak var delegate: EditableItemDelegate?
    /**
     * 编辑类型
     * Edit type
     */
    public var editType: EditableItemEditType = .delete
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
}
