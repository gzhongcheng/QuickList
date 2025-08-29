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

public protocol QuickListCollectionLayoutDelegate: AnyObject {
    /// 更新完成回调
    func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout)
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
    /// 整个form的Header和Footer的尺寸
    var headerAttributes: UICollectionViewLayoutAttributes?
    var footerAttributes: UICollectionViewLayoutAttributes?
    /// 悬浮headerSection的尺寸，用于支持isFormHeader，如果isFormHeader为false，则该值为nil
    var suspensionHeaderSectionSize: CGSize?
    /// 存放各section位置等数据的数组
    var sectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /// 存放各section位置等数据的数组
    var oldSectionAttributes: [Int: QuickListSectionAttribute] = [:]
    /// 计算中的中间量，用于定位各个section的开始位置
    var currentOffset: CGPoint = .zero
    
    // MARK: - 多播代理
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
    
    /// 通知布局完成
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
    
    // MARK: - 布局计算
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
            /// 计算整个列表的Header
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
            
            if scrollDirection == .vertical {
                currentOffset.y += form.contentInset.top
            } else {
                currentOffset.x += form.contentInset.left
            }
            
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
        
        /// 添加尾部间距
        if self.scrollDirection == .vertical {
            currentOffset.y += form.contentInset.bottom
        } else {
            currentOffset.x += form.contentInset.right
        }
        
        /// 计算整个列表的Footer
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
                    /// 记录初始位置
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
        /// 整体的header和footer
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
            /// 添加item位置
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
            /// 如果有可压缩的header/footer，或者悬浮的header/footer，需要重新布局
            return true
        }
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

// MARK: - QuickListSectionAttribute位置获取扩展
extension QuickListSectionAttribute {
    /**
    获取section内所有元素的布局属性
    - Parameters:
        - rect: 需要获取的范围
        - view: QuickListView实例
        - headerSize: form header的尺寸
        - suspensionHeader: 是否悬停form header
        - suspensionHeaderSectionSize: 悬停的header section尺寸
        - footerSize: form footer的尺寸
        - suspensionFooter: 是否悬停form footer
        - scrollDirection: 滚动方向
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
            /// 设置整个section悬停
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
    
    /**
     设置整个section悬停
        - Parameters:
            - attributes: 布局属性
            - zIndex: zIndex值
            - view: QuickListView实例
            - headerSize: form header的尺寸
            - scrollDirection: 滚动方向
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
                /// 如果还没有滚动到悬停位置，直接返回原始的frame
                frame.origin.y += offset - headerSize.height
            }
            attributes.frame = frame
        } else {
            var frame = attributes.caculatedFrame ?? attributes.frame
            if view.contentOffset.x >= headerSize.width {
                /// 如果还没有滚动到悬停位置，直接返回原始的frame
                frame.origin.x += view.contentOffset.x - headerSize.width
            }
            attributes.frame = frame
        }
        attributes.zIndex = zIndex
    }
    
    /**
    设置header悬停
    - Parameters:
        - headerAttributes: header的布局属性
        - view: QuickListView实例
        - headerSize: form header的尺寸
        - suspensionHeader: 是否悬停form header
        - suspensionHeaderSectionSize: 悬停的header section尺寸
        - scrollDirection: 滚动方向
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
    
    /**
     设置footer悬停
        - Parameters:
            - footerAttributes: footer的布局属性
            - view: QuickListView实例
            - footerSize: form footer的尺寸
            - suspensionFooter: 是否悬停form footer
            - scrollDirection: 滚动方向
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
        /// 添加底部安全区域尺寸（视为一直悬浮）
        footerSuspensionSize.height += view.adjustedContentInset.bottom
        /// 还没有滚动到需要悬停的位置，直接返回原始的frame
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
        /// 上一个元素的位置
        var lastAttrPosition: CGPoint = startPoint
        if let headerFrame = self.headerAttributes?.frame {
            lastAttrPosition = CGPoint(x: headerFrame.maxX, y: headerFrame.maxY)
        } else
        /// 已经滚动到上一个section，跳过
        if scrollDirection == .vertical, lastAttrPosition.y > offset.y + view.bounds.height - footerSuspensionSize.height {
            return
        }
        if scrollDirection == .horizontal, lastAttrPosition.x > offset.x + view.bounds.width - footerSuspensionSize.width {
            return
        }
        /// 设置footer悬浮位置
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
