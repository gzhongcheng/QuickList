//
//  Section.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

open class Section: NSObject {
    /**
     * 是否作为整个Form的悬停header，仅对首个section生效
     * Whether as the entire Form's floating header, only effective for the first section
     */
    public var isFormHeader: Bool = false
    /**
     * 整个section悬浮时的装饰view，这个装饰view的展示区域为整个section，包括header和footer的区域，仅悬浮时展示，结束悬浮就会消失
     * Decoration view when the entire section is floating, this decoration view's display area is the entire section, including header and footer areas, only displayed when floating, disappears when floating ends
     */
    public var suspensionDecoration: SectionReusableViewRepresentable?
    
    /**
     * 标记Section的唯一标识，同一个List中的section的tag一定不能相同（否则可能导致某些方法获取的section不正确）
     * Unique identifier for Section, tags of sections in the same List must not be the same (otherwise may cause some methods to get incorrect sections)
     */
    public var tag: String?
    /**
     * Section所在的Form
     * Form where Section belongs
     */
    public internal(set) weak var form: Form?
    /**
     * 获取section在form的index位置
     * Get section's index position in form
     */
    public var index: Int? { return form?.firstIndex(of: self) }
    
    /**
     * 存储所有Item的数组
     * Array storing all Items
     */
    public var items = [Item]()
    
    /**
     * 可独立指定的item与cell的映射关系表
     * Mapping table for items and cells that can be specified independently
     */
    public var itemCellBinders: [any ItemViewBinderRepresentable] = []
    
    // MARK: - Layout related properties
    /**
     * 列数（默认1列）
     * Number of columns (default 1 column)
     */
    public var column: Int = 1
    /**
     * 行间距（默认0）
     * Row spacing (default 0)
     */
    public var lineSpace: CGFloat = 0
    /**
     * 列间距（默认0）
     * Column spacing (default 0)
     */
    public var itemSpace: CGFloat = 0
    /**
     * 内容边距
     * Content insets
     */
    public var contentInset: UIEdgeInsets = .zero
    /**
     * section内部的自定义布局对象
     * Custom layout object inside section
     */
    public var layout: QuickListBaseLayout?
    
    // MARK: - header and footer
    /**
     * section的header
     * Section's header
     */
    public var header: SectionHeaderFooterViewRepresentable?
    /**
     * section的footer
     * Section's footer
     */
    public var footer: SectionHeaderFooterViewRepresentable?
    /**
     * section的装饰view，装饰view的展示区域为 header之下，footer之上，作为item组背景装饰用
     * Section's decoration view, decoration view's display area is below header, above footer, used as item group background decoration
     */
    public var decoration: SectionReusableViewRepresentable?
    
