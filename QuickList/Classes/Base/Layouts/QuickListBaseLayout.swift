//
//  QuickListBaseLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/9.
//

import Foundation

public class QuickListSectionAttribute: NSObject {
    /**
     * 悬停时展示的装饰位置
     * Decoration position when floating
     */
    public var suspensionDecorationAttributes: UICollectionViewLayoutAttributes?
    /**
     * 背景装饰位置
     * Background decoration position
     */
    public var decorationAttributes: UICollectionViewLayoutAttributes?
    /**
     * header位置
     * Header position
     */
    public var headerAttributes: UICollectionViewLayoutAttributes?
    /**
     * footer位置
     * Footer position
     */
    public var footerAttributes: UICollectionViewLayoutAttributes?
    /**
     * 存放item位置的数组
     * Array storing item positions
     */
    public var itemAttributes: [Item: UICollectionViewLayoutAttributes] = [:]
    /**
     * 存放当前选中item位置（仅在单选状态下有效）
     * Store current selected item position (only valid in single selection state)
     */
    public var selectedItemAttributes: UICollectionViewLayoutAttributes?
    
    /**
     * 是否为整个form的悬停header
     * Whether is the floating header of the entire form
     */
    public var isFormHeader: Bool = false
    
    /**
     * 是否需要悬停header
     * Whether needs floating header
     */
    public var shouldSuspensionHeader: Bool = false
    /**
     * 是否需要悬停footer
     * Whether needs floating footer
     */
    public var shouldSuspensionFooter: Bool = false
    
    public var startPoint: CGPoint = .zero
    public var endPoint: CGPoint = .zero

    public var itemsMaxWidth: CGFloat = 0
    public var itemsMaxHeight: CGFloat = 0
    public var singleItemWidth: CGFloat = 0
    public var singleItemHeight: CGFloat = 0
    
}

open class QuickListBaseLayout {
    var cacheAttrs: [Section: QuickListSectionAttribute] = [:]
    
    /**
     * layout获取布局对象
     * Layout gets layout object
     */
    func getAttsWithLayout(_ layout: QuickListCollectionLayout, section: Section, currentStart: CGPoint, isFirstSection: Bool) -> QuickListSectionAttribute {
        if section.isHidden {
            var sectionAttr = QuickListSectionAttribute()
            sectionAttr.startPoint = currentStart
            sectionAttr.endPoint = currentStart
            self.cacheAttrs[section] = sectionAttr
            return sectionAttr
        }
        
        let sectionAttr = self.layoutWith(layout: layout, section: section, currentStart: currentStart)
        section.needUpdateLayout = false
        self.cacheAttrs[section] = sectionAttr
        return sectionAttr
    }
    
    /**
     * 创建新的布局对象
     * Create new layout object
     */
    open func layoutWith(layout: QuickListCollectionLayout, section: Section, currentStart: CGPoint) -> QuickListSectionAttribute {
        #if DEBUG
        assertionFailure("Method must be override!")
        #endif
        return QuickListSectionAttribute()
    }
    
    /**
     * 添加Header的位置
     * Add Header position
     */
    func addHeaderAttributes(
        to attribute: QuickListSectionAttribute,
        layout: QuickListCollectionLayout,
        section: Section,
        sectionIndex: Int,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        formContentInset: UIEdgeInsets,
        tempStart: inout CGPoint
    ) {
        if let header = section.header {
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: QuickListReusableType.sectionHeader.elementKind, with: IndexPath(item: 0, section: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let headerHeight = header.height(section, CGSize(width: maxWidth, height: maxWidth), layout.scrollDirection)
                frame = CGRect(x: formContentInset.left, y: tempStart.y, width: maxWidth, height: headerHeight)
                tempStart.y += headerHeight
                tempStart.x = formContentInset.left
            } else {
                let headerWidth = header.height(section, CGSize(width: maxHeight, height: maxHeight), layout.scrollDirection)
                frame = CGRect(x: tempStart.x, y: formContentInset.top, width: headerWidth, height: maxHeight)
                tempStart.x += headerWidth
                tempStart.y = formContentInset.top
            }
            headerAttributes.frame = frame
            attribute.shouldSuspensionHeader = header.shouldSuspension
            attribute.headerAttributes = headerAttributes
        }
    }
    
