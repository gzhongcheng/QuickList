//
//  QuickYogaLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/19.
//

import Foundation

/// 标签式布局
public class QuickYogaLayout: QuickListBaseLayout {
    /// 行内滚动轴方向的排序方式
    public enum LineAlignment {
        /// 左对齐/上对齐
        case flexStart
        /// 居中对齐
        case center
        /// 右对齐/下对齐
        case flexEnd
    }
    
    /// 垂直于滚动轴方向的排列方式
    public enum AxisAlignment {
        /// 左对齐/上对齐
        case flexStart
        /// 居中对齐
        case center
        /// 右对齐/下对齐
        case flexEnd
        /// 充满并等分剩余间距
        case fillEqualSpacing
    }
    
    /// 垂直于滚动轴方向的排列方式
    public var alignment: AxisAlignment = .center
    /// 行内滚动轴方向的排序方式
    public var lineAlignment: LineAlignment = .center
    
    public init(alignment: AxisAlignment, lineAlignment: LineAlignment) {
        self.alignment = alignment
        self.lineAlignment = lineAlignment
    }
    
    public override func layoutWith(layout: QuickListCollectionLayout, section: Section, currentStart: CGPoint) -> QuickListSectionAttribute {
        let attribute = QuickListSectionAttribute()
        guard
            let formView = section.form?.delegate?.formView,
            let form = section.form,
            let sectionIndex = section.index
        else { return attribute }
        
        let formContentInset = form.contentInset
        let sectionContentInset = section.contentInset
        
        let maxWidth = formView.bounds.width - formContentInset.left - formContentInset.right
        let maxHeight = formView.bounds.height - formContentInset.top - formContentInset.bottom
        
        if layout.scrollDirection == .horizontal, maxHeight <= 0 {
            return attribute
        }
        if layout.scrollDirection == .vertical, maxWidth <= 0 {
            return attribute
        }
        
        // 设置startPoint
        attribute.startPoint = currentStart
        
        /// 当前计算位置
        var tempStart = currentStart
        // 添加header的位置
        addHeaderAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset, tempStart: &tempStart)
        
        /// item展示区域起点
        let itemStartPoint = CGPoint(x: tempStart.x + sectionContentInset.left, y: tempStart.y + sectionContentInset.top)
        if layout.scrollDirection == .vertical {
            tempStart.y += sectionContentInset.top
        } else {
            tempStart.x += sectionContentInset.left
        }
        // 添加每个元素的位置
        /// 展示范围
        let itemTotalWidth = maxWidth - sectionContentInset.left - sectionContentInset.right
        let itemTotalHeight = maxHeight - sectionContentInset.top - sectionContentInset.bottom
        
