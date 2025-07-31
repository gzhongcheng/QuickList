//
//  QuickSegmentSection.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/3/28.
//

import UIKit
import SnapKit

public class QuickSegmentSection: Section {
    /// 菜单Item间距
    var menuItemSpace: CGFloat = 30
    /// 菜单Item列表
    var menuItems: [Item] = [] {
        didSet {
            self.reloadMenu()
        }
    }
    
    /// 页面控制器列表
    var pageViewControllers: [QuickSegmentPageViewDelegate] = []
    
    convenience init(
        menuHeight: CGFloat,
        menuItemSpace: CGFloat,
        menuListInsets: UIEdgeInsets,
        menuBackgroundDecoration: UIView? = nil,
        menuSelectedItemDecoration: UIView? = nil,
        menuItems: [Item],
        pageViewControllers: [QuickSegmentPageViewDelegate],
        _ initializer: (Section) -> Void
    ) {
        
        self.init(initializer)
        
        self.menuTabList.form.selectedItemDecoration = menuSelectedItemDecoration
        self.menuTabList.form.backgroundDecoration = menuBackgroundDecoration
        self.header = SectionHeaderFooterView<UICollectionReusableView>({[weak self] view, section in
            guard let self = self else { return }
            view.addSubview(self.menuTabList)
            self.menuTabList.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })
        self.header?.shouldSuspension = true
        self.header?.height = { [weak self] _, _, _ in
            menuHeight
        }
        self.menuItemSpace = menuItemSpace
        self.menuItems = menuItems
        self.reloadMenu()
        self.pageViewControllers = pageViewControllers
    }
    
    /// 菜单列表Tab
    public let menuTabList: QuickListView = {
        let listView = QuickListView()
        listView.scrollDirection = .horizontal
        return listView
    }()
    
    /// 页面item
    public lazy var pagesItem: QuickSegmentPagesItem = {
        let item = QuickSegmentPagesItem(pageViewControllers: self.pageViewControllers)
        return item
    }()
    
    func reloadMenu() {
        let section = Section { section in
            section.lineSpace = self.menuItemSpace
        }
        section.append(contentsOf: self.menuItems)
        self.menuTabList.form.removeAll()
        self.menuTabList.form.append(section)
        self.menuTabList.reload()
    }
}
