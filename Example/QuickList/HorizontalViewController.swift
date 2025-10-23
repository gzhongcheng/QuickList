//
//  HorizontalViewController.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/8/22.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import QuickList
import SnapKit

class HorizontalViewController: UIViewController {
    
    let formlist = QuickListView()
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            _ in
            self.formlist.reload()
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        formlist.scrollDirection = .horizontal
        self.view.addSubview(formlist)
        formlist.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        formlist.form.backgroundDecoration = UIView()
        formlist.form.backgroundDecoration?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let formHeader = FormCompressibleDecorationView<CompressibleHeaderView>()
        /**
         * 设置悬浮
         * Set suspension
         */
        formHeader.shouldSuspension = true
        /**
         * 设置压缩
         * Set compression
         */
        formHeader.minSize = CGSize(width: 40, height: 40)
        /**
         * 设置默认尺寸
         * Set default size
         */
        formHeader.height = { _, _, _ in
            80
        }
        /**
         * 设置拉伸时的逻辑
         * Set the logic for stretching
         */
        formHeader.displayType = .top
        formlist.form.header = formHeader
        
        
        let formFooter = FormCompressibleDecorationView<CompressibleHeaderView>()
        /**
         * 设置悬浮
         * Set suspension
         */
        formFooter.shouldSuspension = true
        /**
         * 设置压缩
         * Set compression
         */
        formFooter.minSize = CGSize(width: 40, height: 40)
        /**
         * 设置默认尺寸
         * Set default size
         */
        formFooter.height = { _, _, _ in
            80
        }
        /**
         * 设置拉伸时的逻辑
         * Set the logic for stretching
         */
        formFooter.displayType = .bottom

        formlist.form.footer = formFooter
        
