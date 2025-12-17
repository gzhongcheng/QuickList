//
//  List.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

public protocol FormDelegate : AnyObject {
    /**
     * 滚动方向
     * Scroll direction
     */
    var scrollDirection: UICollectionView.ScrollDirection { get }
    /**
     * 列表控件
     * List view
     */
    var formView: QuickListView? { get }
    /**
     * 是否正在滚动
     * Whether scrolling
     */
    var isScrolling: Bool { get }
    
    /**
     * 更新指定Sections及之后的Section的Layout
     * Update Layout for specified Sections and subsequent Sections
     * - Parameters:
     *   - sections: 需要更新的Sections / Sections to update
     *   - inAnimation: 本Section进入动画 / This section enter animation
     *   - othersInAnimation: 其他Section进入动画 / Other sections enter animation
     *   - performBatchUpdates: 批量更新数据的逻辑 / Batch update logic
     *   - completion: 更新动画完成后的回调 / Completion after update
     */
    func updateLayout(sections: [Section]?, inAnimation: ListReloadAnimation?, othersInAnimation: ListReloadAnimation?, performBatchUpdates: ((QuickListView?, QuickListCollectionLayout?) -> Void)?, completion: (() -> Void)?)
    
    /**
     * 获取控件尺寸
     * Get view size
     */
    func getViewSize() -> CGSize
    /**
     * 获取内容尺寸
     * Get content size
     */
    func getContentSize() -> CGSize
}

/**
 * 选中item装饰view与item的关系
 * Relationship between selected item decoration view and item
 */
public enum ItemDecorationPosition {
    /**
     * 选中item装饰view在item图层之上
     * Selected item decoration view above item layer
     */
    case above
    /**
     * 选中item装饰view在item图层之下
     * Selected item decoration view below item layer
     */
    case below
}

public final class Form: NSObject {
    /// delegate
    public weak var delegate: FormDelegate?
    /**
     * 列表的总布局对象(实际传递给列表使用的UICollectionViewLayout对象, 只读)
     * Total layout object for the list (the actual UICollectionViewLayout object passed to the list, read-only)
     */
    public var listLayout: QuickListCollectionLayout? {
        return delegate?.formView?.handler.layout
    }
    /**
     * 列表视图对象(只读)
     * List view object (read-only)
     */
    public var listView: QuickListView? {
        return delegate?.formView
    }
    /**
     * 内容自定义布局（优先级 section.layout -> form.layout -> QuickListFlowLayout）
     * Custom layout for content (priority: section.layout -> form.layout -> QuickListFlowLayout)
     */
    public var layout: QuickListBaseLayout?
    /**
     * 内容未填满列表时是否需要居中展示
     * Whether to center display when content doesn't fill the list
     */
    public var needCenterIfNotFull: Bool = false
    /**
     * 内容边距
     * Content insets
     */
    public var contentInset: UIEdgeInsets = .zero
    /**
     * 是否单选
     * Whether single selection
     */
    public var singleSelection: Bool = false
    /**
     * 列表通用的选中item的装饰view，展示在选中item图层之下，尺寸为item大小，设置后，列表将强制变成单选状态
     * Common decoration view for selected items in the list, displayed below the selected item layer, size is item size, after setting, the list will be forced to single selection state
     */
    public var selectedItemDecoration: UIView?
    /**
     * 选中item装饰view与item的图层关系
     * Layer relationship between selected item decoration view and item
     */
    public var selectedItemDecorationPosition: ItemDecorationPosition = .below
    /**
     * 选中item装饰view的移动动画时长
     * Movement animation duration for selected item decoration view
     */
    public var selectedItemDecorationMoveDuration: TimeInterval = 0.25
    /**
     * 列表整体的背景装饰view，展示在列表最底层，尺寸为列表大小，且内部会将它的交互禁用
     * Overall background decoration view for the list, displayed at the bottom layer of the list, size is list size, and its interaction will be disabled internally
     */
    public var backgroundDecoration: UIView? {
        didSet {
            backgroundDecoration?.isUserInteractionEnabled = false
        }
    }
    
    /**
     * 列表的Header
     * List's Header
     */
    public var header: FormHeaderFooterReusable?
    /**
     * 列表的Footer
     * List's Footer
     */
    public var footer: FormHeaderFooterReusable?
    
    /**
     * 所有Section的数组
     * Array of all Sections
     */
    public private(set) var sections: [Section] = []
    
    /**
     * 可独立指定的item与cell的映射关系表（section中也可指定，且优先级高于这个）
     * Mapping table for items and cells that can be specified independently (can also be specified in section, with higher priority)
     */
    public var itemCellBinders: [any ItemViewBinderRepresentable] = []
    
    /**
     * 获取tag对应的Section
     * Get Section corresponding to tag
     */
    public func section(for tag: String) -> Section? {
        sections.first(where: { $0.tag == tag })
    }
    
