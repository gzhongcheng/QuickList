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
}