    /**
     * 获取预估尺寸（根据指定的列数和间距等计算的正方形尺寸）
     * Get estimated size (square size calculated based on specified number of columns and spacing)
     */
    public func estimateItemSize(with weight: Int) -> CGSize {
        guard
            let form = self.form,
            let delegate = form.delegate,
            let formView = delegate.formView
        else {
            return .zero
        }
        let formContentInset = form.contentInset
        switch delegate.scrollDirection {
        case .vertical:
            let maxWidth = formView.bounds.width - formContentInset.left - formContentInset.right
            if column > 1 {
                let itemTotalWidth = maxWidth - self.contentInset.left - self.contentInset.right
                let singleItemWidth: CGFloat = (itemTotalWidth - (column > 1 ? (itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
                let itemWidth = floor(singleItemWidth * CGFloat(weight) + (column > 1 ? self.itemSpace : 0) * CGFloat(weight - 1))
                return CGSize(width: itemWidth, height: itemWidth)
            } else {
                return CGSize(width: maxWidth, height: maxWidth)
            }
        case .horizontal:
            let formAutoInset = formView.adjustedContentInset
            let maxHeight = formView.bounds.height - formContentInset.top - formContentInset.bottom - formAutoInset.top - formAutoInset.bottom
            if self.column > 1 {
                let itemTotalHeight = maxHeight - self.contentInset.top - self.contentInset.bottom
                let singleItemHeight: CGFloat = (itemTotalHeight - (column > 1 ? (itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
                let itemHeight = floor(singleItemHeight * CGFloat(weight) + itemSpace * CGFloat(weight - 1))
                return CGSize(width: itemHeight, height: itemHeight)
            } else {
                return CGSize(width: maxHeight, height: maxHeight)
            }
        @unknown default:
            return .zero
        }
    }
    
    // MARK: - Initialization
    public required override init() {
        super.init()
    }
    
    /**
     * 初始化并在完成时回调
     * Initialize and callback when completed
     */
    public init(items: [Item]? = nil, _ initializer: (Section) -> Void) {
        super.init()
        self.items = items ?? []
        initializer(self)
    }
    
    /**
     * 初始化并在完成时回调
     * Initialize and callback when completed
     */
    public init(_ header: String?, items: [Item]? = nil, _ initializer: (Section) -> Void = { _ in }) {
        super.init()
        if let header = header {
            setTitleHeader(header)
        }
        if let items = items {
            self.append(contentsOf: items)
        }
        initializer(self)
    }
    
    /**
     * 带系统样式的header或footer的初始化方法
     * Initialization method with system style header or footer
     */
    public init(header: String? = nil, footer: String? = nil, items: [Item]? = nil, _ initializer: (Section) -> Void = { _ in }) {
        super.init()
        if let header = header {
            setTitleHeader(header)
        }
        if let footer = footer {
            setTitleFooter(footer)
        }
        self.items = items ?? []
        initializer(self)
    }
    
    /**
     * 设置系统样式header
     * Set system style header
     */
    func setTitleHeader(_ title: String) {
        self.header =  SectionHeaderFooterView<SectionStringHeaderFooterView>.init({ [weak self] (view, _) in
            view.title = title
            guard
                let handler = self?.form?.delegate
            else {
                return
            }
            view.scrollDirection = handler.scrollDirection
        })
        self.header?.height = { _,_,_ in 30 }
    }
    /**
     * 设置系统样式footer
     * Set system style footer
     */
    func setTitleFooter(_ title: String) {
        self.footer =  SectionHeaderFooterView<SectionStringHeaderFooterView>.init({ [weak self] (view, _) in
            view.title = title
            guard
                let handler = self?.form?.delegate
            else {
                return
            }
            view.scrollDirection = handler.scrollDirection
        })
        self.footer?.height = { _,_,_ in 30 }
    }
    
    /**
     * 隐藏所有item
     * Hide all items
     */
    public func hideAllItems(withOut: [Item] = [], inAnimation: ListReloadAnimation? = ListReloadAnimation.transform, outAnimation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        if let threeDAnim = outAnimation as? ThreeDFoldListReloadAnimation {
            threeDAnim.setSkipItems(items: withOut, at: self)
        }
        self.items.reversed().forEach { (item) in
            if !withOut.contains(item) {
                item.isHidden = true
                guard let cell = item.cell, let section = item.section else { return }
                outAnimation?.animateOut(view: cell, to: item, at: section)
            }
        }
        self.form?.delegate?.updateLayout(section: self, inAnimation: inAnimation, othersInAnimation: inAnimation != nil ? .transform : nil, performBatchUpdates: nil, completion: completion)
    }
    /**
     * 显示所有item
     * Show all items
     */
    public func showAllItems(inAnimation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        self.items.forEach { (item) in
            item.isHidden = false
        }
        self.form?.delegate?.updateLayout(section: self, inAnimation: inAnimation, othersInAnimation: inAnimation != nil ? .transform : nil, performBatchUpdates: nil, completion: completion)
    }
    
    /**
     * 刷新所有item
     * Reload all items
     */
    public func reload() {
        guard let sectionIndex = form?.firstIndex(of: self) else {
            return
        }
        self.form?.delegate?.updateLayout(section: self, inAnimation: nil, othersInAnimation: nil, performBatchUpdates: nil, completion: nil)
        self.form?.delegate?.formView?.reloadSections(IndexSet(integer: sectionIndex))
    }

    /**
     * 动画添加item
     * Animate add item
     * - Parameters:
     *   - item: 新的item / New item
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func addItem(with item: Item, animation: ListReloadAnimation? = ListReloadAnimation.bottomSlide, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            self.append(item)
            listView?.insertItems(at: [IndexPath(row: sectionIndex, section: sectionIndex)])
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 动画添加items
     * Animate add items
     * - Parameters:
     *   - items: 新的item数组 / New item array
     *   - inAnimation: cell进入动画 / Cell enter animation
     *   - completion: 完成回调 / Completion callback
     */
    public func addItems(with items: [Item], animation: ListReloadAnimation? = ListReloadAnimation.bottomSlide, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            var addedItemIndexPaths: [IndexPath] = []
            items.enumerated().forEach { (index, item) in
                self.append(item)
                addedItemIndexPaths.append(IndexPath(row: index, section: sectionIndex))
            }
            listView?.insertItems(at: addedItemIndexPaths)
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 动画插入item
     * Animate insert item
     * - Parameters:
     *   - item: 新的item / New item
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func insertItem(with item: Item, at index: Int, animation: ListReloadAnimation? = ListReloadAnimation.bottomSlide, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            self.insert(item, at: index)
            listView?.insertItems(at: [IndexPath(row: index, section: sectionIndex)])
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: false)
        }, completion: completion)
    }
    
    /**
     * 动画删除items
     * Animate delete items
     * - Parameters:
     *   - items: 需要删除的item数组 / Items to delete
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func deleteItems(with items: [Item], animation: ListReloadAnimation? = ListReloadAnimation.leftSlide, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: .transform, othersInAnimation: .transform, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            var removedItemIndexPaths: [IndexPath] = []
            items.enumerated().forEach { (index, item) in
                if self.items.contains(item) {
                    removedItemIndexPaths.append(item.indexPath!)
                    if let cell = item.cell, let section = item.section {
                        animation?.animateOut(view: cell, to: item, at: section)
                    }
                    item.section = nil
                }
            }
            self.items.removeAll(where: { items.contains($0) })
            listView?.deleteItems(at: removedItemIndexPaths)
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: true)
        }, completion: completion)
    }

    /**
     * 替换所有item, 使用相同的进入和退出动画类型
     * Replace all items, use the same enter and exit animation types
     * - Parameters:
     *   - newItems: 新的item数组 / New item array
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func replaceItems(with newItems: [Item], animation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        replaceItems(with: newItems, inAnimation: animation, outAnimation: animation, completion: completion)
    }

    /**
     * 替换所有item, 使用指定的进入和退出动画类型
     * Replace all items, use the specified enter and exit animation types
     * - Parameters:
     *   - newItems: 新的item数组 / New item array
     *   - inAnimation: cell进入动画 / Cell enter animation
     *   - outAnimation: cell退出动画 / Cell exit animation
     *   - completion: 完成回调 / Completion callback
     */
    public func replaceItems(with newItems: [Item], inAnimation: ListReloadAnimation? = ListReloadAnimation.transform, outAnimation: ListReloadAnimation? = ListReloadAnimation.transform, otherSectionsInAnimation: ListReloadAnimation? = ListReloadAnimation.transform, otherSectionsOutAnimation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: inAnimation, othersInAnimation: otherSectionsInAnimation, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            var removedItemIndexPaths: [IndexPath] = []
            self.items.enumerated().forEach { (index, item) in
                if let cell = item.cell, let section = item.section {
                    outAnimation?.animateOut(view: cell, to: item, at: section)
                }
                item.section = nil
                removedItemIndexPaths.append(IndexPath(row: index, section: sectionIndex))
            }
            self.items = newItems
            var addedItemIndexPaths: [IndexPath] = []
            newItems.enumerated().forEach { (index, item) in
                item.section = self
                addedItemIndexPaths.append(IndexPath(row: index, section: sectionIndex))
            }
            listView?.deleteItems(at: removedItemIndexPaths)
            listView?.insertItems(at: addedItemIndexPaths)
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: true)
        }, completion: completion)
    }

    /**
     * 替换item数组到指定范围, 并通知到代理
     * Replace item array to specified range, and notify delegate
     * - Parameters:
     *   - range: 范围 / Range
     *   - newItems: 新的item数组 / New item array
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func replaceItems(with newItems: [Item], at range: Range<Int>, animation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            let sectionIndex = self.index ?? 0
            var removedItemIndexPaths: [IndexPath] = []
            self.items.enumerated().forEach { (index, item) in
                if index < range.lowerBound || index >= range.upperBound {
                    if let cell = item.cell, let section = item.section {
                        animation?.animateOut(view: cell, to: item, at: section)
                    }
                    removedItemIndexPaths.append(IndexPath(row: index, section: sectionIndex))
                }
            }
            self.replaceSubrange(range, with: newItems)
            var addedItemIndexPaths: [IndexPath] = []
            newItems.enumerated().forEach { (index, item) in
                addedItemIndexPaths.append(item.indexPath!)
            }
            listView?.deleteItems(at: removedItemIndexPaths)
            listView?.insertItems(at: addedItemIndexPaths)
            layout?.reloadSectionsAfter(index: sectionIndex, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 仅刷新界面布局,可以指定进入动画类型
     * Only refresh interface layout, can specify enter animation type
     * - Parameters:
     *   - animation: cell进入动画 / Cell enter animation
     *   - completion: 完成回调 / Completion callback
     */
    public func updateLayout(animation: ListReloadAnimation? = ListReloadAnimation.transform, completion: (() -> Void)? = nil) {
        self.form?.delegate?.updateLayout(section: self, inAnimation: animation, othersInAnimation: animation, performBatchUpdates: nil, completion: completion)
    }
}


// MARK: - Collection protocol
extension Section: MutableCollection,BidirectionalCollection {
    // MARK: MutableCollectionType
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return items.count }
    
