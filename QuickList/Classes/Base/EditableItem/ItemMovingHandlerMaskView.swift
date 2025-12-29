//
//  ItemMovingHandlerMaskView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/10/30.
//

import Foundation

// MARK: - MovingHandlerMaskView
// MovingHandlerMaskView
public class ItemMovingHandlerMaskView: UIView {
    /**
     * 自动滚动的步长, 不设置的话默认为当前cell高度的两倍(即每次滚动两个cell的高度)
     * The step of auto scroll, if not set, default is the height of the cell * 2 (i.e. scroll two cell heights)
     */
    public var autoScrollStep: CGFloat?
    /**
     * 自动滚动的间隔时间
     * The interval time between auto scroll
     */
    public var autoScrollTimeSpace: TimeInterval = 1

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
            for view in moveSnapshotContainerView.subviews {
                view.removeFromSuperview()
            }
            if let snapshot = moveSnapshot {
                moveSnapshotContainerView.addSubview(snapshot)
                snapshot.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
    private lazy var moveSnapshotContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        self.addSubview(view)
        return view
    }()
    
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
            _sharedInstance = ItemMovingHandlerMaskView()
            return _sharedInstance!
        }
        return instance
    }
    
    /**
     释放单例对象
     Destruction of single instance object
     */
    public static func destroy() {
        _sharedInstance?.reset()
        _sharedInstance = nil
    }
    
    public func reset() {
        removeTargetIndicator()
        stopAutoScroll()
        for view in moveSnapshotContainerView.subviews {
            view.removeFromSuperview()
        }
        moveSnapshot = nil
        item = nil
        moveStartPointInItem = .zero
        moveStartPointInWindow = .zero
        restoreScroll()
        self.removeFromSuperview()
    }
    
    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        guard self.item != nil else {
            reset()
            return
        }
        switch gesture.state {
        case .began:
            startMoveAnimation(pointInCell: gesture.location(in: item?.cell ?? UIView()), pointInWindow: gesture.location(in: UIApplication.shared.keyWindow))
        case .changed:
            updateMoveAnimationSnapshot(pointInWindow: gesture.location(in: UIApplication.shared.keyWindow))
        case .ended, .cancelled:
            endMoveAnimation()
        default:
            endMoveAnimation()
        }
    }

    public func startMoveAnimation(pointInCell: CGPoint, pointInWindow: CGPoint) {
        if moveSnapshot != nil {
            return
        }
        guard let item = self.item, let cell = item.cell, let indexPath = item.indexPath else {
            reset()
            return
        }
        item.isDragging = true
        item.form?.listLayout?.layoutAttributesForItem(at: indexPath)?.alpha = 0
        cell.alpha = 0
        
        prohibitScroll(for: cell)

        moveStartPointInItem = pointInCell
        moveStartPointInWindow = pointInWindow
        moveSnapshot = cell.snapshotView(afterScreenUpdates: false)
        moveSnapshot?.contentMode = .topLeft
        moveSnapshotContainerView.frame = CGRect(x: pointInWindow.x - pointInCell.x, y: pointInWindow.y - pointInCell.y, width: cell.frame.width, height: cell.frame.height)
        if let delegate = item.delegate {
            delegate.preProcessScreenshot(view: moveSnapshotContainerView)
        } else {
            var blurEffect: UIBlurEffect = UIBlurEffect(style: .regular)
            if #available(iOS 13.0, *) {
                blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            }
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            moveSnapshotContainerView.insertSubview(blurEffectView, at: 0)
            blurEffectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            moveSnapshotContainerView.layer.shadowColor = UIColor.systemGray.cgColor
            moveSnapshotContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            moveSnapshotContainerView.layer.shadowOpacity = 0.5
            moveSnapshotContainerView.layer.shadowRadius = 2
        }
        UIApplication.shared.keyWindow?.addSubview(ItemMovingHandlerMaskView.shared)
        ItemMovingHandlerMaskView.shared.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIApplication.shared.keyWindow?.layoutIfNeeded()
    }
    
    public func updateMoveAnimationSnapshot(pointInWindow: CGPoint) {
        moveSnapshotContainerView.frame = CGRect(x: pointInWindow.x - self.moveStartPointInItem.x, y: pointInWindow.y - self.moveStartPointInItem.y, width: moveSnapshotContainerView.frame.width, height: moveSnapshotContainerView.frame.height)
        
        DispatchQueue.main.async {
            guard
                let listView = self.item?.section?.form?.delegate?.scrollFormView
            else { return }
            let pointInScrollView = listView.convert(pointInWindow, from: UIApplication.shared.keyWindow)
            switch listView.scrollDirection {
            case .vertical:
                if pointInScrollView.y <= listView.contentOffset.y + listView.adjustedContentInset.top {
                    self.autoScrollTo(point: CGPoint(x: 0, y: -listView.adjustedContentInset.top))
                } else if pointInScrollView.y >= listView.contentOffset.y + listView.bounds.height - listView.adjustedContentInset.bottom {
                    self.autoScrollTo(point: CGPoint(x: 0, y: listView.contentSize.height - listView.bounds.height + listView.adjustedContentInset.bottom))
                } else {
                    self.stopAutoScroll()
                    self.updateTargetPointer()
                }
            case .horizontal:
                if pointInScrollView.x <= listView.contentOffset.x {
                    self.autoScrollTo(point: .zero)
                } else if pointInScrollView.x >= listView.contentOffset.x + listView.bounds.width - 50 {
                    self.autoScrollTo(point: CGPoint(x: listView.contentSize.width - listView.bounds.width, y: 0))
                } else {
                    self.stopAutoScroll()
                    self.updateTargetPointer()
                }
            default:
                return
            }
        }
    }

    public func endMoveAnimation() {
        guard let item = self.item else { return }
        stopAutoScroll()
        restoreScroll()
        guard let indexPath = item.indexPath else { return }
        if let targetMoveIndexPath = self.targetMoveIndexPath {
            removeTargetIndicator()
            item.isDragging = false
            item.form?.delegate?.scrollFormView?.handler.updateLayout(sections: nil, inAnimation: .transform, othersInAnimation: .transform) { (listView, layout) in
                guard
                  let section = item.section, 
                  let currentItemIndexPath = item.indexPath, 
                  let targetSection = item.form?.sections[targetMoveIndexPath.section]
                else {
                    return 
                }
                section.remove(at: currentItemIndexPath.row)
                targetSection.insert(item, at: targetMoveIndexPath.row)
                listView?.deleteItems(at: [currentItemIndexPath])
                listView?.insertItems(at: [targetMoveIndexPath])
                layout?.reloadSectionsAfter(index: min(currentItemIndexPath.section, targetMoveIndexPath.section), needOldSectionAttributes: true)
                if
                    let targetCellFrame = layout?.layoutAttributesForItem(at: targetMoveIndexPath)?.frame,
                    let targetCellFrameInWindow = listView?.convert(targetCellFrame.origin, to: UIApplication.shared.keyWindow)
                {
                    self.moveSnapshotContainerView.frame = CGRect(x: targetCellFrameInWindow.x, y: targetCellFrameInWindow.y, width: targetCellFrame.width, height: targetCellFrame.height)
                }
            } completion: {
                self.item?.form?.listLayout?.layoutAttributesForItem(at: targetMoveIndexPath)?.alpha = 1
                self.item?.cell?.alpha = 1
                item.delegate?.didFinishExchange(item: item)
                self.reset()
            }
        } else {
            let itemAttr = item.form?.listLayout?.layoutAttributesForItem(at: indexPath)
            let itemFrame = itemAttr?.frame ?? .zero
            let itemPointInWindow = item.form?.delegate?.scrollFormView?.convert(itemFrame.origin, to: UIApplication.shared.keyWindow) ?? .zero
            UIView.animate(withDuration: 0.3, animations: {
                self.moveSnapshotContainerView.frame = CGRect(x: itemPointInWindow.x, y: itemPointInWindow.y, width: itemFrame.width, height: itemFrame.height)
            }, completion: { _ in
                item.isDragging = false
                itemAttr?.alpha = 1
                self.item?.cell?.alpha = 1
                self.reset()
            })
        }
        
    }
    
    // MARK: - auto scroll behavior
    private func autoScrollTo(point: CGPoint) {
        guard
            autoScrollTimer == nil
        else {
            return
        }
        guard
            let listView = self.item?.section?.form?.delegate?.scrollFormView
        else {
            stopAutoScroll()
            return
        }
        switch listView.scrollDirection {
        case .vertical:
            if point.y == listView.contentOffset.y {
                stopAutoScroll()
                return
            }
        case .horizontal:
            if point.x == listView.contentOffset.x {
                stopAutoScroll()
                return
            }
        default:
            return
        }
        autoScrollTargetPoint = point
        scrollScrollView()
        autoScrollTimer = Timer.scheduledTimer(timeInterval: autoScrollTimeSpace, target: self, selector: #selector(scrollScrollView), userInfo: nil, repeats: true)
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc private func scrollScrollView() {
        guard
            let listView = self.item?.section?.form?.delegate?.scrollFormView,
            let targetPoint = self.autoScrollTargetPoint
        else {
            return
        }
        let autoScrollStep = self.autoScrollStep ?? moveSnapshotContainerView.frame.height * 2
        switch listView.scrollDirection {
        case .vertical:
            var newScrollContent = listView.contentOffset.y
            if targetPoint.y < newScrollContent {
                newScrollContent -= autoScrollStep
                newScrollContent = max(-listView.adjustedContentInset.top, newScrollContent)
                listView.setContentOffset(CGPoint(x: -listView.adjustedContentInset.left, y: newScrollContent), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    self.updateTargetPointer()
                }
            } else {
                newScrollContent += autoScrollStep
                newScrollContent = min(listView.contentSize.height - listView.bounds.height + listView.adjustedContentInset.bottom, newScrollContent)
                listView.setContentOffset(CGPoint(x: -listView.adjustedContentInset.left, y: newScrollContent), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    self.updateTargetPointer()
                }
            }
            if newScrollContent == -listView.adjustedContentInset.top || newScrollContent == listView.contentSize.height - listView.bounds.height + listView.adjustedContentInset.bottom {
                stopAutoScroll()
            }
        case .horizontal:
            var newScrollContent = listView.contentOffset.x
            if targetPoint.x < newScrollContent {
                newScrollContent -= autoScrollStep
                newScrollContent = max(-listView.adjustedContentInset.left, newScrollContent)
                listView.setContentOffset(CGPoint(x: newScrollContent, y: -listView.adjustedContentInset.top), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.updateTargetPointer()
                }
            } else {
                newScrollContent += autoScrollStep
                newScrollContent = min(listView.contentSize.width - listView.bounds.width + listView.adjustedContentInset.right, newScrollContent)
                listView.setContentOffset(CGPoint(x: newScrollContent, y: -listView.adjustedContentInset.top), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.updateTargetPointer()
                }
            }
            if newScrollContent == -listView.adjustedContentInset.left || newScrollContent == listView.contentSize.width - listView.bounds.width + listView.adjustedContentInset.right {
                stopAutoScroll()
            }
        default:
            return
        }
    }

    private var targetIndicatorView: EditableItemMoveIndicator = EditableItemMoveIndicator(frame: .zero)
    private var isUpdatingTargetPointer: Bool = false
    private var targetMoveIndexPath: IndexPath?
    private func updateTargetPointer() {
        guard
            !isUpdatingTargetPointer,
            let item = self.item,
            let listView = item.form?.delegate?.scrollFormView,
            let moveSnapshot = self.moveSnapshot,
            let targetItem = item.form?.listLayout?.getTargetItem(at: moveSnapshot.convert(CGPoint(x: moveStartPointInItem.x, y: moveStartPointInItem.y), to: listView)),
            let targetIndexPath = targetItem.indexPath,
            targetItem != item
        else {
            return 
        }
        switch item.editType {
        case .move(let moveAnimation):
            switch moveAnimation {
            case .indicator(let arrowColor, let arrowSize, let lineColor, let lineWidth):
                guard 
                    item != targetItem,
                    let section = targetItem.section,
                    let cell = targetItem.cell,
                    let currentItemIndexPath = item.indexPath
                else { 
                    removeTargetIndicator()
                    return
                }
                if let delegate = item.delegate {
                    if delegate.canExchange(item: item, to: targetItem) != true {
                        removeTargetIndicator()
                        return
                    }
                } else {
                    if !(targetItem is EditableItemType) {
                        removeTargetIndicator()
                        return
                    }
                }
                if targetIndicatorView.superview != listView {
                    targetIndicatorView.removeFromSuperview()
                    listView.addSubview(targetIndicatorView)
                }
                targetIndicatorView.arrowColor = arrowColor
                targetIndicatorView.arrowSize = arrowSize
                targetIndicatorView.lineColor = lineColor
                targetIndicatorView.lineWidth = lineWidth
                targetIndicatorView.alpha = 1
                targetIndicatorView.layer.zPosition = cell.layer.zPosition + 1
                let moveIndicatorToCellTop = {
                    DispatchQueue.main.async {
                        self.targetIndicatorView.updatePosition(to: CGRect(x: cell.frame.minX, y: cell.frame.minY - lineWidth * 0.5 - section.lineSpace * 0.5, width: cell.frame.width, height: lineWidth), direction: .horizontal)
                    }
                }
                let moveIndicatorToCellBottom = {
                    DispatchQueue.main.async {
                        self.targetIndicatorView.updatePosition(to: CGRect(x: cell.frame.minX, y: cell.frame.maxY - lineWidth * 0.5 + section.lineSpace * 0.5, width: cell.frame.width, height: lineWidth), direction: .horizontal)
                    }
                }
                let moveIndicatorToCellLeft = {
                    DispatchQueue.main.async {
                        self.targetIndicatorView.updatePosition(to: CGRect(x: cell.frame.minX - lineWidth * 0.5 - section.itemSpace * 0.5, y: cell.frame.minY, width: lineWidth, height: cell.frame.height), direction: .vertical)
                    }
                }
                let moveIndicatorToCellRight = {
                    DispatchQueue.main.async {
                        self.targetIndicatorView.updatePosition(to: CGRect(x: cell.frame.maxX - lineWidth * 0.5 + section.itemSpace * 0.5, y: cell.frame.minY, width: lineWidth, height: cell.frame.height), direction: .vertical)
                    }
                }
                let positionInCell = moveSnapshot.convert(CGPoint(x: moveStartPointInItem.x, y: moveStartPointInItem.y), to: cell)
                if section.column == 1 || section.column <= item.weight {
                    switch listView.scrollDirection {
                    case .vertical:
                        if positionInCell.y < cell.bounds.height * 0.5 {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row - 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row - 1, section: targetIndexPath.section)
                            } else {
                                targetMoveIndexPath = targetIndexPath
                            }
                            moveIndicatorToCellTop()
                        } else {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row + 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = targetIndexPath
                            } else {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row + 1, section: targetIndexPath.section)
                            }
                            moveIndicatorToCellBottom()
                        }
                    case .horizontal:
                        if positionInCell.x < cell.bounds.width * 0.5 {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row - 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row - 1, section: targetIndexPath.section)
                            } else {
                                targetMoveIndexPath = targetIndexPath
                            }
                            moveIndicatorToCellLeft()
                        } else {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row + 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = targetIndexPath
                            } else {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row + 1, section: targetIndexPath.section)
                            }
                            moveIndicatorToCellRight()
                        }
                    default:
                        return
                    }
                } else {
                    switch listView.scrollDirection {
                    case .horizontal:
                        if positionInCell.y < cell.bounds.height * 0.5 {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row - 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row - 1, section: targetIndexPath.section)
                            } else {
                                targetMoveIndexPath = targetIndexPath
                            }
                            moveIndicatorToCellTop()
                        } else {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row + 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = targetIndexPath
                            } else {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row + 1, section: targetIndexPath.section)
                            }
                            moveIndicatorToCellBottom()
                        }
                    case .vertical:
                        if positionInCell.x < cell.bounds.width * 0.5 {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row - 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row - 1, section: targetIndexPath.section)
                            } else {
                                targetMoveIndexPath = targetIndexPath
                            }
                            moveIndicatorToCellLeft()
                        } else {
                            if
                                currentItemIndexPath.section == targetIndexPath.section,
                                currentItemIndexPath.row == targetIndexPath.row + 1
                            {
                                removeTargetIndicator()
                                return
                            }
                            if currentItemIndexPath.section == targetIndexPath.section, currentItemIndexPath.row < targetIndexPath.row {
                                targetMoveIndexPath = targetIndexPath
                            } else {
                                targetMoveIndexPath = IndexPath(row: targetIndexPath.row + 1, section: targetIndexPath.section)
                            }
                            moveIndicatorToCellRight()
                        }
                    default:
                        return
                    }
                }
            case .exchange:
                guard
                    item.delegate?.canExchange(item: item, to: targetItem) == true
                else {
                    removeTargetIndicator()
                    return
                }
                removeTargetIndicator()
                isUpdatingTargetPointer = true
                DispatchQueue.main.async {
                    item.form?.delegate?.scrollFormView?.handler.updateLayout(sections: nil, inAnimation: .transform, othersInAnimation: .transform) { (listView, layout) in
                        guard
                            let section = item.section,
                            let currentItemIndexPath = item.indexPath,
                            let targetSection = targetItem.section
                        else { return }
                        section.remove(at: currentItemIndexPath.row)
                        targetSection.insert(item, at: targetIndexPath.row)
                        listView?.deleteItems(at: [currentItemIndexPath])
                        listView?.insertItems(at: [targetIndexPath])
                        layout?.reloadSectionsAfter(index: min(currentItemIndexPath.section, targetIndexPath.section), needOldSectionAttributes: true)
                    } completion: {
                        self.isUpdatingTargetPointer = false
                        item.delegate?.didFinishExchange(item: item)
                    }
                }
            }
        case .delete:
            return
        }
    }
    private func removeTargetIndicator() {
        targetIndicatorView.alpha = 0
        targetMoveIndexPath = nil
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
