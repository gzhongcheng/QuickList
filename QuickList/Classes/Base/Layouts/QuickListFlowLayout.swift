//
//  QuickListFlowLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/16.
//

import Foundation

/**
 * 瀑布流布局
 * Waterfall layout
 */
public class QuickListFlowLayout: QuickListBaseLayout {
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
        let maxHeight = formView.bounds.height - formContentInset.top - formContentInset.bottom - formView.adjustedContentInset.top - formView.adjustedContentInset.bottom
        
        if layout.scrollDirection == .horizontal, maxHeight <= 0 {
            return attribute
        }
        if layout.scrollDirection == .vertical, maxWidth <= 0 {
            return attribute
        }
        
        // 设置startPoint
        // Set startPoint
        attribute.startPoint = currentStart
        
        /**
         * 列数
         * Number of columns
         */
        let column = section.column
        /**
         * 行间距
         * Row spacing
         */
        let lineSpace = section.lineSpace
        /**
         * 当前计算位置
         * Current calculation position
         */
        var tempStart = currentStart
        // 添加header的位置
        // Add header position
        addHeaderAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset, tempStart: &tempStart)
        
        /**
         * item展示区域起点
         * Item display area starting point
         */
        let itemStartPoint = CGPoint(x: tempStart.x + sectionContentInset.left, y: tempStart.y + sectionContentInset.top)
        if layout.scrollDirection == .vertical {
            tempStart.y += sectionContentInset.top
        } else {
            tempStart.x += sectionContentInset.left
        }
        // 添加每个元素的位置
        // Add position for each element
        /**
         * 展示范围
         * Display range
         */
        let itemTotalWidth = maxWidth - sectionContentInset.left - sectionContentInset.right
        let itemTotalHeight = maxHeight - sectionContentInset.top - sectionContentInset.bottom
        let singleItemWidth: CGFloat = (itemTotalWidth - (column > 1 ? (section.itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
        let singleItemHeight: CGFloat = (itemTotalHeight - (column > 1 ? (section.itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
        /**
         * 每列的最后一个元素的结束偏移量（相对于itemStartPoint）
         * End offset of the last element in each column (relative to itemStartPoint)
         */
        var tempOffsets: [CGFloat] = (0..<column).map({ _ in 0 })
        var visibleLineCount: Int = 0
        attribute.itemAttributes.removeAll()
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
            var itemIndex: Int = 0
            
            if tempOffsets.count <= item.weight {
                /**
                 * 填满整行
                 * Fill entire row
                 */
                if layout.scrollDirection == .vertical {
                    itemOffsetY = tempOffsets.sorted().last!
                    itemOffsetX = 0
                    if !item.isHidden {
                        /**
                         * 占用行/列的位置调整
                         * Position adjustment for occupied rows/columns
                         */
                        for i in 0 ..< tempOffsets.count {
                            tempOffsets[i] = itemOffsetY + lineSpace + itemSize.height
                            visibleLineCount += 1
                        }
                    }
                    itemSize.width = itemTotalWidth
                } else {
                    itemOffsetX = tempOffsets.sorted().last!
                    itemOffsetY = 0
                    if !item.isHidden {
                        /**
                         * 占用行/列的位置调整
                         * Position adjustment for occupied rows/columns
                         */
                        for i in 0 ..< tempOffsets.count {
                            tempOffsets[i] = itemOffsetX + lineSpace + itemSize.width
                            visibleLineCount += 1
                        }
                    }
                    itemSize.height = itemTotalHeight
                }
            } else {
                /**
                 * 先记录最底部位置
                 * First record the bottommost position
                 */
                for (i, offset) in tempOffsets.enumerated() {
                    if layout.scrollDirection == .vertical {
                        if offset > itemOffsetY {
                            itemOffsetY = offset
                            itemIndex = i
                        }
                    } else {
                        if offset > itemOffsetX {
                            itemOffsetX = offset
                            itemIndex = i
                        }
                    }
                }
                
                var haveSpace: Bool = false
                /**
                 * 不填满整行
                 * Don't fill entire row
                 */
                for i in 0 ... tempOffsets.count - item.weight {
                    /**
                     * 找到当前位置对应的可以塞下的最低位置
                     * Find the lowest position that can fit at current position
                     */
                    var currentMaxOffset: CGFloat = 0
                    for j in 0 ..< item.weight {
                        currentMaxOffset = max(tempOffsets[i + j], currentMaxOffset)
                    }
                    if layout.scrollDirection == .vertical {
                        if currentMaxOffset < itemOffsetY {
                            itemOffsetY = currentMaxOffset
                            itemIndex = i
                            haveSpace = true
                        }
                    } else {
                        if currentMaxOffset < itemOffsetX {
                            itemOffsetX = currentMaxOffset
                            itemIndex = i
                            haveSpace = true
                        }
                    }
                }
                
                if !haveSpace {
                    /**
                     * 没有找到可以插入的位置，就从头开始占格子
                     * No suitable insertion position found, start occupying slots from the beginning
                     */
                    itemIndex = 0
                }
                
                if !item.isHidden {
                    /// 占用行/列的位置调整 | Position adjustment for occupied rows/columns
                    for i in itemIndex ..< itemIndex + item.weight {
                        if layout.scrollDirection == .vertical {
                            tempOffsets[i] = itemOffsetY + lineSpace + itemSize.height
                        } else {
                            tempOffsets[i] = itemOffsetX + lineSpace + itemSize.width
                        }
                        visibleLineCount += 1
                    }
                }
                if layout.scrollDirection == .vertical {
                    itemOffsetX = CGFloat(itemIndex) * (singleItemWidth + section.itemSpace)
                } else {
                    itemOffsetY = CGFloat(itemIndex) * (singleItemHeight + section.itemSpace)
                }
            }
            
            attr.frame = CGRect(x: itemOffsetX + itemStartPoint.x, y: itemOffsetY + itemStartPoint.y, width: itemSize.width, height: itemSize.height)
            attr.alpha = item.isHidden ? 0 : 1
            attribute.itemAttributes.append(attr)
            if item.isSelected {
                attribute.selectedItemAttributes = attr
            }
        }
        
        if layout.scrollDirection == .vertical {
            let totalItemsHeight = tempOffsets.sorted().last!
            tempStart.y += totalItemsHeight + section.contentInset.bottom
            if visibleLineCount > 0 {
                tempStart.y -= lineSpace
            }
        } else {
            let totalItemsWidth = tempOffsets.sorted().last!
            tempStart.x += totalItemsWidth + section.contentInset.right
            if visibleLineCount > 0 {
                tempStart.x -= lineSpace
            }
        }
        
        // 添加footer的位置
        // Add footer position
        addFooterAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset, tempStart: &tempStart)
        
        // 设置endPoint
        // Set endPoint
        attribute.endPoint = tempStart
        
        /**
         * 添加decoration的位置
         * Add decoration position
         */
        addDecorationAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset)
        
        /**
         * 添加suspensionDecoration的位置
         * Add suspensionDecoration position
         */
        addSuspensionDecorationAttributes(to: attribute, layout: layout, section: section, sectionIndex: sectionIndex, currentStart: currentStart, maxWidth: maxWidth, maxHeight: maxHeight, formContentInset: formContentInset)
        
        return attribute
    }
}