    /**
     * 通过下标设置/获取元素
     * Set/get elements through subscript
     */
    public subscript (position: Int) -> Item {
        get {
            if position >= items.count {
                assertionFailure("Section: Index out of bounds")
            }
            return items[position]
        }
        set {
            if position > items.count {
                assertionFailure("Section: Index out of bounds")
            }
            if position < items.count {
                let oldItem = items[position]
                if oldItem == newValue {
                    return
                }
                items[position] = newValue
            } else {
                items.append(newValue)
            }
        }
    }
    
    public subscript (range: Range<Int>) -> ArraySlice<Item> {
        get { return items.map { $0 }[range] }
        set { replaceSubrange(range, with: newValue) }
    }
    
    public func index(after i: Int) -> Int { return i + 1 }
    public func index(before i: Int) -> Int { return i - 1 }
}

// MARK: - RangeReplaceableCollection
extension Section: RangeReplaceableCollection {
    public func insert(_ newElement: Item, at i: Int) {
        items.insert(newElement, at: i)
        newElement.section = self
    }
    
    public func append(_ formItem: Item) {
        items.append(formItem)
        formItem.section = self
    }
    
    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Item {
        items.append(contentsOf: newElements)
        newElements.forEach({ $0.section = self })
    }

    public func replaceSubrange<C>(_ subRange: Range<Int>, with newElements: C) where C : Collection, C.Element == Item {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, items.count - 1))
        let upper = Swift.min(subRange.upperBound, items.count)
        items[lower ..< upper].forEach({ $0.section = nil })
        items.replaceSubrange(lower..<upper, with: newElements)
        newElements.forEach({ $0.section = self })
    }
    
    @discardableResult
    public func remove(at i: Int) -> Item {
        if i >= items.count {
            assertionFailure("Form: Index out of bounds")
        }
        let old = items[i]
        items.remove(at: i)
        old.section = nil
        return old
    }
    
    public func removeFirst() -> Item {
        return remove(at: 0)
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        items.forEach({ $0.section = nil })
        items.removeAll(keepingCapacity: keepCapacity)
    }
    
    public func removeAll(where shouldBeRemoved: (Item) throws -> Bool) rethrows {
        items.forEach({ 
            if (try? shouldBeRemoved($0)) ?? false {
                $0.section = nil
            }
        })
        try items.removeAll(where: shouldBeRemoved)
    }
}