    /**
     * 获取tag对应的第一个item
     * Get first item corresponding to tag
     */
    public func firstItem(for tag: String) -> Item? {
        for section in sections {
            for item in section.items {
                if item.tag == tag {
                    return item
                }
            }
        }
        return nil
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(sections: [Section]) {
        self.init()
        self.append(contentsOf: sections)
    }
    
    /**
     * 仅刷新界面布局
     * Only refresh interface layout
     */
    public func updateLayout(afterSection: Int, animation: ListReloadAnimation? = nil) {
        delegate?.formView?.setNeedUpdateLayout(afterSection: afterSection, animation: animation)
    }

    /**
     * 添加Section数组, 更新界面布局
     * Add Section array, update interface layout
     * - Parameters:
     *   - sections: Section数组 / Section array
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func addSections(with sections: [Section], animation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.append(contentsOf: sections)
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: sections, inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            var addedSectionIndexSet: IndexSet = IndexSet()
            sections.forEach { section in
                self.append(section)
                addedSectionIndexSet.insert(self.sections.count - 1)
            }
            listView?.insertSections(addedSectionIndexSet)
            layout?.reloadSectionsAfter(index: addedSectionIndexSet.first ?? 0, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 添加Section, 更新界面布局
     * Add Section, update interface layout
     * - Parameters:
     *   - section: Section / Section
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func addSection(with section: Section, animation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.append(section)
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: [section], inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            self.append(section)
            listView?.insertSections(IndexSet(integer: self.sections.count - 1))
            layout?.reloadSectionsAfter(index: self.sections.count - 1, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 插入Section, 更新界面布局
     * Insert Section, update interface layout
     * - Parameters:
     *   - section: Section / Section
     *   - index: 插入位置 / Insert position
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func insetSection(with section: Section, at index: Int, animation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.insert(section, at: index)
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: [section], inAnimation: animation, othersInAnimation: nil, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            self.insert(section, at: index)
            listView?.insertSections(IndexSet(integer: index))
            layout?.reloadSectionsAfter(index: index, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 替换Section数组, 更新界面布局
     * Replace Section array, update interface layout
     * - Parameters:
     *   - sections: Section数组 / Section array
     *   - inAnimation: 进入动画 / Item enter animation
     *   - outAnimation: 退出动画 / Item exit animation
     *   - completion: 完成回调 / Completion callback
     */
    public func replaceSections(with sections: [Section], inAnimation: ListReloadAnimation? = nil, outAnimation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.removeAll()
            self.append(contentsOf: sections)
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: sections, inAnimation: inAnimation, othersInAnimation: inAnimation, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            if self.sections.count > 0 {
                var removedSectionIndexSet: IndexSet = IndexSet()
                var removedItemIndexPath: [IndexPath] = []
                self.sections.enumerated().forEach { (sectionIndex, section) in
                    if let outAnimation = outAnimation {
                        section.items.enumerated().forEach { (itemIndex, item) in
                            if let cell = item.cell, let section = item.section {
                                outAnimation.animateOut(view: cell, to: item, at: section)
                            }
                            removedItemIndexPath.append(IndexPath(row: itemIndex, section: sectionIndex))
                        }
                    }
                    section.form = nil
                    removedSectionIndexSet.insert(sectionIndex)
                }
                self.sections.removeAll()
                listView?.deleteItems(at: removedItemIndexPath)
                listView?.deleteSections(removedSectionIndexSet)
            }
            var insertSectionIndexSet: IndexSet = IndexSet()
            var insertItemIndexPath: [IndexPath] = []
            sections.enumerated().forEach { sectionIndex, section in
                self.append(section)
                insertSectionIndexSet.insert(sectionIndex)
                section.items.enumerated().forEach { (itemIndex, item) in
                    insertItemIndexPath.append(IndexPath(row: itemIndex, section: sectionIndex))
                }
            }
            listView?.insertSections(insertSectionIndexSet)
            layout?.reloadSectionsAfter(index: 0, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 替换Section数组到指定范围, 更新界面布局
     * Replace Section array to specified range, update interface layout
     * - Parameters:
     *   - sections: Section数组 / Section array
     *   - range: 范围 / Range
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func replaceSections(with sections: [Section], at range: Range<Int>, inAnimation: ListReloadAnimation? = nil, outAnimation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.replaceSubrange(range, with: sections)
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: sections, inAnimation: inAnimation, othersInAnimation: .transform, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            var removedSectionIndexSet: IndexSet = IndexSet()
            var removedSections: [Section] = []
            self.sections.enumerated().forEach { (index, section) in
                if index >= range.lowerBound && index < range.upperBound  {
                    if let outAnimation = outAnimation {
                        section.items.forEach { item in
                            if let cell = item.cell, let section = item.section {
                                outAnimation.animateOut(view: cell, to: item, at: section)
                            }
                        }
                    }
                    section.form = nil
                    removedSectionIndexSet.insert(index)
                    removedSections.append(section)
                }
            }
            self.sections.removeAll(where: { removedSections.contains($0) })
            var addedSectionIndexSet: IndexSet = IndexSet()
            sections.enumerated().forEach { (index, section) in
                self.insert(section, at: index + range.lowerBound)
                addedSectionIndexSet.insert(index + range.lowerBound)
            }
            listView?.deleteSections(removedSectionIndexSet)
            listView?.insertSections(addedSectionIndexSet)
            layout?.reloadSectionsAfter(index: range.lowerBound, needOldSectionAttributes: false)
        }, completion: completion)
    }

    /**
     * 删除Section数组, 更新界面布局
     * Delete Section array, update interface layout
     * - Parameters:
     *   - sections: Section数组 / Section array
     *   - animation: 动画 / Animation
     *   - completion: 完成回调 / Completion callback
     */
    public func deleteSections(with sections: [Section], inAnimation: ListReloadAnimation? = .transform, outAnimation: ListReloadAnimation? = nil, completion: (() -> Void)? = nil) {
        guard self.listView?.superview != nil, self.listView?.window != nil else {
            self.removeAll(where: { sections.contains($0) })
            setNeedReloadList()
            return
        }
        self.delegate?.updateLayout(sections: nil, inAnimation: inAnimation, othersInAnimation: inAnimation, performBatchUpdates: { [weak self] (listView, layout) in
            guard let `self` = self else { return }
            var removedSectionIndexSet: IndexSet = IndexSet()
            sections.forEach { section in
                if let index = self.sections.firstIndex(where: { $0.index == section.index }) {
                    if let outAnimation = outAnimation {
                        section.items.forEach { item in
                            if let cell = item.cell, let section = item.section {
                                outAnimation.animateOut(view: cell, to: item, at: section)
                            }
                        }
                    }
                    section.form = nil
                    removedSectionIndexSet.insert(index)
                }
            }
            self.removeAll(where: { sections.contains($0) })
            listView?.deleteSections(removedSectionIndexSet)
            layout?.reloadSectionsAfter(index: removedSectionIndexSet.first ?? 0, needOldSectionAttributes: false)
        }, completion: completion)
    }
    
    func setNeedReloadList() {
        self.listView?.setNeedsReload()
    }
}

extension Form: Collection {
    /**
     * 根据indexPath获取Item
     * Get Item based on indexPath
     */
    public subscript(indexPath: IndexPath) -> Item? {
        guard indexPath.underestimatedCount > 1, self.count > indexPath.section ,self[indexPath.section].count > indexPath.row else {
            return nil
        }
        return self[indexPath.section][indexPath.row]
    }
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return sections.count }
}

