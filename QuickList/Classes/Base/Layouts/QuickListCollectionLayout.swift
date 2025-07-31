//
//  QuickListCollectionLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/9.
//

import Foundation

public enum QuickListDataChangeType {
    case all
    case appendSection
    case insetSection
    case appendCell
    case deleteSection
    case changeSection
    case appendSections
}

extension UICollectionViewLayoutAttributes {
    private struct AssociatedKey {
        @UniqueAddress static var caculatedFrameIdentifier
    }
    
    /// 计算得到的初始位置
    public var caculatedFrame: CGRect? {
        get {
            return objc_getAssociatedObject(self, AssociatedKey.caculatedFrameIdentifier) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.caculatedFrameIdentifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

public class QuickListCollectionLayout: UICollectionViewLayout {
    /// 滚动方向
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    /// 是否需要更新全部布局
    public var needReloadAll: Bool = true
    /// 数据from
    public var form: Form? {
        didSet {
            resetData()
        }
    }
    
    /// 更新类型
    var dataChangeType: QuickListDataChangeType = .all
    /// 存放各section位置等数据的数组
    var sectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /// 存放各section位置等数据的数组
    var oldSectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /// 计算中的中间量，用于定位各个section的开始位置
    var currentOffset: CGPoint = .zero
    /// 布局完成回调
    var didFinishLayout: ((_ layout: QuickListCollectionLayout) -> Void)?
    
    func reloadAll() {
        reloadSectionsAfter(index: 0)
    }
    
    func reloadSectionsAfter(index: Int, needOldSectionAttributes: Bool = false) {
        //前一段布局改变后，会影响其后的所有布局，该段后面的都要刷新
        guard let form = self.form else {
            return
        }
        
        oldSectionAttributes.removeAll()
        if needOldSectionAttributes {
            sectionAttributes.forEach { (k, v) in
                oldSectionAttributes[k] = v
            }
        }
        
        if index == 0 {
            resetData()
        } else {
            for (i, attr) in self.sectionAttributes {
                if i < index {
                    continue
                }
                if i == index {
                    self.currentOffset = attr.startPoint
                    continue
                }
                self.sectionAttributes[i] = nil
            }
        }
        
        for i in index ..< form.sections.count {
            let section = form.sections[i]
            self.addSection(section: section, isFirst: i == index)
        }
        
        /// 取最大位置设置
        if let maxPoint = sectionAttributes.values.max(by: { section1, section2 in
            if self.scrollDirection == .horizontal {
                return section1.endPoint.x < section2.endPoint.x
            }
            return section1.endPoint.y < section2.endPoint.y
        })?.endPoint {
            currentOffset = maxPoint
        }
        
        if form.needCenterIfNotFull {
            if scrollDirection == .vertical {
                if currentOffset.y < form.delegate?.formView?.bounds.height ?? 0 {
                    /// 如果内容高度小于视图高度，居中显示
                    /// 计算内容需要偏移的位置
                    let offsetY = ((form.delegate?.formView?.bounds.height ?? 0) - currentOffset.y) * 0.5
                    /// 设置所有内容偏移
                    for section in sectionAttributes.values {
                        section.startPoint.y += offsetY
                        section.endPoint.y += offsetY
                        section.headerAttributes?.frame.origin.y += offsetY
                        section.footerAttributes?.frame.origin.y += offsetY
                        section.itemAttributes.forEach { $0.frame.origin.y += offsetY }
                        section.decorationAttributes?.frame.origin.y += offsetY
                        section.suspensionDecorationAttributes?.frame.origin.y += offsetY
                    }
                }
            } else {
                if currentOffset.x < form.delegate?.formView?.bounds.width ?? 0 {
                    /// 如果内容宽度小于视图宽度，居中显示
                    /// 计算内容需要偏移的位置
                    let offsetX = ((form.delegate?.formView?.bounds.width ?? 0) - currentOffset.x) * 0.5
                    /// 设置所有内容偏移
                    for section in sectionAttributes.values {
                        section.startPoint.x += offsetX
                        section.endPoint.x += offsetX
                        section.headerAttributes?.frame.origin.x += offsetX
                        section.footerAttributes?.frame.origin.x += offsetX
                        section.itemAttributes.forEach { $0.frame.origin.x += offsetX }
                        section.decorationAttributes?.frame.origin.x += offsetX
                        section.suspensionDecorationAttributes?.frame.origin.x += offsetX
                    }
                }
            }
        }
        
        if
            self.form?.selectedItemDecoration != nil,
            let handler = self.form?.delegate as? FormViewHandler
        {
            DispatchQueue.main.async {
                handler.updateSelectedItemDecorationIfNeeded()
            }
        }
        
        if
            self.form?.backgroundDecoration != nil,
            let handler = self.form?.delegate as? FormViewHandler
        {
            DispatchQueue.main.async {
                handler.updateBackgroundDecoration()
            }
        }
        
        needReloadAll = true
        invalidateLayout()
        didFinishLayout?(self)
    }
    
    func resetData() {
        sectionAttributes = [:]
        if self.scrollDirection == .vertical {
            currentOffset = CGPoint(x: 0, y: form?.contentInset.top ?? 0)
        } else {
            currentOffset = CGPoint(x: form?.contentInset.left ?? 0, y: 0)
        }
    }
    
    public override func prepare() {
        super.prepare()
        if needReloadAll {
            self.invalidateLayout()
            if self.scrollDirection == .horizontal {
                guard
                    collectionView?.bounds.size.height ?? 0 > 0
                else {
                    print("collectionview的尺寸为0，不进行布局")
                    return
                }
            } else {
                guard
                    collectionView?.bounds.size.width ?? 0 > 0
                else {
                    print("collectionview的尺寸为0，不进行布局")
                    return
                }
            }
            needReloadAll = false
            if sectionAttributes.count == 0 {
                reloadAll()
            }
        }
    }
    
    func addSection(section: Section, isFirst: Bool) {
        guard let sectionIndex = section.index else { return }
        
        let layoutExecute = { (layout: QuickListBaseLayout) in
            let sectionAttr = layout.getAttsWithLayout(self, section: section, currentStart: self.currentOffset, isFirstSection: isFirst)
            if sectionIndex == 0 {
                if section.isFormHeader {
                    if self.scrollDirection == .vertical {
                        self.collectionView?.suspensionStartPoint = CGPoint(x: 0, y: sectionAttr.endPoint.y)
                    } else {
                        self.collectionView?.suspensionStartPoint = CGPoint(x: sectionAttr.endPoint.x, y: 0)
                    }
                    /// 记录初始位置
                    sectionAttr.headerAttributes?.caculatedFrame = sectionAttr.headerAttributes?.frame
                    sectionAttr.footerAttributes?.caculatedFrame = sectionAttr.footerAttributes?.frame
                    sectionAttr.decorationAttributes?.caculatedFrame = sectionAttr.decorationAttributes?.frame
                    sectionAttr.suspensionDecorationAttributes?.caculatedFrame = sectionAttr.suspensionDecorationAttributes?.frame
                    sectionAttr.itemAttributes.forEach { $0.caculatedFrame = $0.frame }
                } else {
                    self.collectionView?.suspensionStartPoint = nil
                    sectionAttr.headerAttributes?.zIndex = 502
                    sectionAttr.footerAttributes?.zIndex = 501
                    sectionAttr.decorationAttributes?.zIndex = 498
                    sectionAttr.itemAttributes.forEach { $0.zIndex = 500 }
                }
                sectionAttr.isFormHeader = section.isFormHeader
            } else {
                sectionAttr.isFormHeader = false
                sectionAttr.headerAttributes?.zIndex = 502
                sectionAttr.footerAttributes?.zIndex = 501
                sectionAttr.decorationAttributes?.zIndex = 498
                sectionAttr.itemAttributes.forEach { $0.zIndex = 500 }
            }
            self.sectionAttributes[sectionIndex] = sectionAttr
            guard sectionAttr.endPoint != .zero else {
                return
            }
            self.currentOffset = CGPoint(x: sectionAttr.startPoint.x, y: sectionAttr.endPoint.y)
        }
        
        if let sectionLayout = section.layout {
            layoutExecute(sectionLayout)
        } else if let formLayout = form?.layout {
            layoutExecute(formLayout)
        } else {
            layoutExecute(QuickListFlowLayout())
        }
    }
    
    /// 获取范围内的元素位置数组
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let formView = self.form?.delegate?.formView else { return nil }
        var rect = rect
        if rect.size.width < 1 {
            rect = CGRect(x: rect.minX, y: rect.minY, width: formView.bounds.width, height: rect.height)
        }
        if rect.size.height < 1 {
            rect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: formView.bounds.height)
        }
        /// 向两侧扩展一些距离
        switch scrollDirection {
        case .vertical:
            rect.origin.y -= 50
            rect.size.height += 100
        case .horizontal:
            rect.origin.x -= 50
            rect.size.width += 100
        @unknown default:
            break
        }
        /// 获取位置数组
        var resultAttrs: [UICollectionViewLayoutAttributes] = []
        for sectionAttr in sectionAttributes.values {
            /// 添加item位置
            resultAttrs.append(contentsOf: sectionAttr.layoutAttributesForElements(in: rect, for: formView, scrollDirection: self.scrollDirection) ?? [])
            
            /// 如果有装饰view，也需要悬浮
            if
                sectionAttr.isFormHeader,
                let selectedItemDecoration = form?.selectedItemDecoration,
                selectedItemDecoration.alpha == 1
            {
                var indexPath: IndexPath?
                for section in form?.sections ?? [] {
                    for item in section.items {
                        if item.isSelected {
                            indexPath = item.indexPath
                            break
                        }
                    }
                }
                if 
                    let indexPath = indexPath,
                    let selectedItemAttributes = sectionAttr.itemAttributes.first(where: { $0.indexPath == indexPath })
                {
                    selectedItemDecoration.frame = selectedItemAttributes.frame
                    selectedItemDecoration.layer.zPosition = form?.selectedItemDecorationPosition == .below ? 1023 : 1025
                } else {
                    selectedItemDecoration.layer.zPosition = form?.selectedItemDecorationPosition == .below ? 499 : 501
                }
            }
        }
        
        return resultAttrs
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = sectionAttributes[sectionIndex],
            indexPath.row < section.itemAttributes.count
        else {
            return nil
        }
        return section.itemAttributes[indexPath.row]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = sectionAttributes[sectionIndex]
        else {
            return nil
        }
        if elementKind == SectionReusableType.header.elementKind {
            return section.headerAttributes
        }
        if elementKind == SectionReusableType.footer.elementKind {
            return section.footerAttributes
        }
        if elementKind == SectionReusableType.decoration.elementKind {
            return section.decorationAttributes
        }
        if elementKind == SectionReusableType.suspensionDecoration.elementKind {
            return section.suspensionDecorationAttributes
        }
        return nil
    }
    
    public func initialLayoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = oldSectionAttributes[sectionIndex],
            indexPath.row < section.itemAttributes.count
        else {
            return nil
        }
        return section.itemAttributes[indexPath.row]
    }
    
