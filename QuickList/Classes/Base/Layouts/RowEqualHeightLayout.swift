//
//  RowEqualHeightLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/11/22.
//

import Foundation

/// 多列布局，且行的所有元素都强制为最高的元素的高度
public class RowEqualHeightLayout: QuickListBaseLayout {
    public override init() {
        super.init()
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
        
        /// 列数
        let column = section.column
        /// 行间距
        let lineSpace = section.lineSpace
        /// 当前计算位置
        var tempStart = currentStart
        // 添加header的位置
        if let header = section.header {
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SectionReusableType.header.elementKind, with: IndexPath(item: 0, section: sectionIndex))
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
        let singleItemWidth: CGFloat = (itemTotalWidth - (section.column > 1 ? (section.itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
        let singleItemHeight: CGFloat = (itemTotalHeight - (section.column > 1 ? (section.itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
        /// 最后一行元素的结束偏移量
        var tempOffset: CGFloat = 0
        attribute.itemAttributes.removeAll()
        var currentRowMaxHeight: CGFloat = 0
        var rowAttrs: [UICollectionViewLayoutAttributes] = []
        var itemIndex: Int = 0
        var visibleLineCount: Int = 0
        for (index, item) in section.items.enumerated() {
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: sectionIndex))
            var itemSize: CGSize
            if layout.scrollDirection == .vertical {
                let itemEstSizeWidth = floor(singleItemWidth * CGFloat(item.weight) + (section.column > 1 ? section.itemSpace : 0) * CGFloat(item.weight - 1))
                if item.isHidden {
                    itemSize = CGSize(width: itemEstSizeWidth, height: 0)
                } else {
                    itemSize = item.representableItem()?.sizeForItem(item, with: CGSize(width: itemEstSizeWidth, height: itemEstSizeWidth), in: formView, layoutType: .vertical) ?? .zero
                }
                itemSize.height = ceil(itemSize.height)
                itemSize.width = ceil(itemEstSizeWidth)
            } else {
                let itemEstSizeHeight = floor(singleItemHeight * CGFloat(item.weight) + section.itemSpace * CGFloat(item.weight - 1))
                if item.isHidden {
                    itemSize = CGSize(width: 0, height: itemEstSizeHeight)
                } else {
                    itemSize = item.representableItem()?.sizeForItem(item, with: CGSize(width: itemEstSizeHeight, height: itemEstSizeHeight), in: formView, layoutType: .horizontal) ?? .zero
                }
                itemSize.width = ceil(itemSize.width)
                itemSize.height = ceil(itemEstSizeHeight)
            }
            var itemOffsetX: CGFloat = 0
            var itemOffsetY: CGFloat = 0
            
            if section.column <= item.weight {
                /// 填满整行
                if layout.scrollDirection == .vertical {
                    if !item.isHidden {
                        /// 如果上一个还未填满一行，换行
                        if itemIndex != 0 {
                            itemIndex = 0
                            rowAttrs.forEach({ $0.frame.size.height = currentRowMaxHeight })
                            tempOffset += currentRowMaxHeight + lineSpace
                            currentRowMaxHeight = 0
                            rowAttrs.removeAll()
                            visibleLineCount += 1
                        }
                    }
                    itemOffsetY = tempOffset
                    itemOffsetX = 0
                    if !item.isHidden {
                        /// 占用行/列的位置调整
                        tempOffset = itemOffsetY + lineSpace + itemSize.height
                        visibleLineCount += 1
                    }
                    itemSize.width = itemTotalWidth
                } else {
                    if !item.isHidden {
                        /// 如果上一个还未填满一行，换行
                        if itemIndex != 0 {
                            itemIndex = 0
                            rowAttrs.forEach({ $0.frame.size.width = currentRowMaxHeight })
                            tempOffset += currentRowMaxHeight + lineSpace
                            currentRowMaxHeight = 0
                            rowAttrs.removeAll()
                            visibleLineCount += 1
                        }
                    }
                    itemOffsetX = tempOffset
                    itemOffsetY = 0
                    if !item.isHidden {
                        /// 占用行/列的位置调整
                        tempOffset = itemOffsetX + lineSpace + itemSize.width
                        visibleLineCount += 1
                    }
                    itemSize.height = itemTotalHeight
                }
            } else {
                if itemIndex + item.weight > section.column {
                    if layout.scrollDirection == .vertical {
                        if !item.isHidden {
                            /// 没有足够的空间可以插入item，就换行
                            itemIndex = item.weight
                            rowAttrs.forEach({ $0.frame.size.height = currentRowMaxHeight })
                            tempOffset += currentRowMaxHeight + lineSpace
                            currentRowMaxHeight = itemSize.height
                            rowAttrs.removeAll()
                            visibleLineCount += 1
                            rowAttrs.append(attr)
                        }
                        itemOffsetY = tempOffset
                        itemOffsetX = 0
                    } else {
                        if !item.isHidden {
                            /// 没有足够的空间可以插入item，就换行
                            itemIndex = item.weight
                            rowAttrs.forEach({ $0.frame.size.width = currentRowMaxHeight })
                            tempOffset += currentRowMaxHeight + lineSpace
                            currentRowMaxHeight = itemSize.width
                            rowAttrs.removeAll()
                            visibleLineCount += 1
                            rowAttrs.append(attr)
                        }
                        itemOffsetX = tempOffset
                        itemOffsetY = 0
                    }
                } else {
                    if layout.scrollDirection == .vertical {
                        itemOffsetY = tempOffset
                        itemOffsetX = CGFloat(itemIndex) * (singleItemWidth + section.itemSpace)
                        currentRowMaxHeight = max(currentRowMaxHeight, itemSize.height)
                    } else {
                        itemOffsetX = tempOffset
                        itemOffsetY = CGFloat(itemIndex) * (singleItemHeight + section.itemSpace)
                        currentRowMaxHeight = max(currentRowMaxHeight, itemSize.width)
                    }
                    if !item.isHidden {
                        itemIndex += item.weight
                        rowAttrs.append(attr)
                    }
                }
            }
            
            attr.frame = CGRect(x: ceil(itemOffsetX + itemStartPoint.x), y: ceil(itemOffsetY + itemStartPoint.y), width: ceil(itemSize.width), height: ceil(itemSize.height))
            attr.alpha = item.isHidden ? 0 : 1
            attribute.itemAttributes.append(attr)
            if item.isSelected {
                attribute.selectedItemAttributes = attr
            }
        }
        
        if layout.scrollDirection == .vertical {
            if rowAttrs.count > 0 {
                /// 换行
                rowAttrs.forEach({ $0.frame.size.height = currentRowMaxHeight })
                tempOffset += currentRowMaxHeight + lineSpace
                currentRowMaxHeight = 0
                rowAttrs.removeAll()
                visibleLineCount += 1
            }
            tempStart.y += tempOffset + section.contentInset.bottom
            if visibleLineCount > 0 {
                tempStart.y -= lineSpace
            }
        } else {
            if rowAttrs.count > 0 {
                /// 换行
                rowAttrs.forEach({ $0.frame.size.width = currentRowMaxHeight })
                tempOffset += currentRowMaxHeight + lineSpace
                currentRowMaxHeight = 0
                rowAttrs.removeAll()
                visibleLineCount += 1
            }
            tempStart.x += tempOffset + section.contentInset.right
            if visibleLineCount > 0 {
                tempStart.x -= lineSpace
            }
        }
        
        // 添加footer的位置
        if let footer = section.footer {
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SectionReusableType.footer.elementKind, with: IndexPath(item: 0, section: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let footerHeight = footer.height(section, CGSize(width: maxWidth, height: maxWidth), layout.scrollDirection)
                frame = CGRect(x: formContentInset.left + sectionContentInset.left, y: tempStart.y, width: maxWidth, height: footerHeight)
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
        
        // 设置endPoint
        attribute.endPoint = tempStart
        
        /// 添加decoration的位置
        if section.decoration != nil {
            let decorationAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SectionReusableType.decoration.elementKind, with: IndexPath(index: sectionIndex))
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
        
        /// 添加suspensionDecoration的位置
        if section.isFormHeader, section.suspensionDecoration != nil {
            let decorationAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SectionReusableType.suspensionDecoration.elementKind, with: IndexPath(index: sectionIndex))
            var frame: CGRect = .zero
            if layout.scrollDirection == .vertical {
                let startY = attribute.headerAttributes?.frame.minX ?? attribute.startPoint.y
                let endY = attribute.footerAttributes?.frame.maxY ?? attribute.endPoint.y
                let startX = formContentInset.left
                let viewHeight = endY - startY
                frame = CGRect(x: startX, y: startY, width: maxWidth, height: viewHeight)
            } else {
                let startX = attribute.headerAttributes?.frame.minX ?? attribute.startPoint.x
                let endX = attribute.footerAttributes?.frame.maxY ?? attribute.endPoint.x
                let startY = formContentInset.top
                let viewWidth = endX - startX
                frame = CGRect(x: startX, y: startY, width: viewWidth, height: maxHeight)
            }
            decorationAttributes.frame = frame
            attribute.suspensionDecorationAttributes = decorationAttributes
        }
        return attribute
    }
}
