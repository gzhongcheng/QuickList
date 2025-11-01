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
            ItemMovingHandlerMaskView.destroy()
            return
        }
        item.isDragging = true
        item.form?.listLayout?.layoutAttributesForItem(at: indexPath)?.alpha = 0
        cell.alpha = 0
        
        prohibitScroll(for: cell)

        moveStartPointInItem = pointInCell
        moveStartPointInWindow = pointInWindow
        moveSnapshot = cell.snapshotView(afterScreenUpdates: false)
        moveSnapshot?.frame = CGRect(x: pointInWindow.x - pointInCell.x, y: pointInWindow.y - pointInCell.y, width: cell.frame.width, height: cell.frame.height)
        UIApplication.shared.keyWindow?.addSubview(ItemMovingHandlerMaskView.shared)
        ItemMovingHandlerMaskView.shared.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIApplication.shared.keyWindow?.layoutIfNeeded()
    }
    
    public func updateMoveAnimationSnapshot(pointInWindow: CGPoint) {
        guard let moveSnapshot = self.moveSnapshot else {
            return
        }
        moveSnapshot.frame = CGRect(x: pointInWindow.x - self.moveStartPointInItem.x, y: pointInWindow.y - self.moveStartPointInItem.y, width: moveSnapshot.frame.width, height: moveSnapshot.frame.height)
        
        DispatchQueue.main.async {
            guard
                let listView = self.item?.section?.form?.delegate?.formView
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
        let itemAttr = item.form?.listLayout?.layoutAttributesForItem(at: indexPath)
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
            ItemMovingHandlerMaskView.destroy()
        })
    }
    
    // MARK: - auto scroll behavior
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
            let listView = self.item?.section?.form?.delegate?.formView,
            let targetPoint = self.autoScrollTargetPoint
        else {
            return
        }
        let autoScrollStep = self.autoScrollStep ?? (moveSnapshot?.frame.height ?? 100) * 2
        switch listView.scrollDirection {
        case .vertical:
            var newScrollContent = listView.contentOffset.y
            if targetPoint.y < newScrollContent {
                newScrollContent -= autoScrollStep
                newScrollContent = max(-listView.adjustedContentInset.top, newScrollContent)
                listView.setContentOffset(CGPoint(x: 0, y: newScrollContent), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    self.updateTargetPointer()
                }
            } else {
                newScrollContent += autoScrollStep
                newScrollContent = min(listView.contentSize.height - listView.bounds.height + listView.adjustedContentInset.bottom, newScrollContent)
                listView.setContentOffset(CGPoint(x: 0, y: newScrollContent), animated: true)
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
                listView.setContentOffset(CGPoint(x: newScrollContent, y: 0), animated: true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.updateTargetPointer()
                }
            } else {
                newScrollContent += autoScrollStep
                newScrollContent = min(listView.contentSize.width - listView.bounds.width + listView.adjustedContentInset.right, newScrollContent)
                listView.setContentOffset(CGPoint(x: newScrollContent, y: 0), animated: true)
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

    private var isUpdatingTargetPointer: Bool = false
    private func updateTargetPointer() {
        guard
            !isUpdatingTargetPointer,
            let item = self.item,
            let listView = item.form?.delegate?.formView,
            let moveSnapshot = self.moveSnapshot,
            let targetItem = item.form?.listLayout?.getTargetItem(at: moveSnapshot.convert(CGPoint(x: moveStartPointInItem.x, y: moveStartPointInItem.y), to: listView)),
            let targetIndexPath = targetItem.indexPath,
            targetItem != item
        else { return }
        switch item.editType {
        case .move(let moveAnimation):
            switch moveAnimation {
            case .indicator(let arrowColor, let arrowSize, let lineColor, let lineWidth):
                let indicatorView = UIView()
                indicatorView.backgroundColor = arrowColor
                indicatorView.frame = CGRect(x: 0, y: 0, width: arrowSize.width, height: arrowSize.height)
                self.addSubview(indicatorView)
            case .exchange:
                isUpdatingTargetPointer = true
                item.form?.delegate?.formView?.handler.updateLayout(section: item.section, inAnimation: .transform, othersInAnimation: .transform) { (listView, layout) in
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
                }
            }
        case .delete:
            return
        }
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
