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
        // Do any additional setup after loading the view, typically from a nib.
        
        /**
         * 支持两种方式创建（直接扔配置进去和后面再添加cell）
         * Support two ways to create (throw configuration in and add cells later)
         */
        // MARK: - Set sections directly in initialization
//        let formlist = QuickListView(sections: [
//            Section(
//                "Auto Wrap",
//                items: [
//                    ButtonItem("Jump (show)") { item in
//                        item.sendValue = "Value 1"
//                        /// Set corner radius to half of height
//                        item.cornerScale = 0.5
//                        /// Set border width
//                        item.borderWidth = 1
//                        /// Set normal color
//                        item.titleColor = .black
//                        item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
//                        item.borderColor = UIColor(white: 0.5, alpha: 1.0)
//                        /// Set highlight color
//                        item.titleHighlightColor = .white
//                        item.highlightContentBgColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
//                        item.highlightBorderColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
//                        /// Automatically select push and present
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
        self.view.addSubview(formlist)
        
        /// Callback for content size change
//        formlist.listSizeChangedBlock = { newSize in
//            formlist.snp.remakeConstraints { make in
//                make.leading.top.trailing.equalToSuperview()
//                make.height.equalTo(min(self.view.bounds.height, newSize.height))
//            }
//        }
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
        formHeader.shouldSuspension = false
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
        formHeader.displayType = .normal
        formlist.form.header = formHeader
        
//        formlist.form.footer = FormDecorationView<UICollectionReusableView> { view in
//            view.backgroundColor = .yellow
//        }
//        formlist.form.footer?.height = { _,_,_ in
//            return 40
//        }
        
        
        let formFooter = FormCompressibleDecorationView<CompressibleHeaderView>()
        /**
         * 设置悬浮
         * Set suspension
         */
        formFooter.shouldSuspension = false
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
        formFooter.displayType = .normal

        formlist.form.footer = formFooter
        
        // MARK: - Add sections after creation
