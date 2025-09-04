//
//  QuickSegmentPagesItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
import SnapKit

// Senment页面容器
// MARK: - QuickSegmentPagesItemCell
public class QuickSegmentPagesItemCell: ItemCell {
    
    public override var contentView: UIView {
        return pageList
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        pageList.frame = bounds
    }
    
    public override func setup() {
        super.setup()
        backgroundColor = .clear
        
        self.addSubview(pageList)
        
        pageList.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
    
    /// 页面控制器展示列表
    public let pageList: QuickSegmentPagesListView = {
        let listView = QuickSegmentPagesListView()
        listView.isQuickSegmentSubPage = true
        listView.scrollDirection = .horizontal
        listView.contentInsetAdjustmentBehavior = .never
        listView.isPagingEnabled = true
//        listView.bounces = false
        return listView
    }()
}

extension QuickSegmentPagesItemCell: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self {
            return true
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view == self {
            return true
        }
        return false
    }
}

// MARK: - QuickSegmentPagesItemDelegate
public protocol QuickSegmentPagesItemDelegate: AnyObject {
    /// 滚动进度变化回调
    func segmentPagesItem(_ item: QuickSegmentPagesItem, didScrollTo index: CGFloat)
}

// MARK: - QuickSegmentPagesItem
public final class QuickSegmentPagesItem: ItemOf<QuickSegmentPagesItemCell>, ItemType {
    public enum MenuType {
        case header
        case item
    }
    
    public var pagesScrollDirection: UICollectionView.ScrollDirection = .horizontal
    public var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    public var menuHeight: CGFloat = 0
    public var menuType: MenuType = .header
    public var pageContainerHeight: CGFloat?
    public weak var delegate: QuickSegmentPagesItemDelegate?
    public weak var currentListView: QuickSegmentPagesListView?
    public var scrollEnable: Bool = true
    public weak var scrollManager: QuickSegmentScrollManager?
    public var shouldScrollToTopWhenPageDisappear: Bool = true
    
    private var contentSize: CGSize = .zero {
        didSet {
            guard let cell = cell as? QuickSegmentPagesItemCell else {
                return
            }
            cell.pageList.setNeedUpdateLayout(afterSection: 0, useAnimation: false)
            print("QuickSegmentPagesItem - contentSize: \(contentSize)")
        }
    }
    
    public convenience init(
        pageViewControllers: [QuickSegmentPageViewDelegate],
        pageContainerHeight: CGFloat? = nil,
        scrollDirection: UICollectionView.ScrollDirection = .horizontal,
        _ initializer: ((QuickSegmentPagesItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewControllers = pageViewControllers
        self.pageContainerHeight = pageContainerHeight
        initializer?(self)
    }
    
    // 更新cell的布局
    public override func updateCell() {
        super.updateCell()
        guard let cell = cell as? QuickSegmentPagesItemCell else {
            return
        }
        self.currentListView = cell.pageList
        self.currentListView?.scrollManager = self.scrollManager
        self.currentListView?.pageScrollEnable = scrollEnable
        cell.pageList.scrollDirection = pagesScrollDirection
        cell.pageList.handerDelegate = self
        cell.pageList.form.removeAll()
        let section = Section()
        for pageVC in pageViewControllers {
            section <<< QuickSegmentSinglePageItem(pageViewController: pageVC, shouldScrollToTopWhenDisappear: shouldScrollToTopWhenPageDisappear)
        }
        cell.pageList.form +++ section
    }
    
    public override var identifier: String {
        return "QuickSegmentPagesItem_\(self.section?.index ?? 0)"
    }
    
    
    /// 计算尺寸
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        let size = CGSize(width: view.bounds.width - view.adjustedContentInset.left, height: view.bounds.height - view.adjustedContentInset.top)
        switch layoutType {
        case .vertical:
            switch menuType {
            case .header:
                contentSize = CGSize(width: estimateItemSize.width, height: max((pageContainerHeight ?? size.height) - menuHeight, 0))
            case .item:
                contentSize = CGSize(width: max(estimateItemSize.width - menuHeight, 0), height: pageContainerHeight ?? size.height)
            }
        case .horizontal:
            switch menuType {
            case .header:
                contentSize = CGSize(width: max(0, pageContainerHeight ?? (size.width - menuHeight)), height: estimateItemSize.height)
            case .item:
                contentSize = CGSize(width: pageContainerHeight ?? size.width, height: estimateItemSize.height - menuHeight)
            }
        case .free:
            switch view.scrollDirection {
            case .vertical:
                switch menuType {
                case .header:
                    contentSize = CGSize(width: estimateItemSize.width, height: max((pageContainerHeight ?? size.height) - menuHeight, 0))
                case .item:
                    contentSize = CGSize(width: max(estimateItemSize.width - menuHeight, 0), height: pageContainerHeight ?? size.height)
                }
            case .horizontal:
                switch menuType {
                case .header:
                    contentSize = CGSize(width: max(0, pageContainerHeight ?? (size.width - menuHeight)), height: estimateItemSize.height)
                case .item:
                    contentSize = CGSize(width: pageContainerHeight ?? size.width, height: estimateItemSize.height - menuHeight)
                }
            @unknown default:
                contentSize = size
            }
        }
        return contentSize
    }
    
    public func scrollToPage(index: Int, animated: Bool) {
        guard
            let cell = cell as? QuickSegmentPagesItemCell,
            index >= 0,
            index < pageViewControllers.count
        else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        cell.pageList.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

extension QuickSegmentPagesItem: FormViewHandlerDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating,
            let cell = self.cell as? QuickSegmentPagesItemCell
        else {
            /// 判断是否手势滚动
            return
        }
        if cell.pageList.scrollDirection == .horizontal {
            let index = scrollView.contentOffset.x / scrollView.bounds.width
            self.delegate?.segmentPagesItem(self, didScrollTo: index)
        } else {
            let index = scrollView.contentOffset.y / scrollView.bounds.height
            self.delegate?.segmentPagesItem(self, didScrollTo: index)
        }
    }
}
