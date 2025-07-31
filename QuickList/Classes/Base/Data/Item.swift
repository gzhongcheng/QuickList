//
//  Item.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

public enum ItemCellLayoutType: Int {
    /// 垂直布局（按weight比例填充满宽度）
    case vertical = 0
    /// 横向布局（按weight比例填充满高度）
    case horizontal = 1
    /// 自由大小
    case free = 2
}

/**
 *  collectionView的item或itemBinder需要实现的协议
 */
public protocol ItemViewRepresentable {
    /// 复用的ID
    var identifier: String { get }
    
    /// 调用此方法来注册
    func regist(to view: FormViewProtocol)

    /**
     调用此方法来获取指定item相对应的cell
     
     - parameter item:    要获取view的section
     - parameter view:    所在的view
     - parameter indexPath: 位置
     
     - returns: 对应的cell
     */
    func viewForItem(_ item: Item, in view: FormViewProtocol, for indexPath: IndexPath) -> UICollectionViewCell?
    
    /// 调用此方法计算尺寸
    /// - parameter estimateItemSize: 预估尺寸，根据配置预估的一个正方形尺寸
    ///         以垂直滚动的formView为例：
    ///             QuickFlowLayout下，section共3列，item的weight为2，则这个size就是两个item的宽度加上一个间距的正方形，按需获取这个尺寸根据滚动方向计算实际尺寸（即使返回的实际宽度小于两个item的宽度，该item也会占用两列的位置）
    ///             QuickYogaLayout下, estimateItemSize返回的是item可绘制区域（即扣除formView.contentInset和section.contentInset的两边间距后的剩余宽度）的正方形尺寸
    /// - parameter view:    所在的view
    /// - parameter layoutType: 布局方式，QuickYogaLayout下值为free，其他布局下根据滚动方向设置为对应的布局方式
    func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize?
}

/// 绑定了cell类型的item
open class ItemOf<Cell: ItemCell>: Item, ItemViewRepresentable {
    public typealias ViewCreatedBlock = ((_ item: Item, _ view: Cell) -> Void)
    
    /// 从xib创建的对象传入对应的xib（将影响注册逻辑）
    internal var fromNib: UINib?
    /// 复用的ID
    open var identifier: String { "ItemCell_\(Cell.self)" }
    /// view获取到之后会走的回调（在这里设置展示逻辑）
    public var onCreated: ViewCreatedBlock?
    
    init(fromNib: UINib? = nil, onCreated: ((_ item: Self, _ view: Cell) -> Void)?) {
        self.fromNib = fromNib
        self.onCreated = { (item, view) in
            onCreated?(item as! Self, view)
        }
    }
    