//        let swipItemSection = Section("Test Swipe") { section in
//            section.column = 2
//            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//            section.lineSpace = 10
//            section.itemSpace = 10
//        }
//        for i in 0 ... 30 {
//            swipItemSection <<< TestSwipeItem("Swipe Delete \(i)") { item in
//                item.swipedActionButtons = [
//                    SwipeActionButton(icon: UIImage(named: "icon_delete"), backgroundColor: .red, touchUpInside: { [weak item] in
//                        item?.removeFromSection()
//                    }),
//                    SwipeActionButton(title: "Favorite", backgroundColor: .black),
//                    SwipeActionButton(icon: UIImage(named: "icon_info"), title: "More", backgroundColor: .lightGray)
//                ]
//                item.autoTriggerFirstButton = true
//            }
//        }
//        formlist.form +++ swipItemSection
        
        formlist.form +++ Section(header: "Automatic Wrap", footer: nil) { section in
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
//            section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
//            section.layout = QuickListFlowLayout()
             section.layout = RowEqualHeightLayout()
//            section.isFormHeader = true
        }
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("Tag Tag Tag Tag Tag")
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag")
            <<< newTagItem("Tag Tag Tag Tag")
            <<< newTagItem("Tag")
            <<< newTagItem("Tag Tag Tag Tag Tag Tag Tag")
        +++ Section("ButtonItem") { section in
            section.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
        }
            <<< ButtonItem("Jump (show)") { item in
                item.sendValue = "Value 1"
                item.arrowType = .custom(UIImage(named: "arrow"), size: CGSize(width: 16, height: 16))
                /**
                 * 设置正常颜色
                 * Set normal color
                 */
                item.titleColor = .black
//                item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
                /**
                 * 设置文字高亮颜色
                 * Set text highlight color
                 */
                item.titleHighlightColor = .white
                /**
                 * 自动选择push和present
                 * Automatically select push and present
                 */
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
            <<< ButtonItem("Jump (present)") { item in
                item.sendValue = "Value 2"
                /**
                 * 指定present
                 * Specify present
                 */
                item.presentationMode = .presentModally(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.item = item
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonItem("Jump (popover)") {[weak self] item in
                item.sendValue = "Value 3"
                /**
                 * 指定popover
                 * Specify popover
                 */
                item.presentationMode = .popover(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.preferredContentSize = CGSize(width: 150, height: 150)
                    vc.modalPresentationStyle = .popover
                    /**
                     * 必须实现delegate中的adaptivePresentationStyle方法***这里的self一定要用weak修饰，否则会造成循环引用***
                     * Must implement the adaptivePresentationStyle method in the delegate***weak self must be used here, otherwise it will cause circular references***
                     */
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
        +++ Section(header:"LineItem(Line)", footer: "Line End") { section in
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
                <<< TitleValueItem("Title + Value"){ item in
                    item.verticalAlignment = .top
                    item.spaceBetweenTitleAndValue = 8
                    item.valueAlignment = .left
                    item.value = "This is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value"
                }
                <<< TitleValueItem("Title Style") { item in
                    item.verticalAlignment = .top

                    item.titlePosition = .left
                    item.titleFont = UIFont.boldSystemFont(ofSize: 15)
                    item.titleColor = .darkText
                    item.titleAlignment = .center

                    item.valueColor = .blue
                    item.valueAlignment = .left
                    item.value = "This is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value, this is value"
                }
            <<< TitleValueItem("A very long title, see if it can display normally, then see if it can automatically wrap, the四周的边距已设置为0") { item in
                item.verticalAlignment = .top
                item.contentInsets = .zero
            }
            <<< TitleValueItem("This is a very long title, set the top and bottom spacing to 0, and set a fixed width",tag: "DEFAULT_LABEL") { item in
                item.value = "When the title and value are both very long, the title will squeeze the space of the value, therefore, the title needs to be set to the maximum width, in order to achieve a better display效果"
                item.titlePosition = .width(120)
            }
        
        +++ Section("SwitchItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
            <<< SwitchItem("Set as Default") { item in
                item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 5, right: 15)
                item.value = true
            }.onValueChanged({ (item) in
                /**
                 * 值改变的回调
                 * Value changed callback
                 */
                guard let TitleValueItem = item.section?.form?.firstItem(for: "DEFAULT_LABEL") as? TitleValueItem else {
                    return
                }
                if item.value {
                    TitleValueItem.titlePosition = .width(200)
                    TitleValueItem.value = "Set as Default"
                } else {
                    TitleValueItem.titlePosition = .left
                    TitleValueItem.title = "Value is cleared, can be changed to automatic width, the entire line can display the value of the title"
                    TitleValueItem.value = ""
                }
                TitleValueItem.updateCell()
            })
            <<< SwitchItem("Custom Style 1") { item in
                item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
                item.switchOffBackgroundColor = .red
                item.switchOnBackgroundColor = .blue
                item.switchOffIndicatorColor = .yellow
                item.switchOnIndicatorColor = .orange
                item.switchOffText = "Off"
                item.switchOnText = "On"
                item.switchOffIndicatorTextColor = .darkGray
                item.switchOnIndicatorTextColor = .white
            }
            <<< SwitchItem("Custom Style 2") { item in
                item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
                item.switchOffBackgroundColor = .red
                item.switchOnBackgroundColor = .blue
                item.switchOffIndicatorColor = .yellow
                item.switchOnIndicatorColor = .orange
                item.switchOffIndicatorText = "Off"
                item.switchOnIndicatorText = "On"
                item.switchOffIndicatorTextColor = .darkGray
                item.switchOnIndicatorTextColor = .white
            }
        +++ Section("TextFieldItem(Text Field)") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< TextFieldItem("Text Field:") { item in
                    item.placeHolder = "Placeholder"
                    item.placeHolderColor = .red
                }
                <<< TextFieldItem("Text Field with Border:") { item in
                    item.boxInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                    item.inputAlignment = .left
                    item.placeHolder = "Placeholder"
                    item.boxBorderWidth = 1.0
                    item.boxBorderColor = .green
                    item.boxHighlightBorderColor = .blue
                    item.boxBackgroundColor = .white
                    item.boxCornerRadius = 5
                }
                <<< TextFieldItem("Callback to limit input:") { item in
                    item.placeHolder = "Only input a(delete is not allowed)"
                    item.onTextShouldChange({ (item, textField, range, string) -> Bool in
                        return string == "a"
                    })
                }
                <<< TextFieldItem("Limit input length") { item in
                    item.placeHolder = "Can input up to 10 characters"
                    item.limitWords = 10
                }
                <<< TextFieldItem("All callbacks of textField") { item in
                    item.onTextDidChanged { (r, textField) in
                        print("Value changed:\(textField.text ?? "")")
                    }
                    item.onTextFieldShouldReturn { (r, t) -> Bool in
                        /// Whether to return
                        r.cell?.endEditing(true)
                        return true
                    }
                    item.onTextFieldShouldClearBlock { (r, t) -> Bool in
                        /// Whether to clear
                        return true
                    }
                    item.onTextFieldDidEndEditing { (r, t) in
                        print("Editing completed")
                    }
                    item.onTextFieldDidBeginEditing { (r, t) in
                        print("Editing started")
                    }
                }
        +++ Section("TextViewItem(Multi-line Input Field)") { section in
            section.lineSpace = 0
            section.column = 1
        }
            <<< TextViewItem("Multi-line text input:\n(Automatic height)") { item in
                item.placeholder = "Can input up to 100 characters"
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
            <<< TextViewItem("Multi-line text input:\n(Fixed height)") { item in
                item.placeholder = "No limit on input count"
                item.showLimit = false
                item.inputBorderColor = .gray
                item.inputBorderWidth = 2
                item.inputCornerRadius = 3
                item.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                item.minHeight = 100
                item.autoHeight = false
            }
            <<< TextViewItem() { item in
                item.placeholder = "Input field without title, no limit on input characters"
                item.showLimit = false
                item.inputBorderColor = .gray
                item.inputBorderWidth = 2
                item.inputCornerRadius = 3
                item.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                item.minHeight = 50
            }
        /**
         * HtmlInfoItem可能会导致滚动时卡顿跳动，使用前请谨慎考虑
         * HtmlInfoItem may cause scrolling to stutter and jump, use with caution before use
         */
//        +++ Section("HtmlInfoItem") { section in
//            section.lineSpace = 0
//            section.column = 1
//        }
//                <<< HtmlInfoItem() { item in
//                    item.content = "HtmlInfoItem is used to display the Html code string, set value to Html code, and it can be displayed\nAfter it is displayed, the height will be automatically adjusted, set estimatedSize to represent the estimated size, and the size will be set in advance according to the ratio of the size\nSet contentInsets to adjust the four-side spacing of the content"
//                    item.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//                    /// Set estimated height to reduce jumping
//                    item.estimatedSize = CGSize(width: 100, height: 30)
//                }
//                <<< getHtmlImageItem(isFirst: true)
//                <<< getHtmlImageItem()
//                <<< getHtmlImageItem()
//                <<< getHtmlImageItem()
//                <<< getHtmlImageItem(isLast: true)
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
//                section <<<! self.newImageItem(index, self.getNumberImage(index))
                section >>>! (itemIndex ..< itemIndex + 1, [newImageItem(i + 30, getRandomGif())])
            }
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

        /**
        * 数据更新需要刷新时，可手动调用reload接口
        * When data needs to be updated, the reload interface can be manually called
        */
//        formlist.reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
