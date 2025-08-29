//
//  QuickSegmentSinglePageItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
import SnapKit

// 单个页面的Item
// MARK:- QuickSegmentSinglePageItemCell
class QuickSegmentSinglePageItemCell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK:- QuickSegmentSinglePageItem
final class QuickSegmentSinglePageItem: ItemOf<QuickSegmentSinglePageItemCell>, ItemType {
    var pageViewController: QuickSegmentPageViewDelegate?
    
    convenience init(
        pageViewController: QuickSegmentPageViewDelegate,
        _ initializer: ((QuickSegmentSinglePageItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewController = pageViewController
        initializer?(self)
    }
    
    // 更新cell的布局
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
        pageVC.beginAppearanceTransition(false, animated: false)
    }
    
    override var identifier: String {
        return "QuickSegmentSinglePageItem_\(self.indexPath?.row ?? 0)"
    }
    
    /// 计算尺寸
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