        // MARK: - Add sections after creation
        formlist.form +++ Section(header: "自动换行", footer: nil) { section in
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
            section.column = 3
            /**
             * 可以是自定义的UICollectionReusableView
             * Can be a custom UICollectionReusableView
             */
            section.footer = SectionHeaderFooterView<UICollectionReusableView> { view,section in
                view.backgroundColor = .lightGray
            }
            /**
             * 高度计算方法
             * Height calculation method
             */
            section.footer?.height = { section, estimateItemSize, scrollDirection in
                return 40
            }
            section.decoration = SectionDecorationView<UICollectionReusableView> { view, _  in
                let imageView = UIImageView(image: UIImage(named: "E-1251692-C01A20FE"))
                view.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
//            section.layout = RowEqualHeightLayout()
            section.isFormHeader = true
        }
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("Tag Tag Tag Tag")
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("标签")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("Tag Tag Tag")
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag Tag Tag Tag")
        +++ Section(header:"LineItem", footer: "LineItem End") { section in
            section.lineSpace = 0
            section.column = 1
            section.header?.shouldSuspension = true
            section.footer?.shouldSuspension = true
        }
            <<< LineItem() { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
                item.lineWidth = 30
                item.lineRadius = 15
            }
            <<< LineItem() { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 0)
                item.lineWidth = 3
                item.lineRadius = 1.5
            }
            <<< LineItem() { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
                item.lineColor = .red
            }
            <<< LineItem() { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            }
        +++ Section("ImageItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
        let towColumSection = Section("Fixed Size Two Column Images") { section in
            section.column = 2
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
        }
        for i in 0 ... 30 {
            towColumSection <<< newImageItem(i, getNumberImage(i)).onCellSelection { [weak self] item in
                guard let `self` = self, let section = item.section, let itemIndex = item.indexPath?.item else { return }
                let index = section.count
                section >>>! (itemIndex ..< itemIndex + 1, [self.newImageItem(index, self.getNumberImage(Int.random(in: 10 ... 20)))])
            }
        }
        for i in 0...30 {
            towColumSection.append(newImageItem(i + 30, getRandomGif()))
        }
        
        formlist.form +++ towColumSection

        let threeColumSection = Section(header: "Automatic Size Three Column Images", footer: "No more!") { section in
            section.column = 3
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 5
            section.itemSpace = 5
            section.header?.shouldSuspension = true
            section.footer?.shouldSuspension = true
        }
        for i in 0 ... 30 {
            threeColumSection <<< newImageItem(i, getRandomImage(), true)
        }
        formlist.form +++ threeColumSection
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newImageItem(_ index: Int, _ url: String,_ autoSize: Bool = false) -> ImageItem {
        return ImageItem(tag: "\(index + 1)") { item in
            item.imageUrl = url
            item.corners = [.leftTop(10),.rightBottom(15)] // CornerType.all(5)
            item.autoSize = autoSize
            item.aspectRatio = CGSize(width: 1, height: 1)
            item.loadFaildImage = UIImage(named: "load_faild")
            item.loadingIndicatorType = .activity
        }
    }
    
    func newTagItem(_ title: String) -> TitleValueItem {
        return TitleValueItem(title) { item in
            item.value = "x"
            item.valueColor = .black
            item.spaceBetweenTitleAndValue = 15
            item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
            item.titleHighlightColor = .white
            item.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
            item.onCellSelection { item in
                if item.value == "x" {
                    item.section?.hideAllItems(withOut: [item], withAnimation: true)
                    item.value = "o"
                } else {
                    item.section?.showAllItems()
                    item.value = "x"
                }
            }
        }
    }

    /**
     * 获取html图片item
     * Get html image item
     */
    func getHtmlImageItem(isFirst: Bool = false, isLast: Bool = false) -> HtmlInfoItem {
        return HtmlInfoItem() { item in
            item.content = getHtmlImage()
            item.estimatedSize = CGSize(width: 750, height: 730)
            item.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            if isFirst {
                item.contentInsets.top = 10
            }
            if isLast {
                item.contentInsets.bottom = 10
            }
        }
    }

    /**
     * 获取随机图片
     * Get random image
     */
    func getRandomImage() -> String {
        let width:Int = Int.random(in: 1000 ... 2000)
        let height: Int = Int.random(in: 1000 ... 2000)
        return "https://picsum.photos/\(width)/\(height)"
    }


    /**
     * html字符串
     * Html string
     */
    func getHtmlImage() -> String {
        return "<img src = \"\(getNumberImage(Int.random(in: 0 ... numberImages.count)))\"/>"
    }
    
    /**
     * 获取数字图片
     * Get number image
     */
    func getNumberImage(_ number: Int) -> String {
        return numberImages[number % numberImages.count]
    }
    
    /**
     * 获取随机gif图片
     * Get random gif image
     */
    func getRandomGif() -> String {
        let index:Int = Int(arc4random() % UInt32(gifImages.count))
        return gifImages[index]
    }
    
    /**
     * 数字图片
     * Number image
     */
    let numberImages = [
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBQFf-a7RNVY_UmC4wWxNc3DruB7Rj3kum_Q&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTAicnETuEvxtX8EzrQyPPA7teboS0QWsbp4g&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3ZHYRyRRsTqdRIEatM-3whUB7nQLS5zF1_A&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMvZXu4KGdxS4I5NwvFX5clpU2v5JvXCpOLA&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKvqVlhk7hnfqwMVUS-cJ2g4vNKoNB7xne0A&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShb7cXxNW2OOM57SxltaNxJJF6yU_JQtkO3g&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVP2j-IOBMNK39hEH4sZpo1VlD0f8BcNrb_w&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS79k7tc_7waBNPdIQqRbwhGs-IQosLu5JaFA&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRVaeTc6yhd6EM1OZ4BnmUooc_T6HO8fa4wOQ&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOyi67ED7rtoAupEqz4LHannal7d0-wdtwUQ&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaDVrN-n0N-z8YQ4QL6rtNjkVTCWku4RkD8Q&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjbhUuUkCeNgr87pkcH5QgzOLae4NOAe0Kog&usqp=CAU",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMBJLkcBA4-HKgAbAiO6pbstwK3mGMe7zH0Q&usqp=CAU"
    ]
    
    /**
     * gif图片
     * Gif image
     */
    let gifImages = [
        "http://hbimg.huabanimg.com/3fee54d0b2e0b7a132319a8e104f5fdc2edd3d35d03ee-93Jmdq_fw658",
        "http://5b0988e595225.cdn.sohucs.com/images/20180510/c861c0e9509546f98c25ef09419f1b81.gif",
        "https://img.zcool.cn/community/01b0d857b1a34d0000012e7e87f5eb.gif",
        "http://img.mp.sohu.com/upload/20170610/57fd225c09e04457a743253fa7191f85_th.png"
    ]
}

extension HorizontalViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
