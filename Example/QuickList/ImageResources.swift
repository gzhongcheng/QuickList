//
//  ImageResources.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/8/27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import QuickList

/**
 * 方便Demo使用，直接用了全局方法，实际项目中不要这么用
 * Convenient for Demo use, directly used global methods, do not use this in actual projects
 */

/**
 * 创建图片item
 * Create a new image item
 */
func newImageItem(_ index: Int, _ url: String,_ autoSize: Bool = false) -> ImageItem {
    return ImageItem(tag: "\(index + 1)") { item in
        item.imageUrl = url
        item.corners = [.leftTop(10),.rightBottom(15)] // CornerType.all(5)
        item.autoSize = autoSize
        item.aspectRatio = CGSize(width: 1, height: 1)
//            item.contentMode = .center
        item.loadFaildImage = UIImage(named: "load_faild")
        item.loadingIndicatorType = .activity
    }
}

/**
 * 创建标签item
 * Create a new tag item
 */
func newTagItem(_ title: String) -> TitleValueItem {
    return TitleValueItem(title) { item in
        item.value = "x"
        item.valueColor = .black
        item.spaceBetweenTitleAndValue = 15
        item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
        item.titleHighlightColor = .white
        item.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
        item.onCellSelection { item in
//            if item.value == "x" {
//                item.section?.hideAllItems(withOut: [item], inAnimation: ListReloadAnimation.transform, outAnimation: ListReloadAnimation.scale)
//                item.value = "o"
//            } else {
//                item.section?.showAllItems(inAnimation: ListReloadAnimation.scale, outAnimation: ListReloadAnimation.scale)
//                item.value = "x"
//            }
            guard let section = item.section else { return }
            section.replaceItems(with: [tagFlodItem()], inAnimation: .leftSlide, outAnimation: .rightSlide)
        }
    }
}

func tagFlodItem() -> TitleValueItem {
    return TitleValueItem("Open") { item in
        item.value = "o"
        item.valueColor = .black
        item.spaceBetweenTitleAndValue = 15
        item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
        item.titleHighlightColor = .white
        item.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
    }.onCellSelection { item in
        guard let section = item.section else { return }
        section.replaceItems(with: [
            newTagItem("Tag"),
            newTagItem("Tag Tag"),
            newTagItem("Tag Tag Tag Tag Tag"),
            newTagItem("Tag"),
            newTagItem("Tag Tag"),
            newTagItem("Tag"),
            newTagItem("Tag Tag"),
            newTagItem("Tag Tag Tag Tag"),
            newTagItem("Tag"),
            newTagItem("Tag Tag Tag Tag Tag Tag Tag")
        ], inAnimation: .rightSlide, outAnimation: .leftSlide)
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