    public func initialLayoutAttributesForElement(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = sectionAttributes[sectionIndex]
        else {
            return nil
        }
        if elementKind == SectionReusableType.header.elementKind {
            return section.headerAttributes
        }
        if elementKind == SectionReusableType.footer.elementKind {
            return section.footerAttributes
        }
        if elementKind == SectionReusableType.decoration.elementKind {
            return section.decorationAttributes
        }
        if elementKind == SectionReusableType.suspensionDecoration.elementKind {
            return section.suspensionDecorationAttributes
        }
        return nil
    }
    
    public override var collectionViewContentSize: CGSize {
        switch scrollDirection {
        case .horizontal:
            return CGSize(
                width: currentOffset.x + (form?.contentInset.right ?? 0),
                height: max(currentOffset.y, self.form?.delegate?.formView?.bounds.height ?? 0)
            )
        case .vertical:
            return CGSize(
                width: max(currentOffset.x, self.form?.delegate?.formView?.bounds.width ?? 0),
                height: currentOffset.y + (form?.contentInset.bottom ?? 0)
            )
        @unknown default:
            return CGSize(
                width: max(currentOffset.x, self.form?.delegate?.formView?.bounds.width ?? 0),
                height: max(currentOffset.y, self.form?.delegate?.formView?.bounds.height ?? 0)
            )
        }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        for section in sectionAttributes.values {
            if section.isFormHeader {
                /// 如果是表单头部，始终需要重新布局
                return true
            }
            if section.shouldSuspensionHeader || section.shouldSuspensionFooter {
                return true
            }
        }
        return false
    }
}

