//
//  QuickSegmentPagesItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import Foundation
import SnapKit

// Senment页面容器
// MARK:- QuickSegmentPagesItemCell
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
    public let pageList: QuickListView = {
        let listView = QuickListView()
        listView.scrollDirection = .horizontal
        return listView
    }()
}

// MARK:- QuickSegmentPagesItem
public final class QuickSegmentPagesItem: ItemOf<QuickSegmentPagesItemCell>, ItemType {
    
    public var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    
    public convenience init(
        pageViewControllers: [QuickSegmentPageViewDelegate],
        _ initializer: ((QuickSegmentPagesItem) -> Void)? = nil
    ) {
        self.init()
        self.pageViewControllers = pageViewControllers
        initializer?(self)
    }
    
    // 更新cell的布局
    public override func updateCell() {
        super.updateCell()
        guard let cell = cell as? QuickSegmentPagesItemCell else {
            return
        }
        
    }
    
    public override var identifier: String {
        return "QuickSegmentPagesItem"
    }
    
    
    /// 计算尺寸
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return CGSize(width: estimateItemSize.width, height: self.section?.form?.delegate?.getViewSize().height ?? 0)
        case .horizontal:
            return CGSize(width: self.section?.form?.delegate?.getViewSize().width ?? 0, height: estimateItemSize.height)
        case .free:
            return CGSize(width: self.section?.form?.delegate?.getViewSize().width ?? 0, height: self.section?.form?.delegate?.getViewSize().height ?? 0)
        }
    }
}