    /**
     * 添加Footer的位置
     * Add Footer position
     */
    func addFooterAttributes(
        to attribute: QuickListSectionAttribute,
        layout: QuickListCollectionLayout,
        section: Section,
        sectionIndex: Int,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        formContentInset: UIEdgeInsets,
        tempStart: inout CGPoint
    ) {
        if let footer = section.footer {
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: QuickListReusableType.sectionFooter.elementKind, with: IndexPath(item: 0, section: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let footerHeight = footer.height(section, CGSize(width: maxWidth, height: maxWidth), layout.scrollDirection)
                frame = CGRect(x: formContentInset.left, y: tempStart.y, width: maxWidth, height: footerHeight)
                tempStart.y += footerHeight
            } else {
                let footerWidth = footer.height(section, CGSize(width: maxHeight, height: maxHeight), layout.scrollDirection)
                frame = CGRect(x: tempStart.x, y: formContentInset.top, width: footerWidth, height: maxHeight)
                tempStart.x += footerWidth
            }
            footerAttributes.frame = frame
            attribute.shouldSuspensionFooter = footer.shouldSuspension
            attribute.footerAttributes = footerAttributes
        }
    }
    
    /**
     * 添加decoration的位置
     * Add decoration position
     */
    func addDecorationAttributes(
        to attribute: QuickListSectionAttribute,
        layout: QuickListCollectionLayout,
        section: Section,
        sectionIndex: Int,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        formContentInset: UIEdgeInsets
    ) {
        if section.decoration != nil {
            let decorationAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: QuickListReusableType.decoration.elementKind, with: IndexPath(index: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let startY = attribute.headerAttributes?.frame.maxY ?? attribute.startPoint.y
                let endY = attribute.footerAttributes?.frame.minY ?? attribute.endPoint.y
                let startX = formContentInset.left
                let viewHeight = endY - startY
                frame = CGRect(x: startX, y: startY, width: maxWidth, height: viewHeight)
            } else {
                let startX = attribute.headerAttributes?.frame.maxX ?? attribute.startPoint.x
                let endX = attribute.footerAttributes?.frame.maxX ?? attribute.endPoint.x
                let startY = formContentInset.top
                let viewWidth = endX - startX
                frame = CGRect(x: startX, y: startY, width: viewWidth, height: maxHeight)
            }
            decorationAttributes.frame = frame
            attribute.decorationAttributes = decorationAttributes
        }
    }
    
    /**
     * 添加suspensionDecoration的布局属性
     * Add suspensionDecoration layout attributes
     */
    func addSuspensionDecorationAttributes(
        to attribute: QuickListSectionAttribute,
        layout: QuickListCollectionLayout,
        section: Section,
        sectionIndex: Int,
        currentStart: CGPoint,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        formContentInset: UIEdgeInsets
    ) {
        if section.isFormHeader, section.suspensionDecoration != nil {
            let decorationAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: QuickListReusableType.suspensionDecoration.elementKind, with: IndexPath(index: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let startY = attribute.headerAttributes?.frame.minY ?? attribute.startPoint.y
                let endY = attribute.footerAttributes?.frame.maxY ?? attribute.endPoint.y
                let startX = formContentInset.left
                let viewHeight = endY - startY
                frame = CGRect(x: startX, y: startY, width: maxWidth, height: viewHeight)
            } else {
                let startX = attribute.headerAttributes?.frame.minX ?? attribute.startPoint.x
                let endX = attribute.footerAttributes?.frame.maxX ?? attribute.endPoint.x
                let startY = formContentInset.top
                let viewWidth = endX - startX
                frame = CGRect(x: startX, y: startY, width: viewWidth, height: maxHeight)
            }
            decorationAttributes.frame = frame
            attribute.suspensionDecorationAttributes = decorationAttributes
        }
    }
    
    /**
     * 计算当其他item都收起时，剩余item的frame
     * Calculate the frame of remaining items when all other items are folded
     */
    open func calculateItemsFrameWhenOthersFolded(items: [Item], at section: Section) -> [Item: CGRect] {
        assertionFailure("Method must be override!")
        return [:]
    }
}
