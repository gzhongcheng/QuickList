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
    public func hideAllItems(withOut: [Item] = [], withAnimation: Bool = true) {
        UIView.animate(withDuration: withAnimation ? 0.3 : 0) {
            self.items.forEach { (item) in
                if !withOut.contains(item) {
                    item.isHidden = true
                    item.cell?.alpha = 0
                }
            }
            self.form?.delegate?.updateLayout(withAnimation: withAnimation, afterSection: self.index ?? 0)
        }
    }
    /**
     * 显示所有item
     * Show all items
     */
    public func showAllItems(withAnimation: Bool = true) {
        UIView.animate(withDuration: withAnimation ? 0.3 : 0) {
            self.items.forEach { (item) in
                item.isHidden = false
                item.cell?.alpha = 1
            }
            self.form?.delegate?.updateLayout(withAnimation: withAnimation, afterSection: self.index ?? 0)
        }
    }
    /**
     * 刷新所有item
     * Reload all items
     */
    public func reload() {
        guard let sectionIndex = form?.firstIndex(of: self) else {
            return
        }
        self.form?.delegate?.updateLayout(withAnimation: false, afterSection: sectionIndex)
        self.form?.delegate?.formView?.reloadSections(IndexSet(integer: sectionIndex))
    }
    
    /**
     * 仅刷新界面布局
     * Only refresh interface layout
     */
    public func updateLayout(animation: Bool = false) {
        form?.updateLayout(afterSection: self.index ?? 0, animation: animation)
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
    public func insert(_ newElement: Item, at i: Int, updateUI: Bool) {
        items.insert(newElement, at: i)
        newElement.section = self
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenAdded([newElement], to: self, at: [IndexPath(row: i, section: sectionIndex)])
    }
    
    public func append(_ formItem: Item) {
        items.append(formItem)
        formItem.section = self
    }
    public func append(_ formItem: Item, updateUI: Bool) {
        items.append(formItem)
        formItem.section = self
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenAdded([formItem], to: self, at: [IndexPath(row: items.count - 1, section: sectionIndex)])
    }
    
    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Item {
        items.append(contentsOf: newElements)
        newElements.forEach({ $0.section = self })
    }
    public func append<S: Sequence>(contentsOf newElements: S, updateUI: Bool) where S.Iterator.Element == Item {
        let oldCount = items.count
        items.append(contentsOf: newElements)
        newElements.forEach({ $0.section = self })
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenAdded(newElements.map({ $0 }), to: self, at: (oldCount - 1 ..< items.count - 1).map({ IndexPath(row: $0, section: sectionIndex) }))
    }

    public func replaceSubrange<C>(_ subRange: Range<Int>, with newElements: C) where C : Collection, C.Element == Item {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, items.count - 1))
        let upper = Swift.min(subRange.upperBound, items.count)
        items[lower ..< upper].forEach({ $0.section = nil })
        items.replaceSubrange(lower..<upper, with: newElements)
        newElements.forEach({ $0.section = self })
    }
    public func replaceSubrange<C>(_ subRange: Range<Int>, with newElements: C, updateUI: Bool) where C : Collection, C.Element == Item {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, items.count - 1))
        let upper = Swift.min(subRange.upperBound, items.count)
        let oldItems = items[lower ..< upper].map({ $0 })
        items.replaceSubrange(lower..<upper, with: newElements)
        oldItems.forEach({ $0.section = nil })
        newElements.forEach({ $0.section = self })
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenReplaced(oldItems: oldItems, newItems: newElements.map({ $0 }), to: self, at: (lower ..< upper).map({ IndexPath(row: $0, section: sectionIndex) }))
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
    @discardableResult
    public func remove(at i: Int, updateUI: Bool) -> Item {
        if i >= items.count {
            assertionFailure("Form: Index out of bounds")
        }
        let old = items[i]
        items.remove(at: i)
        old.section = nil
        if updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate {
            delegate.itemsHaveBeenRemoved([old], to: self, at: [IndexPath(row: i, section: sectionIndex)])
        }
        return old
    }
    
    public func removeFirst() -> Item {
        return remove(at: 0)
    }
    public func removeFirst(updateUI: Bool) -> Item {
        return remove(at: 0, updateUI: updateUI)
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        items.forEach({ $0.section = nil })
        items.removeAll(keepingCapacity: keepCapacity)
    }
    public func removeAll(keepingCapacity keepCapacity: Bool = false, updateUI: Bool) {
        let oldItems = items
        items.removeAll(keepingCapacity: keepCapacity)
        oldItems.forEach({ $0.section = nil })
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenRemoved(oldItems, to: self, at: (0 ..< oldItems.count).map({ IndexPath(row: $0, section: sectionIndex) }))
    }
    
    public func removeAll(where shouldBeRemoved: (Item) throws -> Bool) rethrows {
        items.forEach { (item) in
            if (try? shouldBeRemoved(item)) ?? false {
                item.section = nil
            }
        }
        try items.removeAll(where: shouldBeRemoved)
    }
    public func removeAll(updateUI: Bool, where shouldBeRemoved: (Item) throws -> Bool) rethrows {
        var needRemoveItems: [Item] = []
        var needRemoveItemIndexs: IndexSet = IndexSet()
        items.enumerated().forEach { (index, item) in
            if (try? shouldBeRemoved(item)) ?? false {
                needRemoveItems.append(item)
                needRemoveItemIndexs.insert(index)
                item.section = nil
            }
        }
        try items.removeAll(where: shouldBeRemoved)
        guard updateUI, let sectionIndex = form?.firstIndex(of: self), let delegate = form?.delegate else {
            return
        }
        delegate.itemsHaveBeenRemoved(needRemoveItems, to: self, at: needRemoveItemIndexs.map({ IndexPath(row: $0, section: sectionIndex) }))
    }
}
