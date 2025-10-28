//
//  Item.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

public enum ItemCellLayoutType: Int {
    /**
     * 垂直布局（按weight比例填充满宽度）
     * Vertical layout (fills width according to weight ratio)
     */
    case vertical = 0
    /**
     * 横向布局（按weight比例填充满高度）
     * Horizontal layout (fills height according to weight ratio)
     */
    case horizontal = 1
    /**
     * 自由大小
     * Free size
     */
    case free = 2
}

/**
 *  collectionView的item或itemBinder需要实现的协议
 *  Protocol that collectionView items or itemBinders need to implement
 */
public protocol ItemViewRepresentable {
    /**
     * 复用的ID
     * Reuse identifier
     */
    var identifier: String { get }
    
    /**
     * 调用此方法来注册
     * Call this method to register
     */
    func regist(to view: QuickListView)

    /**
     调用此方法来获取指定item相对应的cell
     Call this method to get the cell corresponding to the specified item
     
     - parameter item:    要获取view的section
     - parameter view:    所在的view
     - parameter indexPath: 位置
     - parameter item:    Section to get view for
     - parameter view:    The view it belongs to
     - parameter indexPath: Position
     
     - returns: 对应的cell
     - returns: Corresponding cell
     */
    func viewForItem(_ item: Item, in view: QuickListView, for indexPath: IndexPath) -> UICollectionViewCell?
    
    /**
     * 调用此方法计算尺寸
     * Call this method to calculate size
     * 
     * - parameter estimateItemSize: 预估尺寸，根据配置预估的一个正方形尺寸
     *         以垂直滚动的formView为例：
     *             QuickFlowLayout下，section共3列，item的weight为2，则这个size就是两个item的宽度加上一个间距的正方形，按需获取这个尺寸根据滚动方向计算实际尺寸（即使返回的实际宽度小于两个item的宽度，该item也会占用两列的位置）
     *             QuickYogaLayout下, estimateItemSize返回的是item可绘制区域（即扣除formView.contentInset和section.contentInset的两边间距后的剩余宽度）的正方形尺寸
     * - parameter view:    所在的view
     * - parameter layoutType: 布局方式，QuickYogaLayout下值为free，其他布局下根据滚动方向设置为对应的布局方式

     * - parameter estimateItemSize: Estimated size, a square size estimated based on configuration
     *         Taking a vertically scrolling formView as an example:
     *             Under QuickFlowLayout, if the section has 3 columns and the item's weight is 2, then this size is a square of two item widths plus one spacing. Get this size as needed and calculate the actual size based on scroll direction (even if the returned actual width is less than two item widths, the item will occupy two column positions)
     *             Under QuickYogaLayout, estimateItemSize returns the square size of the item's drawable area (i.e., the remaining width after deducting the left and right spacing of formView.contentInset and section.contentInset)
     * - parameter view:    The view it belongs to
     * - parameter layoutType: Layout method, free under QuickYogaLayout, set to corresponding layout method based on scroll direction under other layouts
     */
    func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize?
}

/**
 * 绑定了cell类型的item
 * Item bound to cell type
 */
open class ItemOf<Cell: ItemCell>: Item, ItemViewRepresentable {
    public typealias ViewCreatedBlock = ((_ item: Item, _ view: Cell) -> Void)
    
    /**
     * 从xib创建的对象传入对应的xib（将影响注册逻辑）
     * Pass the corresponding xib for objects created from xib (will affect registration logic)
     */
    internal var fromNib: UINib?
    /**
     * 复用的ID
     * Reuse identifier
     */
    open var identifier: String { "ItemCell_\(Cell.self)" }
    /**
     * view获取到之后会走的回调（在这里设置展示逻辑）
     * Callback that will be called after view is obtained (set display logic here)
     */
    public var onCreated: ViewCreatedBlock?
    
    init(fromNib: UINib? = nil, onCreated: ((_ item: Self, _ view: Cell) -> Void)?) {
        self.fromNib = fromNib
        self.onCreated = { (item, view) in
            onCreated?(item as! Self, view)
        }
    }
    
