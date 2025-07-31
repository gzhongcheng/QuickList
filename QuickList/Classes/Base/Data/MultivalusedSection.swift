//
//  MultivalusedSection.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

/**
 *  可编辑的section允许的操作选项,可以有多个值，如：
 *      let xxxOptions = MultivaluedOptions.Insert.union(.Delete)
 *   判断时使用`contains`方法判断，如：
 *      xxxOptions.contains(.Reorder)
 */
public struct MultivaluedOptions: OptionSet {

    private enum Options: Int {
        case none = 0, insert = 1, delete = 2, reorder = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: Options) { self.rawValue = options.rawValue }

    /// 没有多值
    public static let None = MultivaluedOptions(.none)

    /// 允许插入行
    public static let Insert = MultivaluedOptions(.insert)

    /// 允许移除行
    public static let Delete = MultivaluedOptions(.delete)

    /// 允许重新排序
    public static let Reorder = MultivaluedOptions(.reorder)
}

// MARK: - 可编辑的section
open class MultivalusedSection: Section {
    public var moveAble: Bool = true
    // item拖动结束的回调
    public var moveFinishClosure: ((_ moveItem: Item, _ from: IndexPath,_ to: IndexPath) -> Void)?
    
    public required init(moveAble: Bool = true,
                         header: String? = nil,
                         footer: String? = nil,
                         _ initializer: (MultivalusedSection) -> Void = { _ in }) {
        self.moveAble = moveAble
        super.init(header: header, footer: footer, {
            section in initializer(section as! MultivalusedSection)
        })
    }
    
    public required init() {
        super.init()
    }
}

// MARK: - 单选/多选列表section
/// SelectableSection中所有的item都需要遵循的协议
public protocol SelectableItemType: Item {
    var isSelected: Bool { get set }
}

/**
 定义单选/多选的枚举
 - MultipleSelection: 多选
 - SingleSelection:   单选（指定是否启用取消选择）
 */
public enum SelectionType {
    /// 多选
    case multipleSelection
    /// 单选（指定是否启用取消选择）
    case singleSelection(enableDeselection: Bool)
}

/// SelectableSection实现的协议，方便定制
public protocol  SelectableSectionType: Collection {
    associatedtype SelectableItem: SelectableItemType, ItemType
    /// 单选还是多选
    var selectionType: SelectionType { get set }

    /// 选中某一行的回调
    var onSelectSelectableItem: ((SelectableItem) -> Void)? { get set }

    /// 已选择的Item
    func selectedItem() -> SelectableItem?
    func selectedItems() -> [SelectableItem]
}

extension  SelectableSectionType where Self: Section {
    /// 获取单选的选中Item（SingleSelection使用）
    public func selectedItem() -> SelectableItem? {
        return selectedItems().first
    }

    /// 获取多选的所有选中Item（multipleSelection使用）
    public func selectedItems() -> [SelectableItem] {
        var findItems: [SelectableItem] = []
        for item in self.items {
            if
                let i = item as? SelectableItem,
                i.isSelected
            {
                findItems.append(i)
            }
        }
        return findItems
    }

    /// Item添加到section之前调用的函数
    func prepare(selectableItems items: [Item]) {
        for item in items {
            if let sItem = item as? SelectableItem {
                sItem.onCellSelection { [weak self] item in
                    guard let s = self, !item.isDisabled else { return }
                    switch s.selectionType {
                        case .multipleSelection:
                            sItem.isSelected = !sItem.isSelected
                        case let .singleSelection(enableDeselection):
                            // 检查是否已选中
                            if sItem.isSelected, enableDeselection {
                                sItem.isSelected = false
                            } else {
                                sItem.isSelected = true
                        }
                    }
                    sItem.updateCell()
                    s.onSelectSelectableItem?(sItem)
                }
            }
        }
    }

}
