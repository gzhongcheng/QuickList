//
//  QuickListBaseLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/9.
//

import Foundation

public class QuickListSectionAttribute: NSObject {
    /// 悬停时展示的装饰位置
    public var suspensionDecorationAttributes: UICollectionViewLayoutAttributes?
    /// 背景装饰位置
    public var decorationAttributes: UICollectionViewLayoutAttributes?
    /// header位置
    public var headerAttributes: UICollectionViewLayoutAttributes?
    /// footer位置
    public var footerAttributes: UICollectionViewLayoutAttributes?
    /// 存放item位置的数组
    public var itemAttributes: [UICollectionViewLayoutAttributes] = []
    /// 存放当前选中item位置（仅在单选状态下有效）
    public var selectedItemAttributes: UICollectionViewLayoutAttributes?
    
    /// 是否为整个form的悬停header
    public var isFormHeader: Bool = false
    
    /// 是否需要悬停header
    public var shouldSuspensionHeader: Bool = false
    /// 是否需要悬停footer
    public var shouldSuspensionFooter: Bool = false
    
    public var startPoint: CGPoint = .zero
    public var endPoint: CGPoint = .zero
}

open class QuickListBaseLayout {
    var needUpdate: Bool = true
    var cacheAttr: QuickListSectionAttribute = QuickListSectionAttribute()
    
    /// layout获取布局对象
    func getAttsWithLayout(_ layout: QuickListCollectionLayout, section: Section, currentStart: CGPoint, isFirstSection: Bool) -> QuickListSectionAttribute {
        let oldStart = cacheAttr.startPoint
        cacheAttr.startPoint = currentStart
        
        let calculateLayout = {
            return self.layoutWith(layout: layout, section: section, currentStart: currentStart)
        }
        
        let updateAttXY = {
            if self.needUpdate {
                return calculateLayout()
            }
            return self.update(with: CGPoint(x: currentStart.x - oldStart.x, y: currentStart.y - oldStart.y), start: currentStart, section: section)
        }
        
        let calculateOrUpdateXYOnly = {
            if isFirstSection || self.needUpdate {
                return calculateLayout()
            }
            return updateAttXY()
        }
        
        var sectionAttr = QuickListSectionAttribute()
        
        switch layout.dataChangeType {
        case .all:
            sectionAttr = calculateLayout()
        case .appendSection, .insetSection, .appendCell, .appendSections, .changeSection:
            sectionAttr = calculateOrUpdateXYOnly()
        case .deleteSection:
            sectionAttr = updateAttXY()
        }
        
        self.needUpdate = false
        self.cacheAttr = sectionAttr
        return self.cacheAttr
    }
    
    /// 创建新的布局对象
    open func layoutWith(layout: QuickListCollectionLayout, section: Section, currentStart: CGPoint) -> QuickListSectionAttribute {
        #if DEBUG
        assertionFailure("Method must be override!")
        #endif
        return QuickListSectionAttribute()
    }
    
    /// 仅需更新所有frame的x和y位置
    private func update(with offsetXY: CGPoint, start: CGPoint, section: Section) -> QuickListSectionAttribute {
        guard let sectionIndex = section.index else { return cacheAttr }
        /// 更新header、footer、items
        if let headerAttr = cacheAttr.headerAttributes {
            headerAttr.frame = moveXY(offsetXY: offsetXY, to: headerAttr.frame)
            headerAttr.indexPath = IndexPath(index: sectionIndex)
        }
        if let footerAttr = cacheAttr.headerAttributes {
            footerAttr.frame = moveXY(offsetXY: offsetXY, to: footerAttr.frame)
            footerAttr.indexPath = IndexPath(index: sectionIndex)
        }
        for itemAttr in cacheAttr.itemAttributes {
            itemAttr.frame = moveXY(offsetXY: offsetXY, to: itemAttr.frame)
            itemAttr.indexPath = IndexPath(item: itemAttr.indexPath.item, section: sectionIndex)
        }
        cacheAttr.endPoint = CGPoint(x: cacheAttr.endPoint.x + offsetXY.x, y: cacheAttr.endPoint.y + offsetXY.y)
        
        if let decorationAttr = cacheAttr.decorationAttributes {
            decorationAttr.frame = moveXY(offsetXY: offsetXY, to: decorationAttr.frame)
            decorationAttr.indexPath = IndexPath(index: sectionIndex)
        }
        if let decorationAttr = cacheAttr.suspensionDecorationAttributes {
            decorationAttr.frame = moveXY(offsetXY: offsetXY, to: decorationAttr.frame)
            decorationAttr.indexPath = IndexPath(index: sectionIndex)
        }
        
        return cacheAttr
    }
    
    private func moveXY(offsetXY: CGPoint, to frame: CGRect) -> CGRect {
        return CGRect(
            x: frame.minX + offsetXY.x,
            y: frame.minY + offsetXY.y,
            width: frame.width,
            height: frame.height
        )
    }
    
    /// 添加Header的位置
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
    
    /// 添加Footer的位置
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
    
    /// 添加decoration的位置
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
                let endX = attribute.footerAttributes?.frame.minY ?? attribute.endPoint.x
                let startY = formContentInset.top
                let viewWidth = endX - startX
                frame = CGRect(x: startX, y: startY, width: viewWidth, height: maxHeight)
            }
            decorationAttributes.frame = frame
            attribute.decorationAttributes = decorationAttributes
        }
    }
    
    /// 添加suspensionDecoration的布局属性
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
}