// MARK: - QuickListSectionAttribute位置获取扩展
extension QuickListSectionAttribute {
    /// 获取指定范围内的attribute数组
    func layoutAttributesForElements(in rect: CGRect, for view: FormViewProtocol, scrollDirection: UICollectionView.ScrollDirection) -> [UICollectionViewLayoutAttributes]? {
        var resultAttrs: [UICollectionViewLayoutAttributes] = []
        var sectionArea: CGRect
        if scrollDirection == .vertical {
            sectionArea = CGRect(x: startPoint.x, y: startPoint.y, width: view.bounds.width, height: endPoint.y - startPoint.y)
        } else {
            sectionArea = CGRect(x: startPoint.x, y: startPoint.y, width: endPoint.x - startPoint.x, height: view.bounds.height)
        }
        if self.isFormHeader {
            /// 设置整个section悬停
            if var headerAttributes = self.headerAttributes {
                suspensionAttributes(&headerAttributes, zIndex: 1026, for: view, with: scrollDirection)
                resultAttrs.append(headerAttributes)
            }
            if var footerAttributes = self.footerAttributes {
                suspensionAttributes(&footerAttributes, zIndex: 1026, for: view, with: scrollDirection)
                resultAttrs.append(footerAttributes)
            }
            for itemAttr in self.itemAttributes {
                var itemAttr = itemAttr
                suspensionAttributes(&itemAttr, zIndex: 1024, for: view, with: scrollDirection)
                resultAttrs.append(itemAttr)
            }
            if var decorationAttributes = self.decorationAttributes {
                suspensionAttributes(&decorationAttributes, zIndex: 1022, for: view, with: scrollDirection)
                resultAttrs.append(decorationAttributes)
            }
            if var suspensionDecorationAttributes = self.suspensionDecorationAttributes {
                suspensionAttributes(&suspensionDecorationAttributes, zIndex: 1021, for: view, with: scrollDirection)
                suspensionDecorationAttributes.alpha = view.contentOffset.y > 0 ? 1 : 0
                resultAttrs.append(suspensionDecorationAttributes)
            }
        } else if rect.intersects(sectionArea) {
            if var headerAttributes = self.headerAttributes, rect.intersects(headerAttributes.frame) {
                if self.shouldSuspensionHeader {
                    suspensionHeaderAttributes(&headerAttributes, for: view, with: scrollDirection)
                    resultAttrs.append(headerAttributes)
                } else if rect.intersects(headerAttributes.frame) {
                    headerAttributes.zIndex = 503
                    resultAttrs.append(headerAttributes)
                }
            }
            if var footerAttributes = self.footerAttributes, rect.intersects(footerAttributes.frame) {
                if self.shouldSuspensionFooter {
                    suspensionFooterAttributes(&footerAttributes, for: view, with: scrollDirection)
                    resultAttrs.append(footerAttributes)
                } else if rect.intersects(footerAttributes.frame) {
                    footerAttributes.zIndex = 502
                    resultAttrs.append(footerAttributes)
                }
            }
            for itemAttr in self.itemAttributes {
                if rect.intersects(itemAttr.frame) {
                    itemAttr.zIndex = 500
                    resultAttrs.append(itemAttr)
                }
            }
            if let decorationAttributes = self.decorationAttributes {
                decorationAttributes.zIndex = 498
                resultAttrs.append(decorationAttributes)
            }
        }
        return resultAttrs
    }
    