    public func regist(to view: QuickListView) {
        if let fromNib = self.fromNib {
            view.register(fromNib, forCellWithReuseIdentifier: identifier)
        } else {
            view.register(Cell.self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    public func viewForItem(_ item: Item, in view: QuickListView, for indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = view.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell
        if let cell = cell {
            onCreated?(item, cell)
        }
        return cell
    }
    
    open func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        assertionFailure("Need to override this method to set size")
        return nil
    }
    
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}

public protocol ItemViewBinderRepresentable: ItemViewRepresentable {
    /**
     * 匹配item（判断item是否为当前binder对应的的item类型）
     * Match item (determine if item is the item type corresponding to current binder)
     */
    func mateItem(_ item: Item) -> Bool
}

/**
 * cell与item的绑定器
 * Binder between cell and item
 */
public class ItemCellBinder<I: Item, Cell: ItemCell>: ItemViewBinderRepresentable {
    public typealias ViewCreatedBlock = ((_ item: I, _ view: Cell) -> Void)
    public typealias SizeBlock = ((_ item: I, _ estimateItemSize: CGSize, _ view: QuickListView, _ layoutType: ItemCellLayoutType) -> CGSize)
    
    /**
     * 从xib创建的对象传入对应的xib（将影响注册逻辑）
     * Pass the corresponding xib for objects created from xib (will affect registration logic)
     */
    private var fromNib: UINib?
    /**
     * item类型
     * Item type
     */
    public var itemClass: any AnyObject.Type {
        I.self
    }
    /**
     * 复用的ID
     * Reuse identifier
     */
    public var identifier: String = "ItemCell_\(Cell.self)"
    /**
     * 计算尺寸的回调
     * Callback for calculating size
     */
    public var onSizeGet: SizeBlock
    /**
     * view获取到之后会走的回调（在这里设置展示逻辑）
     * Callback that will be called after view is obtained (set display logic here)
     */
    public var onCreated: ViewCreatedBlock?
    
    init(fromNib: UINib? = nil, onSizeGet: @escaping SizeBlock, onCreated: ViewCreatedBlock? = nil) {
        self.fromNib = fromNib
        self.onSizeGet = onSizeGet
        self.onCreated = onCreated
    }
    
    /**
     * 调用此方法来注册
     * Call this method to register
     */
    public func regist(to view: QuickListView) {
        if let fromNib = self.fromNib {
            view.register(fromNib, forCellWithReuseIdentifier: identifier)
        } else {
            view.register(Cell.self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    open func updateCell() {
    }

    /**
     调用此方法来获取指定item相对应的cell
     Call this method to get the cell corresponding to the specified item
     
     - parameter item:    要获取view的section
     - parameter view:    所在的view
     - parameter indexPath: 位置
     - parameter item:    Section to get view for
     - parameter view:    The view it belongs to
     - parameter indexPath: Position
     
     - returns: 对应的cell
     - returns: Corresponding cell
     */
    public func viewForItem(_ item: Item, in view: QuickListView, for indexPath: IndexPath) -> UICollectionViewCell? {
        guard let item = item as? I else { return nil }
        let cell = view.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell
        if let cell = cell {
            onCreated?(item, cell)
        }
        return cell
    }
    
    /**
     * 调用此方法计算尺寸
     * Call this method to calculate size
     */
    public func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard let item = item as? I else { return nil }
        return onSizeGet(item, estimateItemSize, view, layoutType)
    }
    
    /**
     * 匹配item（判断item是否为当前binder对应的的item类型）
     * Match item (determine if item is the item type corresponding to current binder)
     */
    public func mateItem(_ item: Item) -> Bool {
        item is I
    }
}


open class Item: NSObject {
    /**
     * Item所在的Section
     * Section where Item belongs
     */
    public internal(set) weak var section: Section?
    /**
     * Item所对应的cell
     * Cell corresponding to Item
     */
    public internal(set) weak var cell: ItemCell?
    
    /**
     * 是否需要重新计算尺寸
     * Whether size recalculation is needed
     */
    public var needReSize: Bool = true
    
    /**
     * Item的title(可用于展示)
     * Item's title (can be used for display)
     */
    public var title: String?
    /**
     * 标记item的唯一标识，同一个Section中的item的tag建议不要设置相同
     * Unique identifier for item, it's recommended not to set the same tag for items in the same Section
     */
    public var tag: String?
    
    /**
     * cell的权重（如：在flowLayout中表示cell的尺寸占几列，默认为1）
     * Cell's weight (e.g., in flowLayout represents how many columns the cell's size occupies, default is 1)
     */
    public var weight: Int = 1
    /**
     * cell 的尺寸的缓存
     * Cache of cell's size
     */
    public var cellSize: CGSize = .zero
    
    /**
     * cell背景色
     * Cell background color
     */
    public var backgroundColor: UIColor = .clear
    /**
     * 背景色
     * Background color
     */
    public var contentBgColor: UIColor = .clear
    /**
     * 内容边距，仅做为预留属性，具体边距的实现逻辑需要item自行处理
     * Content insets, only as a reserved property, specific insets implementation logic needs to be handled by item itself
     */
    open var contentInsets: UIEdgeInsets = .zero
    
    /**
     * 是否不可点击
     * Whether not clickable
     */
    public var isDisabled: Bool = false
    /**
     * 是否隐藏
     * Whether hidden
     */
    public var isHidden: Bool = false
    /**
     * 是否可选中
     * Whether selectable
     */
    public var isSelectable: Bool = true
    /**
     * 选中（可在update中根据选中状态进行一些样式设置）
     * Selected (can perform some style settings based on selected state in update)
     */
    public var isSelected: Bool = false
    /**
     * 选中时是否滚动到item位置
     * Whether to scroll to item position when selected
     */
    public var scrollToSelected: Bool = false
    /**
     * 是否可以移动
     * Whether movable
     */
    open var canMove: Bool = false
    
    /**
     * 获取当前列表的滚动方向
     * Get current list's scroll direction
     */
    public var scrollDirection: UICollectionView.ScrollDirection {
        return section?.form?.delegate?.scrollDirection ?? .vertical
    }
    /**
     * 获取IndexPath
     * Get IndexPath
     */
    public final var indexPath: IndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.firstIndex(of: self) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    /**
     * 数据改变后的回调
     * Callback after data change
     */
    var callbackOnDataChange: (() -> Void)?
    /**
     * cell更新后的回调
     * Callback after cell update
     */
    var callbackCellUpdate: (() -> Void)?
    /**
     * cell选中回调
     * Cell selection callback
     */
    var callbackCellOnSelection: (() -> Void)?
    /**
     * cell高亮（成为第一响应者）回调
     * Cell highlight (becoming first responder) callback
     */
    var callbackOnCellHighlightChanged: (() -> Void)?
    /**
     * cell结束编辑的回调，可以在这里进行value验证等操作
     * Callback when cell ends editing, can perform value validation and other operations here
     */
    var callbackOnCellEndEditing: (() -> Void)?
    
    // MARK: - Events
    /**
     * cell选中时调用，子类中重写可以在选中时改变item的状态等
     * Called when cell is selected, subclasses can override to change item state when selected
     */
    open func customDidSelect() {}
    /**
     * 更新Cell时调用，子类中重写可以联动其他效果
     * Called when updating Cell, subclasses can override to link other effects
     */
    open func customUpdateCell() {
        guard let cell = self.cell else {
            return
        }
        cell.contentView.isUserInteractionEnabled = !isDisabled
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = contentBgColor
    }
    /**
     * cell高亮时调用，子类中重写可联动其他事件
     * Called when cell is highlighted, subclasses can override to link other events
     */
    open func customHighlightCell() {}
    /**
     * cell结束高亮时调用，子类中重写可联动其他事件
     * Called when cell ends highlighting, subclasses can override to link other events
     */
    open func customUnHighlightCell() {}
    /**
     * 选中状态改变时调用，子类中重写更新选中状态
     * Called when selection state changes, subclasses can override to update selection state
     */
    /**
     * - Returns: 状态切换时是否需要更新布局（如：字体变化导致尺寸变化，需要更新布局，就返回true）
     * - Returns: Whether layout update is needed when state changes (e.g., font change causes size change, need to update layout, return true)
     */
    open func onSelectedChanged() -> Bool { return false }
    /**
     * 点击选中事件
     * Click selection event
     */
    open func didSelect() {
        if !isDisabled {
            cell?.didSelect()
            customDidSelect()
            callbackCellOnSelection?()
        }
    }
    /**
     * 更新Cell的内容
     * Update Cell content
     */
    open func updateCell() {
        customUpdateCell()
        callbackCellUpdate?()
    }
    /**
     * Cell高亮
     * Cell highlight
     */
    open func highlightCell() {
        if !isDisabled {
            cell?.isHighlighted = true
            customHighlightCell()
            callbackOnCellHighlightChanged?()
        }
    }
    /**
     * Cell取消高亮
     * Cell unhighlight
     */
    open func unHighlightCell() {
        cell?.isHighlighted = false
        customUnHighlightCell()
        callbackOnCellHighlightChanged?()
    }
    
    /**
     * 展示 / 结束展示
     * Display / End display
     */
    public var isShow: Bool = false
    open func willDisplay() {
        isShow = true
    }
    open func didEndDisplay() {
        isShow = false
    }

    /**
     * 刷新界面布局,可以指定进入动画类型
     * Refresh interface layout, can specify enter animation type
     */
    public func updateLayout(animation: ListReloadAnimation? = nil) {
        section?.updateLayout(animation: animation)
    }
    
    /**
     * 初始化
     * Initialization
     */
    public required init(title: String? = nil, tag: String? = nil) {
        self.tag = tag
        self.title = title
    }
    
    /**
     * 从列表中动画删除
     * Animated deletion from list
     */
    public func removeFromSection(animation: ListReloadAnimation? = ListReloadAnimation.fade) {
        guard let section = self.section else { return }
        section.deleteItems(with: [self], animation: animation)
    }
}

// MARK: - Item initialization protocol
public protocol ItemType: AnyObject {
    init(_ title: String?, tag: String?, weight: Int, _ initializer: (Self) -> Void)
}

extension ItemType where Self: Item {
    /**
     默认的初始化方法
     Default initialization method
     */
    public init(_ title: String? = nil, tag: String? = nil, weight: Int = 1, _ initializer: (Self) -> Void = { _ in }) {
        self.init(title: title, tag: tag)
        self.weight = weight
        initializer(self)
    }
}

// MARK: - Various callback events for Item
extension ItemType where Self: Item {
    /**
     * 高亮时的回调
     * Callback when highlighted
     */
    @discardableResult
    public func onCellHighlightChanged(_ callback: @escaping (_ item: Self) -> Void) -> Self {
        callbackOnCellHighlightChanged = { [weak self] in callback(self!) }
        return self
    }
    
    /**
     * 设置选中回调
     * Set selection callback
     */
    @discardableResult
    public func onCellSelection(_ callback: @escaping ((_ item: Self) -> Void)) -> Self {
        callbackCellOnSelection = { [weak self] in
            guard
                let r = self
            else {
                return
            }
            callback(r)
        }
        return self
    }
    
    /**
     * 设置update回调
     * Set update callback
     */
    @discardableResult
    public func onCellUpdate(_ callback: @escaping ((_ item: Self) -> Void)) -> Self {
        callbackCellUpdate = { [weak self] in  callback(self!) }
        return self
    }
    
    /**
     * 设置value改变时的回调
     * Set callback when value changes
     */
    @discardableResult
    public func onValueChanged(_ callback: @escaping (_ item: Self) -> Void) -> Self {
        callbackOnDataChange = { [weak self] in callback(self!) }
        return self
    }
}

/**
 * Get real item
 * 获取真实的item
 */
extension Item {
    func representableItem() -> (any ItemViewRepresentable)? {
        var representableItem: (any ItemViewRepresentable)?
        if let item = self as? (any ItemViewRepresentable) {
            representableItem = item
        } else if let binder = self.section?.itemCellBinders.first(where: { $0.mateItem(self) }) {
            representableItem = binder
        } else if let binder = self.section?.form?.itemCellBinders.first(where: { $0.mateItem(self) }) {
            representableItem = binder
        }
        return representableItem
    }
}
