//
//  Section.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

open class Section: NSObject {
    /// 是否作为整个Form的悬停header，仅对首个section生效
    public var isFormHeader: Bool = false
    /// 整个section悬浮时的装饰view，这个装饰view的展示区域为整个section，包括header和footer的区域，仅悬浮时展示，结束悬浮就会消失
    public var suspensionDecoration: SectionReusableViewRepresentable?
    
    /// 标记Section的唯一标识，同一个List中的section的tag一定不能相同（否则可能导致某些方法获取的section不正确）
    public var tag: String?
    /// Section所在的Form
    public internal(set) weak var form: Form?
    /// 获取section在form的index位置
    public var index: Int? { return form?.firstIndex(of: self) }
    
    /// 存储所有Item的数组
    public var items = [Item]()
    
    /// 可独立指定的item与cell的映射关系表
    public var itemCellBinders: [any ItemViewBinderRepresentable] = []
    
    // MARK: - 布局相关属性
    /// 列数（默认1列）
    public var column: Int = 1
    /// 行间距（默认0）
    public var lineSpace: CGFloat = 0
    /// 列间距（默认0）
    public var itemSpace: CGFloat = 0
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero
    /// section内部的自定义布局对象
    public var layout: QuickListBaseLayout?
    
    // MARK: - header 和 footer
    /// section的header
    public var header: SectionHeaderFooterViewRepresentable?
    /// section的footer
    public var footer: SectionHeaderFooterViewRepresentable?
    /// section的装饰view，装饰view的展示区域为 header之下，footer之上，作为item组背景装饰用
    public var decoration: SectionReusableViewRepresentable?
    
    /// 获取预估尺寸（根据指定的列数和间距等计算的正方形尺寸）
    public func estimateItemSize(with weight: Int) -> CGSize {
        guard
            let form = self.form,
            let delegate = form.delegate,
            let viewSize = delegate.formView?.displaySize()
        else {
            return .zero
        }
        let formContentInset = form.contentInset
        
        switch delegate.scrollDirection {
        case .vertical:
            let maxWidth = viewSize.width - formContentInset.left - formContentInset.right
            if column > 1 {
                let itemTotalWidth = maxWidth - self.contentInset.left - self.contentInset.right
                let singleItemWidth: CGFloat = (itemTotalWidth - (column > 1 ? (itemSpace * CGFloat(column - 1)) : 0)) / CGFloat(column)
                let itemWidth = floor(singleItemWidth * CGFloat(weight) + (column > 1 ? self.itemSpace : 0) * CGFloat(weight - 1))
                return CGSize(width: itemWidth, height: itemWidth)
            } else {
                return CGSize(width: maxWidth, height: maxWidth)
            }
        case .horizontal:
            let maxHeight = viewSize.height - formContentInset.top - formContentInset.bottom
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
    
    // MARK: - 初始化
    public required override init() {
        super.init()
    }
    
    /// 初始化并在完成时回调
    public init(items: [Item]? = nil, _ initializer: (Section) -> Void) {
        super.init()
        self.items = items ?? []
        initializer(self)
    }
    
    /// 初始化并在完成时回调
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
    
    /// 带系统样式的header或footer的初始化方法
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
    
    /// 设置系统样式header
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
    /// 设置系统样式footer
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
    
    /// 隐藏所有item
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
    /// 显示所有item
    public func showAllItems(withAnimation: Bool = true) {
        UIView.animate(withDuration: withAnimation ? 0.3 : 0) {
            self.items.forEach { (item) in
                item.isHidden = false
                item.cell?.alpha = 1
            }
            self.form?.delegate?.updateLayout(withAnimation: withAnimation, afterSection: self.index ?? 0)
        }
    }
    /// 刷新所有item
    public func reload() {
        guard let sectionIndex = form?.firstIndex(of: self) else {
            return
        }
        self.form?.delegate?.updateLayout(withAnimation: false, afterSection: sectionIndex)
        self.form?.delegate?.formView?.reloadSections(IndexSet(integer: sectionIndex))
    }
    
    /// 仅刷新界面布局
    public func updateLayout(animation: Bool = false) {
        form?.delegate?.updateLayout(withAnimation: animation, afterSection: self.index ?? 0)
    }
}


// MARK: - 集合协议
extension Section: MutableCollection,BidirectionalCollection {
    // MARK: MutableCollectionType
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return items.count }
    
    /// 通过下标设置/获取元素
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
    /// 插入
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
    
    /// 添加
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
    /// 添加数组
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

    /// 替换内容
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
    
    /// 移除
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
