//
//  MultivalusedSection.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

// MARK: - Editable section
open class MultivalusedSection: Section {
    public var moveAble: Bool = true
    // item拖动结束的回调
    // Callback when item drag ends
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

// MARK: - Single/Multiple selection list section
/**
 * SelectableSection中所有的item都需要遵循的协议
 * Protocol that all items in SelectableSection need to follow
 */
public protocol SelectableItemType: Item {
    var isSelected: Bool { get set }
}

/**
 * 定义单选/多选的枚举
 * Define single/multiple selection enumeration
 * - MultipleSelection: 多选
 * - MultipleSelection: Multiple selection
 * - SingleSelection:   单选（指定是否启用取消选择）
 * - SingleSelection:   Single selection (specify whether to enable deselection)
 */
public enum SelectionType {
    /**
     * 多选
     * Multiple selection
     */
    case multipleSelection
    /**
     * 单选（指定是否启用取消选择）
     * Single selection (specify whether to enable deselection)
     */
    case singleSelection(enableDeselection: Bool)
}

/**
 * SelectableSection实现的协议，方便定制
 * Protocol implemented by SelectableSection for easy customization
 */
public protocol  SelectableSectionType: Collection {
    associatedtype SelectableItem: SelectableItemType, ItemType
    /**
     * 单选还是多选
     * Single or multiple selection
     */
    var selectionType: SelectionType { get set }

    /**
     * 选中某一行的回调
     * Callback when a row is selected
     */
    var onSelectSelectableItem: ((SelectableItem) -> Void)? { get set }

    /**
     * 已选择的Item
     * Selected Item
     */
    func selectedItem() -> SelectableItem?
    func selectedItems() -> [SelectableItem]
}

extension  SelectableSectionType where Self: Section {
    /**
     * 获取单选的选中Item（SingleSelection使用）
     * Get selected Item for single selection (used by SingleSelection)
     */
    public func selectedItem() -> SelectableItem? {
        return selectedItems().first
    }

    /**
     * 获取多选的所有选中Item（multipleSelection使用）
     * Get all selected Items for multiple selection (used by multipleSelection)
     */
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

    /**
     * Item添加到section之前调用的函数
     * Function called before Item is added to section
     */
    func prepare(selectableItems items: [Item]) {
        var needUpdateLayout: Bool = false
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
                    if sItem.onSelectedChanged() {
                        sItem.needReSize = true
                        needUpdateLayout = true
                    }
                    s.onSelectSelectableItem?(sItem)
                }
            }
        }
        
        if needUpdateLayout {
            self.updateLayout()
        }
    }

}
