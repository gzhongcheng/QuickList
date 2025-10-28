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
    
    /**
     * 计算得到的初始位置
     * Calculated initial position
     */
    public var caculatedFrame: CGRect? {
        get {
            return objc_getAssociatedObject(self, AssociatedKey.caculatedFrameIdentifier) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.caculatedFrameIdentifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension Array where Element == UICollectionViewLayoutAttributes {
    /**
     * 使用二分法找到rect范围内的一个itemAttr
     * Use binary search to find an itemAttr in the rect range
     */
    func binarySearch(frame: CGRect, in rect: CGRect, direction: UICollectionView.ScrollDirection) -> (Int, UICollectionViewLayoutAttributes)? {
        var left = 0
        var right = count - 1
        while left <= right {
            let mid = (left + right) / 2
            if self[mid].frame.intersects(rect) {
                return (mid, self[mid])
            }
            if direction == .vertical {
                if self[mid].frame.minY > frame.minY {
                    right = mid - 1
                } else {
                    left = mid + 1
                }
            } else {
                if self[mid].frame.minX > frame.minX {
                    right = mid - 1
                } else {
                    left = mid + 1
                }
            }
        }
        return nil
    }
}

public protocol QuickListCollectionLayoutDelegate: AnyObject {
    /**
     * 更新完成回调
     * Update completion callback
     */
    func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout)
}

public class QuickListCollectionLayout: UICollectionViewLayout {
    /**
     * 滚动方向
     * Scroll direction
     */
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    /**
     * 是否需要更新全部布局
     * Whether need to update all layout
     */
    public var needReloadAll: Bool = true
    /**
     * 数据from
     * Data from
     */
    public var form: Form? {
        didSet {
            resetData()
        }
    }
    
    /**
     * 更新类型
     * Update type
     */
    var dataChangeType: QuickListDataChangeType = .all
    /**
     * 整个form的Header和Footer的尺寸
     * Size of entire form's Header and Footer
     */
    var headerAttributes: UICollectionViewLayoutAttributes?
    var footerAttributes: UICollectionViewLayoutAttributes?
    /**
     * 悬浮headerSection的尺寸，用于支持isFormHeader，如果isFormHeader为false，则该值为nil
     * Floating headerSection size, used to support isFormHeader, if isFormHeader is false, this value is nil
     */
    var suspensionHeaderSectionSize: CGSize?
    /**
     * 存放各section位置等数据的数组
     * Array storing position data for each section
     */
    var sectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /**
     * 存放各section位置等数据的数组
     * Array storing position data for each section
     */
    var oldSectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /**
     * 计算中的中间量，用于定位各个section的开始位置
     * Intermediate variable in calculation, used to locate the starting position of each section
     */
    var currentOffset: CGPoint = .zero
    
    // MARK: - Multi-cast delegate
    private let multiDelegate: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    func add(_ delegate: QuickListCollectionLayoutDelegate) {
        multiDelegate.add(delegate)
    }
    
    func remove(_ delegate: QuickListCollectionLayoutDelegate) {
        invoke {
            if $0 === delegate as AnyObject {
                multiDelegate.remove($0)
            }
        }
    }
    
    /**
     * 通知布局完成
     * Notify layout completion
     */
    func noticeDidFinishLayout() {
        invoke {
            $0.collectionLayoutDidFinishLayout(self)
        }
    }
    
    private func invoke(_ invocation: (QuickListCollectionLayoutDelegate) -> Void) {
        for delegate in multiDelegate.allObjects.reversed() {
            invocation(delegate as! QuickListCollectionLayoutDelegate)
        }
    }
    
    // MARK: - Layout calculation
    func reloadAll() {
        reloadSectionsAfter(index: 0)
    }
    
    func reloadSectionsAfter(index: Int, needOldSectionAttributes: Bool = false) {
        /**
         * 前一段布局改变后，会影响其后的所有布局，该段后面的都要刷新
         * After the previous layout changes, it will affect all subsequent layouts, all sections after this need to be refreshed
         */
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
            /**
             * 计算整个列表的Header
             * Calculate the Header of the entire list
             */
            if
                let collectionView = self.collectionView,
                let header = form.header
            {
                headerAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: QuickListReusableType.formHeader.elementKind,
                    with: IndexPath(item: 0, section: 0)
                )
                var frame: CGRect = .zero
                if self.scrollDirection == .vertical {
                    let height = header.height(form, collectionView.bounds.size, self.scrollDirection)
                    frame = CGRect(x: 0, y: currentOffset.y, width: collectionView.bounds.width, height: height)
                    currentOffset.y += height
                } else {
                    let height = collectionView.bounds.size.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
                    let width = header.height(form, CGSize(width: collectionView.bounds.size.width, height: height), self.scrollDirection)
                    frame = CGRect(x: currentOffset.x, y: 0, width: width, height: height)
                    currentOffset.x += width
                }
                headerAttributes?.frame = frame
                headerAttributes?.caculatedFrame = frame
            }
            currentOffset.y += form.contentInset.top
            currentOffset.x += form.contentInset.left
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
        
        /**
         * 取最大位置设置
         * Take maximum position setting
         */
        if let maxPoint = sectionAttributes.values.max(by: { section1, section2 in
            if self.scrollDirection == .horizontal {
                return section1.endPoint.x < section2.endPoint.x
            }
            return section1.endPoint.y < section2.endPoint.y
        })?.endPoint {
            currentOffset = maxPoint
        }
        
        /**
         * 添加尾部间距
         * Add trailing spacing
         */
        if self.scrollDirection == .vertical {
            currentOffset.y += form.contentInset.bottom
        } else {
            currentOffset.x += form.contentInset.right
        }
        
        /**
         * 计算整个列表的Footer
         * Calculate the Footer of the entire list
         */
        if let collectionView = self.collectionView {
            if let footer = form.footer {
                footerAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: QuickListReusableType.formFooter.elementKind,
                    with: IndexPath(item: 0, section: 0)
                )
                var frame: CGRect = .zero
                if self.scrollDirection == .vertical {
                    let height = footer.height(form, collectionView.bounds.size, self.scrollDirection)
                    frame = CGRect(x: 0, y: currentOffset.y, width: collectionView.bounds.width, height: height)
                    currentOffset.y += height
                } else {
                    let height = collectionView.bounds.size.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
                    let width = footer.height(form, CGSize(width: collectionView.bounds.size.width, height: height), self.scrollDirection)
                    frame = CGRect(x: currentOffset.x, y: 0, width: width, height: height)
                    currentOffset.x += width
                }
                footerAttributes?.frame = frame
                footerAttributes?.caculatedFrame = frame
            }
        }
        
        if form.needCenterIfNotFull {
            if scrollDirection == .vertical {
                if currentOffset.y < form.delegate?.formView?.bounds.height ?? 0 {
                    /**
                     * 如果内容高度小于视图高度，居中显示
                     * If content height is less than view height, center display
                     */
                    /**
                     * 计算内容需要偏移的位置
                     * Calculate the offset position needed for content
                     */
                    let offsetY = ((form.delegate?.formView?.bounds.height ?? 0) - currentOffset.y) * 0.5
                    /**
                     * 设置所有内容偏移
                     * Set all content offset
                     */
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
                    /**
                     * 如果内容宽度小于视图宽度，居中显示
                     * If content width is less than view width, center display
                     */
                    /**
                     * 计算内容需要偏移的位置
                     * Calculate the offset position needed for content
                     */
                    let offsetX = ((form.delegate?.formView?.bounds.width ?? 0) - currentOffset.x) * 0.5
                    /**
                     * 设置所有内容偏移
                     * Set all content offset
                     */
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
            let handler = self.form?.delegate as? FormViewHandler
        {
            mainThread { [weak self] in
                guard let self = self else { return }
                let contentSize = self.collectionViewContentSize
                if self.form?.backgroundDecoration != nil {
                    handler.updateBackgroundDecoration(contentSize: contentSize)
                }
                if self.form?.selectedItemDecoration != nil {
                    handler.updateSelectedItemDecorationIfNeeded()
                }
            }
        }
        
        needReloadAll = true
        invalidateLayout()
        noticeDidFinishLayout()
    }
    
    func resetData() {
        sectionAttributes = [:]
        currentOffset = .zero
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
        guard
            let sectionIndex = section.index,
            let collectionView = self.collectionView as? QuickListView
        else { return }
        
        let layoutExecute = { (layout: QuickListBaseLayout) in
            let sectionAttr = layout.getAttsWithLayout(self, section: section, currentStart: self.currentOffset, isFirstSection: isFirst)
            if sectionIndex == 0 {
                if section.isFormHeader {
                    if self.scrollDirection == .vertical {
                        self.suspensionHeaderSectionSize = CGSize(width: collectionView.bounds.width, height: sectionAttr.endPoint.y - sectionAttr.startPoint.y)
                    } else {
                        self.suspensionHeaderSectionSize = CGSize(width: sectionAttr.endPoint.x - sectionAttr.startPoint.x, height: collectionView.bounds.height)
                    }
                    /**
                     * 记录初始位置
                     * Record initial position
                     */
                    sectionAttr.headerAttributes?.caculatedFrame = sectionAttr.headerAttributes?.frame
                    sectionAttr.footerAttributes?.caculatedFrame = sectionAttr.footerAttributes?.frame
                    sectionAttr.decorationAttributes?.caculatedFrame = sectionAttr.decorationAttributes?.frame
                    sectionAttr.suspensionDecorationAttributes?.caculatedFrame = sectionAttr.suspensionDecorationAttributes?.frame
                    sectionAttr.itemAttributes.forEach { $0.caculatedFrame = $0.frame }
                } else {
                    self.suspensionHeaderSectionSize = nil
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
            if self.scrollDirection == .vertical {
                self.currentOffset = CGPoint(x: sectionAttr.startPoint.x, y: sectionAttr.endPoint.y)
            } else {
                self.currentOffset = CGPoint(x: sectionAttr.endPoint.x, y: sectionAttr.startPoint.y)
            }
        }
        
        if let sectionLayout = section.layout {
            layoutExecute(sectionLayout)
        } else if let formLayout = form?.layout {
            layoutExecute(formLayout)
        } else {
            layoutExecute(QuickListFlowLayout())
        }
    }
    
    /**
     * 获取范围内的元素位置数组
     * Get array of element positions within range
     */
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let formView = self.form?.delegate?.formView else { return nil }
        var rect = rect
        if rect.size.width < 1 {
            rect = CGRect(x: rect.minX, y: rect.minY, width: formView.bounds.width, height: rect.height)
        }
        if rect.size.height < 1 {
            rect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: formView.bounds.height)
        }
        /**
         * 获取位置数组
         * Get position array
         */
        var resultAttrs: [UICollectionViewLayoutAttributes] = []
        /**
         * 整体的header和footer
         * Overall header and footer
         */
        var headerSize: CGSize = .zero
        var footerSize: CGSize = .zero
        var suspensionHeader: Bool = false
        var suspensionFooter: Bool = false
        if let header = form?.header {
            let (headerAttr, size) = getFormHeaderAttributes(header, for: formView, with: scrollDirection)
            if let headerAttr = headerAttr {
                resultAttrs.append(headerAttr)
                if let header = header as? FormCompressibleHeaderFooterReusable {
                    header.didChangeDispalySize(to: headerAttr.frame.size)
                }
            }
            headerSize = size
            suspensionHeader = header.shouldSuspension
        }
        if let footer = form?.footer {
            let (footerAttr, size) = getFormFooterAttributes(footer, for: formView, with: scrollDirection)
            if let footerAttr = footerAttr {
                resultAttrs.append(footerAttr)
                if let footer = footer as? FormCompressibleHeaderFooterReusable {
                    footer.didChangeDispalySize(to: footerAttr.frame.size)
                }
            }
            footerSize = size
            suspensionFooter = footer.shouldSuspension
        }
        
        for sectionAttr in sectionAttributes.values {
            /**
             * 添加item位置
             * Add item position
             */
            resultAttrs.append(contentsOf: sectionAttr.layoutAttributesForElements(
                in: rect,
                for: formView,
                headerSize: headerSize,
                suspensionHeader: suspensionHeader,
                suspensionHeaderSectionSize: self.suspensionHeaderSectionSize,
                footerSize: footerSize,
                suspensionFooter: suspensionFooter,
                scrollDirection: self.scrollDirection
            ) ?? [])
            
            /**
             * 如果有装饰view，也需要悬浮
             * If there are decoration views, they also need to float
             */
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
        print("layoutAttributesForElements returns \(resultAttrs.count)")
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
        if elementKind == QuickListReusableType.formHeader.elementKind {
            return headerAttributes
        }
        if elementKind == QuickListReusableType.formFooter.elementKind {
            return footerAttributes
        }
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = sectionAttributes[sectionIndex]
        else {
            return nil
        }
        if elementKind == QuickListReusableType.sectionHeader.elementKind {
            return section.headerAttributes
        }
        if elementKind == QuickListReusableType.sectionFooter.elementKind {
            return section.footerAttributes
        }
        if elementKind == QuickListReusableType.decoration.elementKind {
            return section.decorationAttributes
        }
        if elementKind == QuickListReusableType.suspensionDecoration.elementKind {
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
            let section = oldSectionAttributes[sectionIndex]
        else {
            return nil
        }
        if elementKind == QuickListReusableType.sectionHeader.elementKind {
            return section.headerAttributes
        }
        if elementKind == QuickListReusableType.sectionFooter.elementKind {
            return section.footerAttributes
        }
        if elementKind == QuickListReusableType.decoration.elementKind {
            return section.decorationAttributes
        }
        if elementKind == QuickListReusableType.suspensionDecoration.elementKind {
            return section.suspensionDecorationAttributes
        }
        return nil
    }
    
    public override var collectionViewContentSize: CGSize {
        switch scrollDirection {
        case .horizontal:
            guard let view = self.form?.delegate?.formView else {
                return .zero
            }
            return CGSize(
                width: currentOffset.x,
                height: max(currentOffset.y, view.bounds.height - view.adjustedContentInset.top - view.adjustedContentInset.bottom)
            )
        case .vertical:
            return CGSize(
                width: max(currentOffset.x, self.form?.delegate?.formView?.bounds.width ?? 0),
                height: currentOffset.y
            )
        @unknown default:
            return .zero
        }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if
            form?.header is FormCompressibleHeaderFooterReusable ||
            form?.footer is FormCompressibleHeaderFooterReusable ||
            form?.header?.shouldSuspension == true ||
            form?.footer?.shouldSuspension == true
        {
            /**
             * 如果有可压缩的header/footer，或者悬浮的header/footer，需要重新布局
             * If there are compressible header/footer or floating header/footer, need to relayout
             */
            return true
        }
        for section in sectionAttributes.values {
            if section.isFormHeader {
                /**
                 * 如果是表单头部，始终需要重新布局
                 * If it's form header, always need to relayout
                 */
                return true
            }
            if section.shouldSuspensionHeader || section.shouldSuspensionFooter {
                return true
            }
        }
        return false
    }
    
    func getFormHeaderAttributes(_ header: FormHeaderFooterReusable, for view: QuickListView, with scrollDirection: UICollectionView.ScrollDirection) -> (UICollectionViewLayoutAttributes?, CGSize) {
        guard let headerAttributes = headerAttributes else { return (nil, .zero) }
        var x: CGFloat = 0
        var y: CGFloat = 0
        var size: CGSize = headerAttributes.caculatedFrame?.size ?? headerAttributes.frame.size
        var inListSize: CGSize = size
        switch scrollDirection {
        case .vertical:
            let offset = view.contentOffset.y + view.adjustedContentInset.top
            if let header = header as? FormCompressibleHeaderFooterReusable {
                let newOffset = offset > 0 ? offset : 0
                if let minSize = header.minSize {
                    size = CGSize(width: view.bounds.width, height: max(size.height - newOffset , minSize.height))
                } else {
                    size = CGSize(width: view.bounds.width, height: size.height - newOffset)
                }
                if header.shouldSuspension {
                    /// 如果是悬浮header，返回压缩后的尺寸，非悬浮返回原始尺寸
                    inListSize = size
                } else if newOffset >= 0 {
                    /// 非悬浮且压缩时，需要往下偏移
                    if newOffset <= (inListSize.height - size.height) {
                        y += newOffset
                    } else {
                        y += (inListSize.height - size.height)
                    }
                }
            }
            switch header.displayType {
            case .stretch:
                if offset < 0 {
                    y += offset
                    size.height -= offset
                }
            case .top:
                if offset < 0 {
                    y = offset
                }
            default:
                break
            }
            if header.shouldSuspension {
                headerAttributes.zIndex = 1127
                if offset > 0 {
                    y += offset
                }
            } else {
                headerAttributes.zIndex = 600
            }
        case .horizontal:
            if let header = header as? FormCompressibleHeaderFooterReusable {
                let offset = view.contentOffset.x > 0 ? view.contentOffset.x : 0
                if let minSize = header.minSize {
                    size = CGSize(width: max(size.width - offset, minSize.width), height: size.height)
                } else {
                    size = CGSize(width: size.width - offset, height: size.height)
                }
                if header.shouldSuspension {
                    /// 如果是悬浮header，返回压缩后的尺寸，非悬浮返回原始尺寸
                    inListSize = size
                } else if offset > 0 {
                    /// 非悬浮且压缩时，需要往右偏移
                    if offset <= (inListSize.width - size.width) {
                        x += offset
                    } else {
                        x += (inListSize.width - size.width)
                    }
                }
            }
            switch header.displayType {
            case .stretch:
                if view.contentOffset.x < 0 {
                    x += view.contentOffset.x
                    size.width -= view.contentOffset.x
                }
            case .top:
                if view.contentOffset.x < 0 {
                    x = view.contentOffset.x
                }
            default:
                break
            }
            if header.shouldSuspension {
                headerAttributes.zIndex = 1127
                if view.contentOffset.x > 0 {
                    x += view.contentOffset.x
                }
            } else {
                headerAttributes.zIndex = 600
            }
        default:
            break
        }
        headerAttributes.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        return (headerAttributes, inListSize)
    }
    
    func getFormFooterAttributes(_ footer: FormHeaderFooterReusable, for view: QuickListView, with scrollDirection: UICollectionView.ScrollDirection) -> (UICollectionViewLayoutAttributes?, CGSize) {
        guard let footerAttributes = footerAttributes else { return (nil, .zero) }
        var x: CGFloat = footerAttributes.caculatedFrame?.minX ?? footerAttributes.frame.minX
        var y: CGFloat = footerAttributes.caculatedFrame?.minY ?? footerAttributes.frame.minY
        var size: CGSize = footerAttributes.caculatedFrame?.size ?? footerAttributes.frame.size
        var inListSize: CGSize = size
        switch scrollDirection {
        case .vertical:
            if let footer = footer as? FormCompressibleHeaderFooterReusable {
                var offset = view.contentSize.height - view.contentOffset.y - view.bounds.height
                offset = offset > 0 ? offset : 0
                if let minSize = footer.minSize {
                    size = CGSize(width: view.bounds.width, height: max(size.height - offset, minSize.height))
                } else {
                    size = CGSize(width: view.bounds.width, height: size.height - offset)
                }
            }
            inListSize = CGSize(width: size.width, height: size.height)
            switch footer.displayType {
            case .stretch:
                if view.contentOffset.y + view.bounds.height > view.contentSize.height {
                    size.height += view.contentOffset.y + view.bounds.height - view.contentSize.height
                }
            case .bottom:
                if view.contentOffset.y + view.bounds.height > view.contentSize.height {
                    y += view.contentOffset.y + view.bounds.height - view.contentSize.height
                }
            default:
                break
            }
            if footer.shouldSuspension {
                footerAttributes.zIndex = 1127
                if view.contentOffset.y < view.contentSize.height - view.bounds.height {
                    y = view.contentOffset.y + view.bounds.height - size.height
                }
            } else {
                footerAttributes.zIndex = 600
            }
        case .horizontal:
            if let footer = footer as? FormCompressibleHeaderFooterReusable {
                var offset = view.contentSize.width - view.contentOffset.x - view.bounds.width
                offset = offset > 0 ? offset : 0
                if let minSize = footer.minSize {
                    size = CGSize(width: max(size.width - offset, minSize.width), height: size.height)
                } else {
                    size = CGSize(width: size.width - offset, height: size.height)
                }
            }
            inListSize = CGSize(width: size.width, height: size.height)
            switch footer.displayType {
            case .stretch:
                if view.contentOffset.x + view.bounds.width > view.contentSize.width {
                    size.width += view.contentOffset.x + view.bounds.width - view.contentSize.width
                }
            case .bottom:
                if view.contentOffset.x + view.bounds.width > view.contentSize.width {
                    x += view.contentOffset.x + view.bounds.width - view.contentSize.width
                }
            default:
                break
            }
            if footer.shouldSuspension {
                footerAttributes.zIndex = 1127
                if view.contentOffset.x < view.contentSize.width - view.bounds.width {
                    x = view.contentOffset.x + view.bounds.width - size.width
                }
            } else {
                footerAttributes.zIndex = 600
            }
        default:
            break
        }
        footerAttributes.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        return (footerAttributes, inListSize)
    }
}

// MARK: - QuickListSectionAttribute position acquisition extension
extension QuickListSectionAttribute {
    /**
     * 获取section内所有元素的布局属性
     * Get layout attributes for all elements within section
     * - Parameters:
     *   - rect: 需要获取的范围 / Range to get
     *   - view: QuickListView实例 / QuickListView instance
     *   - headerSize: form header的尺寸 / form header size
     *   - suspensionHeader: 是否悬停form header / Whether form header is floating
     *   - suspensionHeaderSectionSize: 悬停的header section尺寸 / Floating header section size
     *   - footerSize: form footer的尺寸 / form footer size
     *   - suspensionFooter: 是否悬停form footer / Whether form footer is floating
     *   - scrollDirection: 滚动方向 / Scroll direction
     */
    func layoutAttributesForElements(
        in rect: CGRect,
        for view: QuickListView,
        headerSize: CGSize,
        suspensionHeader: Bool,
        suspensionHeaderSectionSize: CGSize?,
        footerSize: CGSize,
        suspensionFooter: Bool,
        scrollDirection: UICollectionView.ScrollDirection
    ) -> [UICollectionViewLayoutAttributes]? {
        var resultAttrs: [UICollectionViewLayoutAttributes] = []
        var sectionArea: CGRect
        if scrollDirection == .vertical {
            sectionArea = CGRect(x: startPoint.x, y: startPoint.y, width: view.bounds.width, height: endPoint.y - startPoint.y)
        } else {
            sectionArea = CGRect(x: startPoint.x, y: startPoint.y, width: endPoint.x - startPoint.x, height: view.bounds.height)
        }
        if self.isFormHeader {
            /**
             * 设置整个section悬停
             * Set entire section floating
             */
            if var headerAttributes = self.headerAttributes {
                suspensionAttributes(&headerAttributes, zIndex: 1026, for: view, headerSize: headerSize, with: scrollDirection)
                resultAttrs.append(headerAttributes)
            }
            if var footerAttributes = self.footerAttributes {
                suspensionAttributes(&footerAttributes, zIndex: 1026, for: view, headerSize: headerSize, with: scrollDirection)
                resultAttrs.append(footerAttributes)
            }
            for itemAttr in self.itemAttributes {
                var itemAttr = itemAttr
                suspensionAttributes(&itemAttr, zIndex: 1024, for: view, headerSize: headerSize, with: scrollDirection)
                resultAttrs.append(itemAttr)
            }
            if var decorationAttributes = self.decorationAttributes {
                suspensionAttributes(&decorationAttributes, zIndex: 1022, for: view, headerSize: headerSize, with: scrollDirection)
                resultAttrs.append(decorationAttributes)
            }
            if var suspensionDecorationAttributes = self.suspensionDecorationAttributes {
                suspensionAttributes(&suspensionDecorationAttributes, zIndex: 1021, for: view, headerSize: headerSize, with: scrollDirection)
                switch scrollDirection {
                case .horizontal:
                    suspensionDecorationAttributes.alpha = view.contentOffset.x > headerSize.width ? 1 : 0
                case .vertical:
                    suspensionDecorationAttributes.alpha = view.contentOffset.y > headerSize.height ? 1 : 0
                @unknown default:
                    break
                }
                resultAttrs.append(suspensionDecorationAttributes)
            }
        } else if rect.intersects(sectionArea) {
            if var headerAttributes = self.headerAttributes {
                if self.shouldSuspensionHeader {
                    suspensionHeaderAttributes(&headerAttributes, for: view, headerSize: headerSize, suspensionHeader: suspensionHeader, suspensionHeaderSectionSize: suspensionHeaderSectionSize, with: scrollDirection)
                    resultAttrs.append(headerAttributes)
                } else if rect.intersects(headerAttributes.frame) {
                    headerAttributes.zIndex = 503
                    resultAttrs.append(headerAttributes)
                }
            }
            if var footerAttributes = self.footerAttributes {
                if self.shouldSuspensionFooter {
                    suspensionFooterAttributes(&footerAttributes, for: view, footerSize: footerSize, suspensionFooter: suspensionFooter, with: scrollDirection)
                    resultAttrs.append(footerAttributes)
                } else if rect.intersects(footerAttributes.frame) {
                    footerAttributes.zIndex = 502
                    resultAttrs.append(footerAttributes)
                }
            }

            /** 
                * 使用二分法查找rect范围内的一个itemAttr
                * Use binary search to find itemAttr in the rect range
                */
            if let (index, itemAttr) = self.itemAttributes.binarySearch(frame: rect, in: rect, direction: scrollDirection) {
                itemAttr.zIndex = 500
                resultAttrs.append(itemAttr)

                let sectionColumnCount = self.column
                /**
                 * 从后往前反向遍历itemAttributes，直到遇到不在rect范围内的itemAttr，为排除瀑布流item高度不一导致可能出现中间某个itemAttr不在rect范围内，但前面的itemAttr在rect范围内的情况,需要遍历到整行的itemAttr都不在rect范围内为止
                 * Traverse itemAttributes from back to front, add to resultAttrs until an itemAttr that is not in the rect range is encountered, 
                 * to exclude the case where the itemAttr may not be in the rect range, but the previous itemAttr is in the rect range, due to the height of the waterfall item is not the same,
                 * the traversal needs to be continued until the itemAttr of the entire row is not in the rect range
                 */
                var currentOutRectCount: Int = 0
                for itemAttr in self.itemAttributes[..<index].reversed() {
                    if rect.intersects(itemAttr.frame) {
                        itemAttr.zIndex = 500
                        resultAttrs.append(itemAttr)
                        currentOutRectCount = 0
                    } else if currentOutRectCount < sectionColumnCount {
                        currentOutRectCount += 1
                    } else {
                        break
                    }
                }

                /**
                 * 从前往后遍历itemAttributes，直到遇到不在rect范围内的itemAttr，为排除瀑布流item高度不一导致可能出现中间某个itemAttr不在rect范围内，但后面的itemAttr在rect范围内的情况,需要遍历到整行的itemAttr都不在rect范围内为止
                 * Traverse itemAttributes from front to back, add to resultAttrs until an itemAttr that is not in the rect range is encountered
                 */
                currentOutRectCount = 0
                for itemAttr in self.itemAttributes[index...] {
                    if rect.intersects(itemAttr.frame) {
                        itemAttr.zIndex = 500
                        resultAttrs.append(itemAttr)
                        currentOutRectCount = 0
                    } else if currentOutRectCount < sectionColumnCount {
                        currentOutRectCount += 1
                    } else {
                        break
                    }
                }
            }

            if let decorationAttributes = self.decorationAttributes {
                decorationAttributes.zIndex = 498
                resultAttrs.append(decorationAttributes)
            }
        }
        return resultAttrs
    }
    
    /**
     * 设置整个section悬停
     * Set entire section floating
     * - Parameters:
     *   - attributes: 布局属性 / Layout attributes
     *   - zIndex: zIndex值 / zIndex value
     *   - view: QuickListView实例 / QuickListView instance
     *   - headerSize: form header的尺寸 / form header size
     *   - scrollDirection: 滚动方向 / Scroll direction
     */
    func suspensionAttributes(
        _ attributes: inout UICollectionViewLayoutAttributes,
        zIndex: Int,
        for view: QuickListView,
        headerSize: CGSize,
        with scrollDirection: UICollectionView.ScrollDirection
    ) {
        if scrollDirection == .vertical {
            let offset = view.contentOffset.y + view.adjustedContentInset.top
            var frame = attributes.caculatedFrame ?? attributes.frame
            if offset > headerSize.height {
                /**
                 * 如果还没有滚动到悬停位置，直接返回原始的frame
                 * If not scrolled to floating position yet, return original frame directly
                 */
                frame.origin.y += offset - headerSize.height
            }
            attributes.frame = frame
        } else {
            var frame = attributes.caculatedFrame ?? attributes.frame
            if view.contentOffset.x >= headerSize.width {
                /**
                 * 如果还没有滚动到悬停位置，直接返回原始的frame
                 * If not scrolled to floating position yet, return original frame directly
                 */
                frame.origin.x += view.contentOffset.x - headerSize.width
            }
            attributes.frame = frame
        }
        attributes.zIndex = zIndex
    }
    
    /**
     * 设置header悬停
     * Set header floating
     * - Parameters:
     *   - headerAttributes: header的布局属性 / header layout attributes
     *   - view: QuickListView实例 / QuickListView instance
     *   - headerSize: form header的尺寸 / form header size
     *   - suspensionHeader: 是否悬停form header / Whether form header is floating
     *   - suspensionHeaderSectionSize: 悬停的header section尺寸 / Floating header section size
     *   - scrollDirection: 滚动方向 / Scroll direction
     */
    func suspensionHeaderAttributes(
        _ headerAttributes: inout UICollectionViewLayoutAttributes,
        for view: QuickListView,
        headerSize: CGSize,
        suspensionHeader: Bool,
        suspensionHeaderSectionSize: CGSize?,
        with scrollDirection: UICollectionView.ScrollDirection
    ) {
        var offset = CGPoint(x: view.contentOffset.x, y: view.contentOffset.y + view.adjustedContentInset.top)
        if let suspensionHeaderSectionSize = suspensionHeaderSectionSize {
            if scrollDirection == .vertical {
                if suspensionHeader {
                    offset.y += suspensionHeaderSectionSize.height + headerSize.height
                } else {
                    offset.y += suspensionHeaderSectionSize.height
                }
            } else {
                if suspensionHeader {
                    offset.x += suspensionHeaderSectionSize.width + headerSize.width
                } else {
                    offset.x += suspensionHeaderSectionSize.width
                }
            }
        } else {
            if suspensionHeader {
                if scrollDirection == .vertical {
                    offset.y += headerSize.height
                } else {
                    offset.x += headerSize.width
                }
            }
        }
        /**
         * 还没有滚动到需要悬停的位置，直接返回原始的frame
         * Haven't scrolled to the position that needs floating yet, return original frame directly
         */
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
        /**
         * 下一个元素的位置
         * Next element position
         */
        var nextAttrPosition: CGPoint = endPoint
        if let footerStartPoint = footerAttributes?.frame.origin {
            nextAttrPosition = footerStartPoint
        }
        /**
         * 已经滚动到下一个，直接跳过
         * Already scrolled to next, skip directly
         */
        if scrollDirection == .vertical, offset.y > nextAttrPosition.y {
            return
        }
        if scrollDirection == .horizontal, offset.x > nextAttrPosition.x {
            return
        }
        /**
         * 设置header悬浮位置
         * Set header floating position
         */
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
    
    /**
     * 设置footer悬停
     * Set footer floating
     * - Parameters:
     *   - footerAttributes: footer的布局属性 / footer layout attributes
     *   - view: QuickListView实例 / QuickListView instance
     *   - footerSize: form footer的尺寸 / form footer size
     *   - suspensionFooter: 是否悬停form footer / Whether form footer is floating
     *   - scrollDirection: 滚动方向 / Scroll direction
     */
    func suspensionFooterAttributes(
        _ footerAttributes: inout UICollectionViewLayoutAttributes,
        for view: QuickListView,
        footerSize: CGSize,
        suspensionFooter: Bool,
        with scrollDirection: UICollectionView.ScrollDirection
    ) {
        let offset = view.contentOffset
        var footerSuspensionSize: CGSize = suspensionFooter ? footerSize : .zero
        /**
         * 添加底部安全区域尺寸（视为一直悬浮）
         * Add bottom safe area size (considered as always floating)
         */
        footerSuspensionSize.height += view.adjustedContentInset.bottom
        /**
         * 还没有滚动到需要悬停的位置，直接返回原始的frame
         * Haven't scrolled to the position that needs floating yet, return original frame directly
         */
        if scrollDirection == .vertical, endPoint.y < offset.y + view.bounds.height - footerSuspensionSize.height  {
            var frame = footerAttributes.frame
            frame.origin.y = endPoint.y - footerAttributes.size.height
            footerAttributes.frame = frame
            return
        }
        if scrollDirection == .horizontal, endPoint.x < offset.x + view.bounds.width - footerSuspensionSize.width  {
            var frame = footerAttributes.frame
            frame.origin.x = endPoint.x - footerAttributes.size.width
            footerAttributes.frame = frame
            return
        }
        /**
         * 上一个元素的位置
         * Previous element position
         */
        var lastAttrPosition: CGPoint = startPoint
        if let headerFrame = self.headerAttributes?.frame {
            lastAttrPosition = CGPoint(x: headerFrame.maxX, y: headerFrame.maxY)
        } else
        /**
         * 已经滚动到上一个section，跳过
         * Already scrolled to previous section, skip
         */
        if scrollDirection == .vertical, lastAttrPosition.y > offset.y + view.bounds.height - footerSuspensionSize.height {
            return
        }
        if scrollDirection == .horizontal, lastAttrPosition.x > offset.x + view.bounds.width - footerSuspensionSize.width {
            return
        }
        /**
         * 设置footer悬浮位置
         * Set footer floating position
         */
        if scrollDirection == .vertical {
            let width = footerAttributes.frame.width
            let height = footerAttributes.frame.height
            let x: CGFloat = footerAttributes.frame.minX
            let offsetY = offset.y + view.bounds.height - footerSuspensionSize.height
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
            let offsetX = offset.x + view.bounds.width - footerSuspensionSize.width
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
