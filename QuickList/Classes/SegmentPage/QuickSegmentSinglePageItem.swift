//
//  QuickSegmentSinglePageItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
import SnapKit

/**
 * 单个页面的Item
 * Single page item
 */
// MARK:- QuickSegmentSinglePageItemCell
class QuickSegmentSinglePageItemCell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

extension QuickSegmentSinglePageItemCell: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self || gestureRecognizer.view == self.contentView {
            return true
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view == self || otherGestureRecognizer.view == self.contentView {
            return true
        }
        return false
    }
}

// MARK:- QuickSegmentSinglePageItem
final class QuickSegmentSinglePageItem: ItemOf<QuickSegmentSinglePageItemCell>, ItemType {
    var pageViewController: QuickSegmentPageViewDelegate?
    var shouldScrollToTopWhenDisappear: Bool = true
    weak var segmentPagesView: QuickSegmentPagesListView?
    
    convenience init(
        pageViewController: QuickSegmentPageViewDelegate,
        shouldScrollToTopWhenDisappear: Bool,
        segmentPagesView: QuickSegmentPagesListView? = nil,
        _ initializer: ((QuickSegmentSinglePageItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewController = pageViewController
        self.shouldScrollToTopWhenDisappear = shouldScrollToTopWhenDisappear
        self.segmentPagesView = segmentPagesView
        initializer?(self)
    }
    
    override func updateCell() {
        super.updateCell()
        guard let cell = cell as? QuickSegmentSinglePageItemCell else {
            return
        }
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        if
            let pageVC = pageViewController,
            let viewController = section?.form?.delegate?.formView?.getViewController(),
            pageVC.parent != viewController || pageVC.view.superview != cell.contentView
        {
            pageVC.listScrollView()?.pageBoxView = segmentPagesView
            if pageVC.parent != nil {
                pageVC.willMove(toParent: nil)
                pageVC.view.removeFromSuperview()
                pageVC.endAppearanceTransition()
                pageVC.removeFromParent()
            }
            viewController.addChild(pageVC)
            pageVC.didMove(toParent: viewController)
            cell.contentView.addSubview(pageVC.view)
            pageVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func willDisplay() {
        super.willDisplay()
        guard let pageVC = pageViewController else {
            return
        }
        pageVC.beginAppearanceTransition(true, animated: false)
    }
    
    override func didEndDisplay() {
        super.didEndDisplay()
        guard let pageVC = pageViewController else {
            return
        }
        if
            let scrollableView = pageVC.listScrollView()
        {
            if scrollableView.isDecelerating {
                scrollableView.forceStopScroll()
            }
            if shouldScrollToTopWhenDisappear {
                scrollableView.contentOffset = .zero
                scrollableView.layoutIfNeeded()
            } else {
                if scrollableView.contentOffset.x < 0 || scrollableView.contentOffset.y < 0 {
                    scrollableView.contentOffset = .zero
                    scrollableView.layoutIfNeeded()
                } else {
                    switch scrollableView.scrollDirection {
                    case .horizontal:
                        if scrollableView.contentOffset.x > (scrollableView.contentSize.width - scrollableView.bounds.width - scrollableView.adjustedContentInset.left - scrollableView.adjustedContentInset.right) {
                            let targetX = max(0, scrollableView.contentSize.width - scrollableView.bounds.width - scrollableView.adjustedContentInset.left - scrollableView.adjustedContentInset.right)
                            scrollableView.contentOffsetX = targetX
                            scrollableView.layoutIfNeeded()
                        }
                    case .vertical:
                        if scrollableView.contentOffset.y > (scrollableView.contentSize.height - scrollableView.bounds.height - scrollableView.adjustedContentInset.top - scrollableView.adjustedContentInset.bottom) {
                            let targetY = max(0, scrollableView.contentSize.height - scrollableView.bounds.height - scrollableView.adjustedContentInset.top - scrollableView.adjustedContentInset.bottom)
                            scrollableView.contentOffsetY = targetY
                            scrollableView.layoutIfNeeded()
                        }
                    @unknown default:
                        break
                    }
                }
            }
        }
        pageVC.beginAppearanceTransition(false, animated: false)
    }
    
    override var identifier: String {
        return "QuickSegmentSinglePageItem_\(self.indexPath?.row ?? 0)"
    }
    
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self,
            let size = self.section?.form?.delegate?.getViewSize()
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return CGSize(width: estimateItemSize.width, height: size.height)
        case .horizontal:
            return CGSize(width: size.width, height: estimateItemSize.height)
        case .free:
            return size
        }
    }
}

