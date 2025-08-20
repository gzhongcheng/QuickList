//
//  ViewController.swift
//  QuickList
//
//  Created by gzc on 08/06/2024.
//  Copyright (c) 2024 gzc. All rights reserved.
//

import UIKit
import QuickList
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /// 支持两种方式创建（直接扔配置进去和后面再添加cell）
        // MARK: - 直接在初始化时设置好sections
//        let formlist = QuickListView(sections: [
//            Section(
//                "自动换行",
//                items: [
//                    ButtonItem("点击跳转(show)") { item in
//                        item.sendValue = "传值1"
//                        /// 设置圆角为高度的一半
//                        item.cornerScale = 0.5
//                        /// 设置边框宽度
//                        item.borderWidth = 1
//                        /// 设置正常颜色
//                        item.titleColor = .black
//                        item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
//                        item.borderColor = UIColor(white: 0.5, alpha: 1.0)
//                        /// 设置高亮颜色
//                        item.titleHighlightColor = .white
//                        item.highlightContentBgColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
//                        item.highlightBorderColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
//                        /// 自动选择push和present
//                        item.presentationMode = .show(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
//                            let vc = ItemPresentViewController<ButtonItem>()
//                            vc.modalPresentationStyle = .fullScreen
//                            vc.item = item
//                            return vc
//                        }), onDismiss: { (vc) in
//                            if vc.navigationController != nil {
//                                vc.navigationController?.popViewController(animated: true)
//                            } else {
//                                vc.dismiss(animated: true)
//                            }
//                        })
//                    }
//                ]
//            ) { section in
//                section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//                section.lineSpace = 10
//                section.itemSpace = 10
//                section.lineHeight = 44
//            }
//        ])
        let formlist = QuickListView()
        self.view.addSubview(formlist)
        
        formlist.listSizeChangedBlock = { newSize in
            formlist.snp.updateConstraints { make in
                make.height.equalTo(min(self.view.bounds.height, newSize.height))
            }
        }
        formlist.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        
        formlist.form.backgroundDecoration = UIView()
        formlist.form.backgroundDecoration?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let header = FormHeaderFooterView()
        header.useAutoLayout = true
        header.backgroundColor = .red
        
        let testLabel = UILabel()
        testLabel.text = "很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度，哈哈哈哈"
        testLabel.numberOfLines = 0
        header.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        formlist.form.header = header
        
        formlist.form.header?.height = { _, _ in
            return 40
        }
        
        formlist.form.footer = FormHeaderFooterView()
        formlist.form.footer?.backgroundColor = .blue
        formlist.form.footer?.height = { _, _ in
            return 40
        }
        
        // MARK: - 创建完成后添加sections
        formlist.form +++ Section(header: "自动换行", footer: nil) { section in
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
            section.column = 3
            /// 可以是自定义的UICollectionReusableView
            section.footer = SectionHeaderFooterView<UICollectionReusableView> { view,section in
                view.backgroundColor = .lightGray
            }
            /// 高度计算方法
            section.footer?.height = { section, estimateItemSize, scrollDirection in
                return 40
            }
            section.decoration = SectionDecorationView<UICollectionReusableView> { view in
                let imageView = UIImageView(image: UIImage(named: "E-1251692-C01A20FE"))
                view.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
//            section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
//            section.layout = QuickListFlowLayout()
            section.layout = RowEqualHeightLayout()
            section.isFormHeader = true
        }
            <<< newTagItem("标签")
            <<< newTagItem("标签标签")
            <<< newTagItem("标签标签标签标签")
            <<< newTagItem("标签")
            <<< newTagItem("标签标签")
            <<< newTagItem("标签")
            <<< newTagItem("标签标签")
            <<< newTagItem("标签标签标签")
            <<< newTagItem("标签")
            <<< newTagItem("标签标签标签标签标签")
        +++ Section("ButtonItem") { section in
            section.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
        }
            <<< ButtonItem("点击跳转(show)") { item in
                item.sendValue = "传值1"
                item.arrowType = .custom(UIImage(named: "arrow"), size: CGSize(width: 16, height: 16))
                /// 设置正常颜色
                item.titleColor = .black
//                item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
                /// 设置文字高亮颜色
                item.titleHighlightColor = .white
                /// 自动选择push和present
                item.presentationMode = .show(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.modalPresentationStyle = .fullScreen
                    vc.item = item
                    return vc
                }), onDismiss: { (vc) in
                    if vc.navigationController != nil {
                        vc.navigationController?.popViewController(animated: true)
                    } else {
                        vc.dismiss(animated: true)
                    }
                })
            }
            <<< ButtonItem("点击跳转(present)") { item in
                item.sendValue = "传值2"
                /// 指定present
                item.presentationMode = .presentModally(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.item = item
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonItem("点击跳转(popover)") {[weak self] item in
                item.sendValue = "传值3"
                /// 指定popover
                item.presentationMode = .popover(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.preferredContentSize = CGSize(width: 150, height: 150)
                    vc.modalPresentationStyle = .popover
                    // 必须实现delegate中的adaptivePresentationStyle方法***这里的self一定要用weak修饰，否则会造成循环引用***
                    if let weakSelf = self {
                        vc.popoverPresentationController?.delegate = weakSelf
                    }
                    vc.popoverPresentationController?.sourceView = item?.cell
                    vc.popoverPresentationController?.permittedArrowDirections = .any
                    vc.popoverPresentationController?.backgroundColor = .green
                    vc.item = item
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
        +++ Section(header:"LineItem(分割线)", footer: "分割线结束") { section in
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
        +++ Section("TitleValueItem") { section in
            section.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
            section.lineSpace = 10
            section.column = 1
//            section.decoration = SectionDecorationView<UICollectionReusableView> { view in
//                view.backgroundColor = .yellow
//            }
            section.header?.shouldSuspension = true
        }
                <<< TitleValueItem("title加上value"){ item in
                    item.verticalAlignment = .top
                    item.spaceBetweenTitleAndValue = 8
                    item.valueAlignment = .left
                    item.value = "这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value"
                }
                <<< TitleValueItem("标题样式") { item in
                    item.verticalAlignment = .top

                    item.titlePosition = .left
                    item.titleFont = UIFont.boldSystemFont(ofSize: 15)
                    item.titleColor = .darkText
                    item.titleAlignment = .center

                    item.valueColor = .blue
                    item.valueAlignment = .left
                    item.value = "value样式,然后这是一串比较长的字符串，我们看看能不能换行\n加个回车试试看"
                }
            <<< TitleValueItem("只有一串比较长的标题，试试看能不能正常的显示到充满，然后看看能不能自动换行, 四周的边距已设置为0") { item in
                item.verticalAlignment = .top
                item.contentInsets = .zero
            }
            <<< TitleValueItem("这也是一串比较长的标题，把上下间距设为零，设置固定宽度",tag: "DEFAULT_LABEL") { item in
                item.value = "标题与value都很长的时候，标题会挤压value的空间，因此需要给标题设置最大宽度，达到比较好的展示效果"
                item.titlePosition = .width(120)
            }
        
        +++ Section("SwitchItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
            <<< SwitchItem("设为默认") { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 5, right: 15)
                item.value = true
            }.onValueChanged({ (item) in
                /// 值改变的回调
                guard let TitleValueItem = item.section?.form?.firstItem(for: "DEFAULT_LABEL") as? TitleValueItem else {
                    return
                }
                if item.value {
                    TitleValueItem.titlePosition = .width(200)
                    TitleValueItem.value = "已设为默认"
                } else {
                    TitleValueItem.titlePosition = .left
                    TitleValueItem.title = "value清空了，可以改成自动宽度，整行都能显示title的值"
                    TitleValueItem.value = ""
                }
                TitleValueItem.updateCell()
            })
            <<< SwitchItem("自定义样式1") { item in
                item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
                item.switchOffBackgroundColor = .red
                item.switchOnBackgroundColor = .blue
                item.switchOffIndicatorColor = .yellow
                item.switchOnIndicatorColor = .orange
                item.switchOffText = "关"
                item.switchOnText = "开"
                item.switchOffIndicatorTextColor = .darkGray
                item.switchOnIndicatorTextColor = .white
            }
            <<< SwitchItem("自定义样式2") { item in
                item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
                item.switchOffBackgroundColor = .red
                item.switchOnBackgroundColor = .blue
                item.switchOffIndicatorColor = .yellow
                item.switchOnIndicatorColor = .orange
                item.switchOffIndicatorText = "关"
                item.switchOnIndicatorText = "开"
                item.switchOffIndicatorTextColor = .darkGray
                item.switchOnIndicatorTextColor = .white
            }
            
        +++ Section("TextFieldItem(输入框)") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< TextFieldItem("输入框:") { item in
                    item.placeHolder = "提示信息"
                    item.placeHolderColor = .red
                }
                <<< TextFieldItem("带边框的输入框:") { item in
                    item.boxInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                    item.inputAlignment = .left
                    item.placeHolder = "提示信息"
                    item.boxBorderWidth = 1.0
                    item.boxBorderColor = .green
                    item.boxHighlightBorderColor = .blue
                    item.boxBackgroundColor = .white
                    item.boxCornerRadius = 5
                }
                <<< TextFieldItem("回调限制输入:") { item in
                    item.placeHolder = "只能输入a(删除都不行)"
                    item.onTextShouldChange({ (item, textField, range, string) -> Bool in
                        return string == "a"
                    })
                }
                <<< TextFieldItem("限制输入长度") { item in
                    item.placeHolder = "最多能输入10个字"
                    item.limitWords = 10
                }
                <<< TextFieldItem("textField的各种回调") { item in
                    item.onTextDidChanged { (r, textField) in
                        print("输入值改变:\(textField.text ?? "")")
                    }
                    item.onTextFieldShouldReturn { (r, t) -> Bool in
                        /// 是否可以return
                        r.cell?.endEditing(true)
                        return true
                    }
                    item.onTextFieldShouldClearBlock { (r, t) -> Bool in
                        /// 是否可以清空
                        return true
                    }
                    item.onTextFieldDidEndEditing { (r, t) in
                        print("编辑完成")
                    }
                    item.onTextFieldDidBeginEditing { (r, t) in
                        print("开始编辑")
                    }
                }
            +++ Section("TextViewItem(多行输入框)") { section in
                section.lineSpace = 0
                section.column = 1
            }
            <<< TextViewItem("多行文本输入:\n(自动高度)") { item in
                item.placeholder = "最多100个"
                item.showLimit = true
                item.limitWords = 100
                item.inputBorderColor = .red
                item.inputBorderWidth = 1
                item.inputCornerRadius = 3
                item.boxBorderColor = .blue
                item.boxBorderWidth = 1
                item.boxCornerRadius = 5
                item.boxEditingBorderColor = .green
                item.boxPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                item.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                item.minHeight = 100
            }
            <<< TextViewItem("多行文本输入:\n(固定高度)") { item in
                item.placeholder = "不限制输入个数"
                item.showLimit = false
                item.inputBorderColor = .gray
                item.inputBorderWidth = 2
                item.inputCornerRadius = 3
                item.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                item.minHeight = 100
                item.autoHeight = false
            }
            <<< TextViewItem() { item in
                item.placeholder = "不带标题的输入框，不限制输入字数"
                item.showLimit = false
                item.inputBorderColor = .gray
                item.inputBorderWidth = 2
                item.inputCornerRadius = 3
                item.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                item.minHeight = 50
            }
            
            +++ Section("HtmlInfoItem") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< HtmlInfoItem() { item in
                    item.content = "HtmlInfoItem是用于展示Html代码字符串的Item，设置value为Html代码，即可展示\n展示出来后会自动调整高度，设置estimatedSize表示预估的size，会根据size的比例预先设置大小\n设置contentInsets可调整内容的四边间距"
                    item.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    /// 设置预估高度可以减少跳动
                    item.estimatedSize = CGSize(width: 100, height: 30)
                }
                <<< getHtmlImageItem(isFirst: true)
                <<< getHtmlImageItem()
                <<< getHtmlImageItem()
                <<< getHtmlImageItem()
                <<< getHtmlImageItem(isLast: true)
        
        +++ Section("ImageItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
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
                section >>>! (itemIndex ..< itemIndex + 1, [self.newImageItem(index, self.getNumberImage(Int.random(in: 10 ... 20)))])
            }
        }
//        for i in 0...30 {
//            towColumSection.append(newImageItem(i + 30, getRandomGif()))
//        }
        
        formlist.form +++ towColumSection

        let threeColumSection = Section(header: "自动大小三列图片", footer: "没啦！") { section in
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
//        
//        formlist.reloadData()
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

    /// 获取html图片item
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

    /// 获取随机图片
    func getRandomImage() -> String {
        let width:Int = Int.random(in: 1000 ... 2000)
        let height: Int = Int.random(in: 1000 ... 2000)
        return "https://picsum.photos/\(width)/\(height)"
    }


    /// html字符串
    func getHtmlImage() -> String {
        return "<img src = \"\(getNumberImage(Int.random(in: 0 ... numberImages.count)))\"/>"
    }
    
    /// 获取数字图片
    func getNumberImage(_ number: Int) -> String {
        return numberImages[number % numberImages.count]
    }
    
    /// 获取随机gif图片
    func getRandomGif() -> String {
        let index:Int = Int(arc4random() % UInt32(gifImages.count))
        return gifImages[index]
    }
    
    /// 数字图片
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
    
    /// gif图片
    let gifImages = [
        "http://hbimg.huabanimg.com/3fee54d0b2e0b7a132319a8e104f5fdc2edd3d35d03ee-93Jmdq_fw658",
        "http://5b0988e595225.cdn.sohucs.com/images/20180510/c861c0e9509546f98c25ef09419f1b81.gif",
        "https://img.zcool.cn/community/01b0d857b1a34d0000012e7e87f5eb.gif",
        "http://img.mp.sohu.com/upload/20170610/57fd225c09e04457a743253fa7191f85_th.png"
    ]
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
