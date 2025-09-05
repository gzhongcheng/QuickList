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
    let formlist = QuickSegmentRootListView()
    
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
//        formlist.scrollDirection = .horizontal
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
        
        let formFooter = FormCompressibleDecorationView<CompressibleHeaderView>()
        /// 设置悬浮
        formFooter.shouldSuspension = false
        /// 设置压缩
        formFooter.minSize = CGSize(width: 40, height: 40)
        /// 设置默认尺寸
        formFooter.height = { _, _, _ in
            80
        }
        /// 设置拉伸时的逻辑
        formFooter.displayType = .normal

        formlist.form.footer = formFooter
        
        let menuBgView = UIView()
        menuBgView.backgroundColor = .white
        
        let menuBgView1 = UIView()
        menuBgView1.backgroundColor = .white
        
        let scrollManager = QuickSegmentScrollManager.create(
            rootScrollView: formlist,
            bouncesType: .root
        )
        
        let menuConfig = QuickSegmentHorizontalMenuConfig(
            menuBackground: menuBgView,
            menuSelectedItemDecoration: SegmentTabSelectedView()
        )
        
        let menuConfig1 = QuickSegmentVerticalMenuConfig(
            menuWidthType: .auto(maxWidth: 150),
            menuBackground: menuBgView1,
            menuSelectedItemDecoration: SegmentTabSelectedView()
        )
        
        formlist.form
        +++ QuickSegmentSection(
            menuConfig: menuConfig1,
            pageViewControllers: [
                SegmentPageViewController(),
                SegmentPageViewController1(),
                SegmentPageViewController2()
            ],
//            pageScrollEnable: false,
            pageContainerHeight: 300,
            scrollManager: scrollManager
        ) { section in
//            section.shouldScrollToTopWhenSelectedTab = false
        }
        +++ QuickSegmentSection(
            menuConfig: menuConfig,
            pageViewControllers: [
                SegmentPageViewController(),
                SegmentPageViewController3(),
                SegmentPageViewController2()
            ],
//            pageContainerHeight: 300,
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
        
//        formlist.scrollDirection = .horizontal
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
            towColumSection <<< newImageItem(i, getNumberImage(i)).onCellSelection { item in
                guard
                    let section = item.section,
                    let itemIndex = item.indexPath?.item
                else { return }
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
        return scrollView
    }
    
    let scrollView = QuickSegmentPageScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        
        let point = UIView()
        point.backgroundColor = .red
        
        scrollView.addSubview(point)
        point.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        self.view.addSubview(scrollView)
        scrollView.backgroundColor = .lightGray
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.contentSize = CGSize(width: 500, height: 3000)
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
    
    let tableView = QuickSegmentPageTableView()
    
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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

extension SegmentPageViewController2: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "测试数据\(indexPath.row)"
        return cell
    }
}

class SegmentPageViewController3: UIViewController, QuickSegmentPageViewDelegate {
    var pageTabItem: QuickList.Item = TitleValueItem() { item in
        item.value = "测试页面1"
    }
    
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return collectionView
    }
    
    let collectionView = QuickSegmentPageCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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

extension SegmentPageViewController3: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
}