    /// 设置整个section悬停
    func suspensionAttributes(_ attributes: inout UICollectionViewLayoutAttributes, zIndex: Int, for view: FormViewProtocol, with scrollDirection: UICollectionView.ScrollDirection) {
        if scrollDirection == .vertical {
            var frame = attributes.caculatedFrame ?? attributes.frame
            frame.origin.y += view.contentOffset.y
            attributes.frame = frame
        } else {
            var frame = attributes.caculatedFrame ?? attributes.frame
            frame.origin.x += view.contentOffset.y
            attributes.frame = frame
        }
        attributes.zIndex = zIndex
    }
    
    /// 设置header悬停
    func suspensionHeaderAttributes(_ headerAttributes: inout UICollectionViewLayoutAttributes, for view: FormViewProtocol, with scrollDirection: UICollectionView.ScrollDirection) {
        var offset = view.contentOffset
        if let suspensionStartPoint = view.suspensionStartPoint {
            offset.x += suspensionStartPoint.x
            offset.y += suspensionStartPoint.y
        }
        /// 还没有滚动到需要悬停的位置，直接返回原始的frame
        if scrollDirection == .vertical, startPoint.y >= offset.y  {
            var frame = headerAttributes.frame
            frame.origin.y = startPoint.y
            headerAttributes.frame = frame
            return
        }
        if scrollDirection == .horizontal, startPoint.x >= offset.x  {
            var frame = headerAttributes.frame
            frame.origin.x = startPoint.x
            headerAttributes.frame = frame
            return
        }
        /// 下一个元素的位置
        var nextAttrPosition: CGPoint = endPoint
        if let footerStartPoint = footerAttributes?.frame.origin {
            nextAttrPosition = footerStartPoint
        }
        /// 已经滚动到下一个，直接跳过
        if scrollDirection == .vertical, offset.y > nextAttrPosition.y {
            return
        }
        if scrollDirection == .horizontal, offset.x > nextAttrPosition.x {
            return
        }
        /// 设置header悬浮位置
        if scrollDirection == .vertical {
            let width: CGFloat = headerAttributes.frame.width
            let height: CGFloat = headerAttributes.frame.height
            let x: CGFloat = headerAttributes.frame.minX
            let offsetY = offset.y
            var y = offsetY
            let next = nextAttrPosition.y
            if
                next - offsetY < height
            {
                y = next - height
            }
            headerAttributes.frame = CGRect(x: x, y: y, width: width, height: height)
            headerAttributes.zIndex = 1020
        } else {
            let width: CGFloat = headerAttributes.frame.width
            let height: CGFloat = headerAttributes.frame.height
            let y: CGFloat = headerAttributes.frame.minY
            let offsetX = offset.x
            var x = offsetX
            let next = nextAttrPosition.x
            if
                next - offsetX < width
            {
                x = next - width
            }
            headerAttributes.frame = CGRect(x: x, y: y, width: width, height: height)
            headerAttributes.zIndex = 1020
        }
    }
    
