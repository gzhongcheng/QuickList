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
    
    public override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(pageList)
        pageList.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 页面控制器展示列表
    public let pageList: QuickSegmentPageListView = {
        let listView = QuickSegmentPageListView()
        listView.scrollDirection = .horizontal
        listView.contentInsetAdjustmentBehavior = .never
        listView.isPagingEnabled = true
        return listView
    }()
}

// MARK: - QuickSegmentPagesItemDelegate
public protocol QuickSegmentPagesItemDelegate: AnyObject {
    /// 滚动进度变化回调
    func segmentPagesItem(_ item: QuickSegmentPagesItem, didScrollTo index: CGFloat)
}

// MARK: - QuickSegmentPagesItem
public final class QuickSegmentPagesItem: ItemOf<QuickSegmentPagesItemCell>, ItemType {
    
    public var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    public var menuHeight: CGFloat = 0
    public var pageContainerHeight: CGFloat?
    public weak var delegate: QuickSegmentPagesItemDelegate?
    public weak var currentListView: QuickSegmentPageListView?
    public var scrollEnable: Bool = true
    public var scrollManager: QuickSegmentScrollManager?
    
    private var contentSize: CGSize = .zero {
        didSet {
            guard let cell = cell as? QuickSegmentPagesItemCell else {
                return
            }
            cell.pageList.snp.remakeConstraints { make in
                make.size.equalTo(contentSize)
                make.center.equalToSuperview()
            }
            cell.contentView.layoutIfNeeded()
            cell.pageList.setNeedUpdateLayout(afterSection: 0, useAnimation: false)
            print("QuickSegmentPagesItem - contentSize: \(contentSize)")
        }
    }
    
    public convenience init(
        pageViewControllers: [QuickSegmentPageViewDelegate],
        menuHeight: CGFloat = 44,
        pageContainerHeight: CGFloat? = nil,
        scrollDirection: UICollectionView.ScrollDirection = .horizontal,
        _ initializer: ((QuickSegmentPagesItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewControllers = pageViewControllers
        self.menuHeight = menuHeight
        self.pageContainerHeight = pageContainerHeight
        initializer?(self)
    }
    
    // 更新cell的布局
    public override func updateCell() {
        super.updateCell()
        guard let cell = cell as? QuickSegmentPagesItemCell else {
            return
        }
        self.currentListView?.removeObserveScrollViewContentOffset()
        self.currentListView = cell.pageList
        if let manager = scrollManager {
            self.currentListView?.observeScrollViewContentOffset(to: manager)
        }
        self.currentListView?.isScrollEnabled = scrollEnable
        cell.pageList.handerDelegate = self
        cell.pageList.form.removeAll()
        let section = Section()
        for pageVC in pageViewControllers {
            section <<< QuickSegmentSinglePageItem(pageViewController: pageVC)
        }
        cell.pageList.form +++ section
    }
    
    public override var identifier: String {
        return "QuickSegmentPagesItem_\(self.section?.index ?? 0)"
    }
    
    deinit {
        self.currentListView?.removeObserveScrollViewContentOffset()
    }
    
    
    /// 计算尺寸
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self,
            let size = self.section?.form?.delegate?.getViewSize()
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            contentSize = CGSize(width: estimateItemSize.width, height: max((pageContainerHeight ?? size.height) - menuHeight, 0))
        case .horizontal:
            contentSize = CGSize(width: max((pageContainerHeight ?? size.width) - menuHeight, 0), height: estimateItemSize.height)
        case .free:
            contentSize = size
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
        guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating else {
            /// 判断是否手势滚动
            return
        }
        let index = scrollView.contentOffset.x / scrollView.bounds.width
        self.delegate?.segmentPagesItem(self, didScrollTo: index)
    }
}