    public func regist(to view: any FormViewProtocol) {
        if let fromNib = self.fromNib {
            view.register(fromNib, forCellWithReuseIdentifier: identifier)
        } else {
            view.register(Cell.self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    public func viewForItem(_ item: Item, in view: any FormViewProtocol, for indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = view.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell
        if let cell = cell {
            onCreated?(item, cell)
        }
        return cell
    }
    
    open func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        assertionFailure("需要重写此方法来设置尺寸")
        return nil
    }
    
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}

public protocol ItemViewBinderRepresentable: ItemViewRepresentable {
    /// 匹配item（判断item是否为当前binder对应的的item类型）
    func mateItem(_ item: Item) -> Bool
}

/// cell与item的绑定器
public class ItemCellBinder<I: Item, Cell: ItemCell>: ItemViewBinderRepresentable {
    public typealias ViewCreatedBlock = ((_ item: I, _ view: Cell) -> Void)
    public typealias SizeBlock = ((_ item: I, _ estimateItemSize: CGSize, _ view: FormViewProtocol, _ layoutType: ItemCellLayoutType) -> CGSize)
    
    /// 从xib创建的对象传入对应的xib（将影响注册逻辑）
    private var fromNib: UINib?
    /// item类型
    public var itemClass: any AnyObject.Type {
        I.self
    }
    /// 复用的ID
    public var identifier: String = "ItemCell_\(Cell.self)"
    /// 计算尺寸的回调
    public var onSizeGet: SizeBlock
    /// view获取到之后会走的回调（在这里设置展示逻辑）
    public var onCreated: ViewCreatedBlock?
    
    init(fromNib: UINib? = nil, onSizeGet: @escaping SizeBlock, onCreated: ViewCreatedBlock? = nil) {
        self.fromNib = fromNib
        self.onSizeGet = onSizeGet
        self.onCreated = onCreated
    }
    
    /// 调用此方法来注册
    public func regist(to view: FormViewProtocol) {
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
     
     - parameter item:    要获取view的section
     - parameter view:    所在的view
     - parameter indexPath: 位置
     
     - returns: 对应的cell
     */
    public func viewForItem(_ item: Item, in view: FormViewProtocol, for indexPath: IndexPath) -> UICollectionViewCell? {
        guard let item = item as? I else { return nil }
        let cell = view.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell
        if let cell = cell {
            onCreated?(item, cell)
        }
        return cell
    }
    
    /// 调用此方法计算尺寸
    public func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard let item = item as? I else { return nil }
        return onSizeGet(item, estimateItemSize, view, layoutType)
    }
    
    /// 匹配item（判断item是否为当前binder对应的的item类型）
    public func mateItem(_ item: Item) -> Bool {
        item is I
    }
}


open class Item: NSObject {
    /// Item所在的Section
    public internal(set) weak var section: Section?
    /// Item所对应的cell
    public internal(set) weak var cell: ItemCell?
    
    /// 是否需要重新计算尺寸
    public var needReSize: Bool = true
    
    /// Item的title(可用于展示)
    public var title: String?
    /// 标记item的唯一标识，同一个Section中的item的tag建议不要设置相同
    public var tag: String?
    
    /// cell的权重（如：在flowLayout中表示cell的尺寸占几列，默认为1）
    public var weight: Int = 1
    /// cell 的尺寸的缓存
    public var cellSize: CGSize = .zero
    
    /// cell背景色
    public var backgroundColor: UIColor = .clear
    /// 背景色
    public var contentBgColor: UIColor = .clear
    /// 内容边距，仅做为预留属性，具体边距的实现逻辑需要item自行处理
    open var contentInsets: UIEdgeInsets = .zero
    
    /// 是否不可点击
    public var isDisabled: Bool = false
    /// 是否隐藏
    public var isHidden: Bool = false
    /// 是否可选中
    public var isSelectable: Bool = true
    /// 选中（可在update中根据选中状态进行一些样式设置）
    public var isSelected: Bool = false
    /// 选中时是否滚动到item位置
    public var scrollToSelected: Bool = false
    /// 是否可以移动
    open var canMove: Bool = false
    
    /// 获取当前列表的滚动方向
    public var scrollDirection: UICollectionView.ScrollDirection {
        return section?.form?.delegate?.scrollDirection ?? .vertical
    }
    /// 获取IndexPath
    public final var indexPath: IndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.firstIndex(of: self) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    /// 数据改变后的回调
    var callbackOnDataChange: (() -> Void)?
    /// cell更新后的回调
    var callbackCellUpdate: (() -> Void)?
    /// cell选中回调
    var callbackCellOnSelection: (() -> Void)?
    /// cell高亮（成为第一响应者）回调
    var callbackOnCellHighlightChanged: (() -> Void)?
    /// cell结束编辑的回调，可以在这里进行value验证等操作
    var callbackOnCellEndEditing: (() -> Void)?
    
    // MARK: - 事件
    /// cell选中时调用，子类中重写可以在选中时改变item的状态等
    open func customDidSelect() {}
    /// 更新Cell时调用，子类中重写可以联动其他效果
    open func customUpdateCell() {
        guard let cell = self.cell else {
            return
        }
        cell.contentView.isUserInteractionEnabled = !isDisabled
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = contentBgColor
    }
    /// cell高亮时调用，子类中重写可联动其他事件
    open func customHighlightCell() {}
    /// cell结束高亮时调用，子类中重写可联动其他事件
    open func customUnHighlightCell() {}
    /// 选中状态改变时调用，子类中重写更新选中状态
    /// - Returns: 状态切换时是否需要更新布局（如：字体变化导致尺寸变化，需要更新布局，就返回true）
    open func onSelectedChanged() -> Bool { return false }
    /// 点击选中事件
    open func didSelect() {
        if !isDisabled {
            cell?.didSelect()
            customDidSelect()
            callbackCellOnSelection?()
        }
    }
    /// 更新Cell的内容
    open func updateCell() {
        customUpdateCell()
        callbackCellUpdate?()
    }
    /// Cell高亮
    open func highlightCell() {
        if !isDisabled {
            cell?.isHighlighted = true
            customHighlightCell()
            callbackOnCellHighlightChanged?()
        }
    }
    /// Cell取消高亮
    open func unHighlightCell() {
        cell?.isHighlighted = false
        customUnHighlightCell()
        callbackOnCellHighlightChanged?()
    }
    
    /// 展示 / 结束展示
    public var isShow: Bool = false
    open func willDisplay() {
        isShow = true
    }
    open func didEndDisplay() {
        isShow = false
    }
    
    /// 刷新界面布局
    public func updateLayout(animation: Bool = false) {
        section?.form?.delegate?.updateLayout(withAnimation: animation, afterSection: self.section?.index ?? 0)
    }
    
    /// 初始化
    public required init(title: String? = nil, tag: String? = nil) {
        self.tag = tag
        self.title = title
    }
}

// MARK: - Item的初始化协议
public protocol ItemType: AnyObject {
    init(_ title: String?, tag: String?, weight: Int, _ initializer: (Self) -> Void)
}

extension ItemType where Self: Item {
    /**
     默认的初始化方法
     */
    public init(_ title: String? = nil, tag: String? = nil, weight: Int = 1, _ initializer: (Self) -> Void = { _ in }) {
        self.init(title: title, tag: tag)
        self.weight = weight
        initializer(self)
    }
}

// MARK: - Item的各种回调事件
extension ItemType where Self: Item {
    // 高亮时的回调
    @discardableResult
    public func onCellHighlightChanged(_ callback: @escaping (_ item: Self) -> Void) -> Self {
        callbackOnCellHighlightChanged = { [weak self] in callback(self!) }
        return self
    }
    
    // 设置选中回调
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
    
    // 设置update回调
    @discardableResult
    public func onCellUpdate(_ callback: @escaping ((_ item: Self) -> Void)) -> Self {
        callbackCellUpdate = { [weak self] in  callback(self!) }
        return self
    }
    
    // 设置value改变时的回调
    @discardableResult
    public func onValueChanged(_ callback: @escaping (_ item: Self) -> Void) -> Self {
        callbackOnDataChange = { [weak self] in callback(self!) }
        return self
    }
}

/// 获取真实的item
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