        var itemOffsetX: CGFloat = itemStartPoint.x
        var itemOffsetY: CGFloat = itemStartPoint.y
        /// 缓存每一行的位置，换行时根据排序方式动态调整位置
        var lineItemAttrs: [UICollectionViewLayoutAttributes] = []
        attribute.itemAttributes.removeAll()
        var visibleLineCount: Int = 0
        for (index, item) in section.items.enumerated() {
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: sectionIndex))
            var itemSize: CGSize
            if layout.scrollDirection == .vertical {
                if item.isHidden {
                    itemSize = .zero
                    attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                } else {
                    itemSize = item.representableItem()?.sizeForItem(item, with: CGSize(width: itemTotalWidth, height: itemTotalWidth), in: formView, layoutType: .free) ?? .zero
                    if itemOffsetX + itemSize.width > itemTotalWidth {
                        // 超出尺寸，需要换行后再设置位置
                        alignVItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalWidth: itemTotalWidth, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        itemOffsetX += itemSize.width + section.itemSpace
                        lineItemAttrs.append(attr)
                        visibleLineCount += 1
                    } else if itemOffsetX + itemSize.width == itemTotalWidth {
                        /// 尺寸刚好，设置完位置直接换行
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        lineItemAttrs.append(attr)
                        alignVItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalWidth: itemTotalWidth, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
                        visibleLineCount += 1
                    } else {
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        itemOffsetX += itemSize.width + section.itemSpace
                        lineItemAttrs.append(attr)
                    }
                }
                itemSize.height = ceil(itemSize.height)
            } else {
                if item.isHidden {
                    itemSize = .zero
                    attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                } else {
                    itemSize = item.representableItem()?.sizeForItem(item, with: CGSize(width: itemTotalHeight, height: itemTotalHeight), in: formView, layoutType: .free) ?? .zero
                    if itemOffsetY + itemSize.height > itemTotalHeight {
                        // 超出尺寸，需要换行后再设置位置
                        alignHItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalHeight: itemTotalHeight, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        lineItemAttrs.append(attr)
                        visibleLineCount += 1
                    } else if itemOffsetY + itemSize.height == itemTotalHeight {
                        /// 尺寸刚好，设置完位置直接换行
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        lineItemAttrs.append(attr)
                        alignHItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalHeight: itemTotalHeight, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
                        visibleLineCount += 1
                    } else {
                        attr.frame = CGRect(x: itemOffsetX, y: itemOffsetY, width: itemSize.width, height: itemSize.height)
                        itemOffsetY += itemSize.height + section.itemSpace
                        lineItemAttrs.append(attr)
                    }
                }
                itemSize.width = ceil(itemSize.width)
            }
            attr.alpha = item.isHidden ? 0 : 1
            attribute.itemAttributes.append(attr)
            if item.isSelected {
                attribute.selectedItemAttributes = attr
            }
        }
        
        if layout.scrollDirection == .vertical {
            /// 排序最后一行
            alignVItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalWidth: itemTotalWidth, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
            tempStart.y = itemOffsetY + section.contentInset.bottom
            if visibleLineCount > 0 {
                tempStart.y -= section.lineSpace
            }
        } else {
            /// 排序最后一行
            alignHItemsAttribute(itemStartPoint: itemStartPoint, lineItemAttrs: &lineItemAttrs, itemTotalHeight: itemTotalHeight, itemOffsetX: &itemOffsetX, itemOffsetY: &itemOffsetY, lineSpace: section.lineSpace)
            tempStart.x = itemOffsetX + section.contentInset.right
            if visibleLineCount > 0 {
                tempStart.x -= section.lineSpace
            }
        }
        
        // 添加footer的位置
        addFooterAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset, tempStart: &tempStart)
        
        // 设置endPoint
        attribute.endPoint = tempStart
        
        /// 添加decoration的位置
        addDecorationAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset)
        
        /// 添加suspensionDecoration的位置
        addSuspensionDecorationAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, currentStart: currentStart, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset)
        
        return attribute
    }
    
    // MARK: 按对齐方式布局的逻辑
    private func alignVItemsAttribute(itemStartPoint: CGPoint, lineItemAttrs: inout [UICollectionViewLayoutAttributes], itemTotalWidth: CGFloat, itemOffsetX: inout CGFloat, itemOffsetY: inout CGFloat, lineSpace: CGFloat) {
        guard !lineItemAttrs.isEmpty else { return }
        /// 按照设定的排序方式调整x的位置
        let lineItemTotalWidth = lineItemAttrs.last!.frame.maxX
        switch alignment {
        case .flexStart:
            break
        case .center:
            let moveX = (itemTotalWidth - lineItemTotalWidth) * 0.5
            lineItemAttrs.forEach({ $0.frame.origin.x += moveX })
        case .flexEnd:
            let moveX = itemTotalWidth - lineItemTotalWidth
            lineItemAttrs.forEach({ $0.frame.origin.x += moveX })
        case .fillEqualSpacing:
            let spaceAddX = lineItemAttrs.count > 1 ? (itemTotalWidth - lineItemTotalWidth) / CGFloat(lineItemAttrs.count - 1) : 0
            for (index, item) in lineItemAttrs.enumerated() {
                item.frame.origin.x += spaceAddX * CGFloat(index)
            }
        }
        /// 按照设定的排序方式调整y的位置
        /// 缓存当前行的起点位置
        let tempOffsetY: CGFloat = itemOffsetY
        /// 计算当前行的终点位置
        var maxOffsetY: CGFloat = itemOffsetY
        for itemAttribute in lineItemAttrs {
            maxOffsetY = max(itemAttribute.frame.maxY, maxOffsetY)
        }
        let lineHeight = maxOffsetY - tempOffsetY
        switch lineAlignment {
        case .flexStart:
            break
        case .center:
            lineItemAttrs.forEach { attr in
                attr.frame.origin.y += (lineHeight - attr.frame.size.height) * 0.5
            }
        case .flexEnd:
            lineItemAttrs.forEach { attr in
                attr.frame.origin.y += lineHeight - attr.frame.size.height
            }
        }
        /// 换行
        lineItemAttrs.removeAll()
        itemOffsetX = itemStartPoint.x
        itemOffsetY = maxOffsetY + lineSpace
    }
    
    private func alignHItemsAttribute(itemStartPoint: CGPoint, lineItemAttrs: inout [UICollectionViewLayoutAttributes], itemTotalHeight: CGFloat, itemOffsetX: inout CGFloat, itemOffsetY: inout CGFloat, lineSpace: CGFloat) {
        guard !lineItemAttrs.isEmpty else { return }
        /// 按照设定的排序方式调整y的位置
        let lineItemTotalHeight = lineItemAttrs.last!.frame.maxY
        switch alignment {
        case .flexStart:
            break
        case .center:
            let moveY = (itemTotalHeight - lineItemTotalHeight) * 0.5
            lineItemAttrs.forEach({ $0.frame.origin.y += moveY })
        case .flexEnd:
            let moveY = itemTotalHeight - lineItemTotalHeight
            lineItemAttrs.forEach({ $0.frame.origin.y += moveY })
        case .fillEqualSpacing:
            let spaceAddY = (itemTotalHeight - lineItemTotalHeight) / CGFloat(lineItemAttrs.count - 1)
            for (index, item) in lineItemAttrs.enumerated() {
                item.frame.origin.y += spaceAddY * CGFloat(index)
            }
        }
        /// 按照设定的排序方式调整x的位置
        /// 缓存当前行的起点位置
        let tempOffsetX: CGFloat = itemOffsetX
        /// 计算当前行的终点位置
        var maxOffsetX: CGFloat = itemOffsetX
        for itemAttribute in lineItemAttrs {
            maxOffsetX = max(itemAttribute.frame.maxX, maxOffsetX)
        }
        let lineHeight = maxOffsetX - tempOffsetX
        switch lineAlignment {
        case .flexStart:
            break
        case .center:
            lineItemAttrs.forEach { attr in
                attr.frame.origin.x += (lineHeight - attr.frame.size.width) * 0.5
            }
        case .flexEnd:
            lineItemAttrs.forEach { attr in
                attr.frame.origin.x += lineHeight - attr.frame.size.width
            }
        }
        /// 换行
        lineItemAttrs = []
        itemOffsetX = maxOffsetX + lineSpace
        itemOffsetY = itemStartPoint.y
    }
}