// MARK: - MutableCollection
extension Form: MutableCollection {
    public subscript (_ position: Int) -> Section {
        get { return sections[position] }
        set {
            if position > sections.count {
                assertionFailure("Form: Index out of bounds")
            }
            if position < sections.count {
                let oldSection = sections[position]
                if oldSection == newValue {
                    return
                }
                sections[position] = newValue
                newValue.form = self
            } else {
                sections.append(newValue)
            }
        }
    }
    public func index(after i: Int) -> Int {
        return i+1 <= endIndex ? i+1 : endIndex
    }
    public func index(before i: Int) -> Int {
        return i > startIndex ? i-1 : startIndex
    }
    public var last: Section? {
        return reversed().first
    }
}

// MARK: - RangeReplaceableCollection
extension Form : RangeReplaceableCollection {
    public func append(_ formSection: Section) {
        sections.append(formSection)
        formSection.form = self
        formSection.needUpdateLayout = true
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Section {
        sections.append(contentsOf: newElements)
        newElements.forEach({
            $0.form = self
            $0.needUpdateLayout = true
        })
    }

    public func insert(_ newElement: Section, at i: Int) {
        sections.insert(newElement, at: i)
        newElement.form = self
        newElement.needUpdateLayout = true
    }

    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Section {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, sections.count - 1))
        let upper = Swift.min(subRange.upperBound, sections.count)
        sections[lower ..< upper].forEach({ $0.form = self })
        sections.replaceSubrange(lower ..< upper, with: newElements)
        newElements.forEach({
            $0.form = self
            $0.needUpdateLayout = true
        })
    }
    
    public func remove(at i: Int) -> Section {
        if i >= sections.count {
            assertionFailure("Form: Index out of bounds")
        }
        let oldSection = sections[i]
        sections.remove(at: i)
        oldSection.form = nil
        return oldSection
    }
    
    public func removeFirst() -> Section {
        return remove(at: 0)
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        sections.forEach({ $0.form = nil })
        sections.removeAll(keepingCapacity: keepCapacity)
    }
    
    public func removeAll(where shouldBeRemoved: (Section) throws -> Bool) rethrows {
        sections.forEach({ section in
            if (try? shouldBeRemoved(section)) ?? false {
                section.form = nil
            }
        })
        try sections.removeAll(where: shouldBeRemoved)
    }
}
