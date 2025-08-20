//
//  List.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

public protocol FormDelegate : AnyObject {
    /// 滚动方向
    var scrollDirection: UICollectionView.ScrollDirection { get }
    /// 列表控件
    var formView: FormViewProtocol? { get }
    /// 是否正在滚动
    var isScrolling: Bool { get }
    
    /// 数据改变的后刷新界面
    func sectionsHaveBeenAdded(_ sections: [Section], at: IndexSet)
    func sectionsHaveBeenRemoved(_ sections: [Section], at: IndexSet)
    func sectionsHaveBeenReplaced(oldSections: [Section], newSections: [Section], at: IndexSet)
    func itemsHaveBeenAdded(_ items: [Item], to section: Section , at: [IndexPath])
    func itemsHaveBeenRemoved(_ items: [Item], to section: Section, at: [IndexPath])
    func itemsHaveBeenReplaced(oldItems: [Item], newItems: [Item], to section: Section, at: [IndexPath])
    
    /// 更新指定SectionIndex及之后的Section的Layout
    func updateLayout(withAnimation: Bool, afterSection: Int)
    
    /// 获取控件尺寸
    func getViewSize() -> CGSize
    /// 获取内容尺寸
    func getContentSize() -> CGSize
}

/// 选中item装饰view与item的关系
public enum ItemDecorationPosition {
    /// 选中item装饰view在item图层之上
    case above
    /// 选中item装饰view在item图层之下
    case below
}

public final class Form: NSObject {
    /// delegate
    public weak var delegate: FormDelegate?
    /// 内容自定义布局（优先级 section.layout -> form.layout -> QuickListFlowLayout）
    public var layout: QuickListBaseLayout?
    /// 内容未填满列表时是否需要居中展示
    public var needCenterIfNotFull: Bool = false
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero
    /// 是否单选
    public var singleSelection: Bool = false
    /// 列表通用的选中item的装饰view，展示在选中item图层之下，尺寸为item大小，设置后，列表将强制变成单选状态
    public var selectedItemDecoration: UIView?
    /// 选中item装饰view与item的图层关系
    public var selectedItemDecorationPosition: ItemDecorationPosition = .below
    /// 选中item装饰view的移动动画时长
    public var selectedItemDecorationMoveDuration: TimeInterval = 0.25
    /// 列表整体的背景装饰view，展示在列表最底层，尺寸为列表大小，且内部会将它的交互禁用
    public var backgroundDecoration: UIView? {
        didSet {
            backgroundDecoration?.isUserInteractionEnabled = false
        }
    }
    
    /// 列表的Header
    public var header: FormHeaderFooterView?
    /// 列表的Footer
    public var footer: FormHeaderFooterView?
    
    /// 所有Section的数组
    public private(set) var sections = [Section]()
    
    /// 可独立指定的item与cell的映射关系表（section中也可指定，且优先级高于这个）
    public var itemCellBinders: [any ItemViewBinderRepresentable] = []
    
    /// 获取tag对应的Section
    public func section(for tag: String) -> Section? {
        sections.first(where: { $0.tag == tag })
    }
    
    /// 获取tag对应的第一个item
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
}

extension Form: Collection {
    /// 根据indexPath获取Item
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
                // form中移除旧Section
                sections[position] = newValue
                self.delegate?.sectionsHaveBeenRemoved([oldSection], at: IndexSet(integer: position))
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
    /// 添加
    public func append(_ formSection: Section) {
        sections.append(formSection)
        formSection.form = self
    }
    public func append(_ formSection: Section, updateUI: Bool) {
        sections.append(formSection)
        formSection.form = self
        guard updateUI else {
            return
        }
        delegate?.sectionsHaveBeenAdded([formSection], at: IndexSet(integersIn: sections.count - 2 ..< sections.count - 1))
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Section {
        sections.append(contentsOf: newElements)
        newElements.forEach({ $0.form = self })
    }
    public func append<S: Sequence>(contentsOf newElements: S, updateUI: Bool) where S.Iterator.Element == Section {
        let firstIndex = sections.count
        sections.append(contentsOf: newElements)
        newElements.forEach({ $0.form = self })
        guard updateUI else {
            return
        }
        delegate?.sectionsHaveBeenAdded(sections, at: IndexSet(integersIn: firstIndex ..< sections.count))
    }

    /// 替换
    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Section {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, sections.count - 1))
        let upper = Swift.min(subRange.upperBound, sections.count)
        sections[lower ..< upper].forEach({ $0.form = self })
        sections.replaceSubrange(lower ..< upper, with: newElements)
        newElements.forEach({ $0.form = self })
    }
    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C, updateUI: Bool) where C.Iterator.Element == Section {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, sections.count - 1))
        let upper = Swift.min(subRange.upperBound, sections.count)
        let oldSections = sections[lower ..< upper].map({ $0 })
        sections.replaceSubrange(lower ..< upper, with: newElements)
        oldSections.forEach({ $0.form = self })
        newElements.forEach({ $0.form = self })
        guard updateUI else {
            return
        }
        self.delegate?.formView?.reloadData()
    }
    
    /// 移除
    public func remove(at i: Int) -> Section {
        if i >= sections.count {
            assertionFailure("Form: Index out of bounds")
        }
        let oldSection = sections[i]
        sections.remove(at: i)
        oldSection.form = nil
        return oldSection
    }
    public func remove(at i: Int, updateUI: Bool) -> Section {
        if i >= sections.count {
            assertionFailure("Form: Index out of bounds")
        }
        let oldSection = sections[i]
        sections.remove(at: i)
        oldSection.form = nil
        guard updateUI else {
            return oldSection
        }
        self.delegate?.sectionsHaveBeenRemoved([oldSection], at: IndexSet(integer: i))
        return oldSection
    }
    
    public func removeFirst() -> Section {
        return remove(at: 0)
    }
    public func removeFirst(updateUI: Bool) -> Section {
        return remove(at: 0, updateUI: updateUI)
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        sections.forEach({ $0.form = nil })
        sections.removeAll(keepingCapacity: keepCapacity)
    }
    public func removeAll(keepingCapacity keepCapacity: Bool = false, updateUI: Bool) {
        let oldSections = sections
        sections.forEach({ $0.form = nil })
        sections.removeAll(keepingCapacity: keepCapacity)
        guard updateUI else {
            return
        }
        self.delegate?.sectionsHaveBeenRemoved(oldSections, at: IndexSet(integersIn: 0 ..< oldSections.count))
    }
    
    public func removeAll(where shouldBeRemoved: (Section) throws -> Bool) rethrows {
        sections.forEach({ section in
            if (try? shouldBeRemoved(section)) ?? false {
                section.form = nil
            }
        })
        try sections.removeAll(where: shouldBeRemoved)
    }
    public func removeAll(updateUI: Bool, where shouldBeRemoved: (Section) throws -> Bool) rethrows {
        var needRemoveSections: [Section] = []
        var needRemoveSectionIndexs: IndexSet = IndexSet()
        sections.enumerated().forEach { (index, section) in
            if (try? shouldBeRemoved(section)) ?? false {
                needRemoveSections.append(section)
                needRemoveSectionIndexs.insert(index)
                section.form = nil
            }
        }
        try sections.removeAll(where: shouldBeRemoved)
        guard updateUI else {
            return
        }
        self.delegate?.sectionsHaveBeenRemoved(needRemoveSections, at: needRemoveSectionIndexs)
    }
}