    /// 设置footer悬停
    func suspensionFooterAttributes(_ footerAttributes: inout UICollectionViewLayoutAttributes, for view: FormViewProtocol, with scrollDirection: UICollectionView.ScrollDirection) {
        var offset = view.contentOffset
        if let suspensionStartPoint = view.suspensionStartPoint {
            offset.x += suspensionStartPoint.x
            offset.y += suspensionStartPoint.y
        }
        /// 还没有滚动到需要悬停的位置，直接返回原始的frame
        if scrollDirection == .vertical, endPoint.y < offset.y + view.bounds.height  {
            var frame = footerAttributes.frame
            frame.origin.y = endPoint.y - footerAttributes.size.height
            footerAttributes.frame = frame
            return
        }
        if scrollDirection == .horizontal, endPoint.x < offset.x + view.bounds.width  {
            var frame = footerAttributes.frame
            frame.origin.x = endPoint.x - footerAttributes.size.width
            footerAttributes.frame = frame
            return
        }
        /// 上一个元素的位置
        var lastAttrPosition: CGPoint = startPoint
        if let headerFrame = self.headerAttributes?.frame {
            lastAttrPosition = CGPoint(x: headerFrame.maxX, y: headerFrame.maxY)
        } else
        /// 已经滚动到上一个section，跳过
        if scrollDirection == .vertical, lastAttrPosition.y > offset.y + view.bounds.height {
            return
        }
        if scrollDirection == .horizontal, lastAttrPosition.x > offset.x + view.bounds.width {
            return
        }
        /// 设置footer悬浮位置
        if scrollDirection == .vertical {
            let width = footerAttributes.frame.width
            let height = footerAttributes.frame.height
            let x: CGFloat = footerAttributes.frame.minX
            let offsetY = offset.y + view.bounds.height
            var y = offsetY - height
            let last = lastAttrPosition.y
            if
                offsetY - last < height
            {
                y = last
            }
            footerAttributes.frame = CGRect(x: x, y: y, width: width, height: height)
            footerAttributes.zIndex = 1020
        } else {
            let width = footerAttributes.frame.width
            let height = footerAttributes.frame.height
            let y: CGFloat = footerAttributes.frame.minY
            let offsetX = offset.x + view.bounds.width
            var x = offsetX - width
            let last = lastAttrPosition.x
            if
                offsetX - last < width
            {
                x = last
            }
            footerAttributes.frame = CGRect(x: x, y: y, width: width, height: height)
            footerAttributes.zIndex = 1020
        }
    }
}
