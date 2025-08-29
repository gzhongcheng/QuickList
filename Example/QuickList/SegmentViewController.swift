//
//  SegmentViewController.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/8/22.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import QuickList
import SnapKit

class SegmentViewController: UIViewController {
    let formlist = QuickSegmentPageListView()
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            _ in
            self.formlist.reload()
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formlist.contentInsetAdjustmentBehavior = .always
        self.view.addSubview(formlist)
        formlist.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let formHeader = FormCompressibleDecorationView<CompressibleHeaderView>()
        /// 设置悬浮
        formHeader.shouldSuspension = false
        /// 设置压缩
        formHeader.minSize = CGSize(width: 40, height: 40)
        /// 设置默认尺寸
        formHeader.height = { _, _, _ in
            80
        }
        /// 设置拉伸时的逻辑
        formHeader.displayType = .stretch
        formlist.form.header = formHeader
        
        let menuBgView = UIView()
        menuBgView.backgroundColor = .white
        
        let menuBgView1 = UIView()
        menuBgView1.backgroundColor = .white
        
        let scrollManager = QuickSegmentScrollManager(rootScrollView: formlist)
        
        formlist.form
        +++ QuickSegmentSection(
            menuBackground: menuBgView,
            menuSelectedItemDecoration: SegmentTabSelectedView(),
            pageViewControllers: [
                SegmentPageViewController(),
                SegmentPageViewController1(),
                SegmentPageViewController2()
            ],
//            pageContainerHeight: 300,
            scrollManager: scrollManager
        )
        +++ QuickSegmentSection(
            menuBackground: menuBgView1,
            menuSelectedItemDecoration: SegmentTabSelectedView(),
            pageViewControllers: [
                SegmentPageViewController(),
                SegmentPageViewController1(),
                SegmentPageViewController2()
            ],
            scrollManager: scrollManager
        )
    }
}

class SegmentPageViewController: UIViewController, QuickSegmentPageViewDelegate {
    var pageTabItem: QuickList.Item = TitleValueItem() { item in
        item.value = "测试页面"
    }
    
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return formlist
    }
    
    let formlist = QuickSegmentPageListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(formlist)
        formlist.contentInsetAdjustmentBehavior = .never
        formlist.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let formHeader = FormCompressibleDecorationView<CompressibleHeaderView>()
        /// 设置悬浮
        formHeader.shouldSuspension = false
        /// 设置压缩
        formHeader.minSize = CGSize(width: 40, height: 40)
        /// 设置默认尺寸
        formHeader.height = { _, _, _ in
            80
        }
        /// 设置拉伸时的逻辑
        formHeader.displayType = .normal
        formlist.form.header = formHeader
        
        let towColumSection = Section("固定大小两列图片") { section in
            section.column = 2
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
        }
        for i in 0 ... 30 {
            towColumSection <<< newImageItem(i, getNumberImage(i)).onCellSelection { [weak self] item in
                guard let `self` = self, let section = item.section, let itemIndex = item.indexPath?.item else { return }
                let index = section.count
//                section <<<! self.newImageItem(index, self.getNumberImage(index))
                section >>>! (itemIndex ..< itemIndex + 1, [newImageItem(i + 30, getRandomGif())])
            }
        }
        
        formlist.form +++ towColumSection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SegmentPageViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SegmentPageViewController viewWillDisappear")
    }
}

class SegmentPageViewController1: UIViewController, QuickSegmentPageViewDelegate {
    var pageTabItem: QuickList.Item = TitleValueItem() { item in
        item.value = "测试页面1"
    }
    
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SegmentPageViewController1 viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SegmentPageViewController1 viewWillDisappear")
    }
}

class SegmentPageViewController2: UIViewController, QuickSegmentPageViewDelegate {
    var pageTabItem: QuickList.Item = TitleValueItem() { item in
        item.value = "测试页面2"
    }
    
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SegmentPageViewController2 viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SegmentPageViewController2 viewWillDisappear")
    }
}
