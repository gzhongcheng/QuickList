//
//  QuickListScrollView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit
import SnapKit

// MARK: - Type Alias for Backwards Compatibility

/// 向后兼容的类型别名
/// Type alias for backwards compatibility
public typealias QuickListView = QuickListScrollView

/// 向后兼容的 FormViewHandler 类型别名
/// Type alias for FormViewHandler for backwards compatibility
public typealias FormViewHandler = QuickListScrollViewHandler

// MARK: - QuickListScrollView

/// 基于 QuickScrollView 的新版列表视图
/// New list view based on QuickScrollView
open class QuickListScrollView: QuickScrollView {
    
    // MARK: - Properties
    
    /// 当前装饰控件
    /// Current decoration control
    var currentDecorationView: UIView?
    
    /// 当前全局背景
    /// Current global background
    var currentBackgroundView: UIView?
    
    /// handler代理
    /// Handler delegate
    public weak var handerDelegate: FormViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    /// collectionView代理处理类
    /// CollectionView delegate handler class
    public var handler = QuickListScrollViewHandler()
    
    /// 重用管理器（公开给外部使用）
    /// Reuse manager (exposed for external use)
    public let reuseManager = QuickScrollViewReuseManager()
    
    /// 数据表单
    /// Data form
    public var form: Form {
        get { handler.form }
        set { handler.form = newValue }
    }
    
    /// 滚动方向
    /// Scroll direction
    open override var scrollDirection: UICollectionView.ScrollDirection {
        didSet {
            handler.scrollDirection = scrollDirection
        }
    }
    
    /// 列表总尺寸变化回调
    /// List total size change callback
    public var listSizeChangedBlock: ((CGSize) -> Void)?
    
    /// 当前内容尺寸
    /// Current content size
    private var currentContentSize: CGSize = .zero
    
    /// 动画器
    /// Animator
    public let animator = QuickScrollViewAnimator()
    
    // MARK: - Visible Views Management
    
    /// 当前可见的 Cells
    /// Currently visible cells
    public private(set) var visibleItemCells: [IndexPath: ItemCell] = [:]
    
    /// 当前可见的补充视图
    /// Currently visible supplementary views
    public private(set) var visibleReusableViews: [String: [IndexPath: QuickScrollViewReusableView]] = [:]
    
    // MARK: - Initialization
    
    public convenience init(sections: [Section]? = nil) {
        self.init(frame: .zero)
        if let sections = sections {
            form.append(contentsOf: sections)
        }
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        defaultSettings()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultSettings()
    }
    
    open func defaultSettings() {
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        handler.scrollView = self
        dataSourceDelegate = handler
        scrollViewDelegate = handler
        // 不使用 animationDelegate，动画在 scrollViewDelegate.willDisplay 中处理
        // Don't use animationDelegate, animation is handled in scrollViewDelegate.willDisplay
        animationDelegate = nil
        
        // 设置布局
        // Setup layout
        let layoutAdapter = QuickScrollViewLayoutAdapter(collectionLayout: handler.layout)
        layout = layoutAdapter
        
        handler.layout.add(self)
    }
    
    // MARK: - Public Methods
    
    /// 添加全局装饰控件
    /// Add global decoration control
    public func addDecorationViewIfNeeded(_ view: UIView) {
        if currentDecorationView != nil, currentDecorationView == view {
            return
        }
        if currentDecorationView != view {
            currentDecorationView?.removeFromSuperview()
        }
        contentContainerView.addSubview(view)
        currentDecorationView = view
    }
    
    /// 添加全局背景
    /// Add global background
    public func addBackgroundViewIfNeeded(_ view: UIView?) {
        if currentBackgroundView != nil, currentBackgroundView == view {
            return
        }
        if currentBackgroundView != view {
            currentBackgroundView?.removeFromSuperview()
        }
        guard let view = view else { return }
        view.layer.zPosition = 0
        contentContainerView.insertSubview(view, at: 0)
        currentBackgroundView = view
    }
    
    /// 滚动到指定 Item
    /// Scroll to item
    public func scrollToItem(_ item: Item, at scrollPosition: UICollectionView.ScrollPosition, animation: Bool) {
        guard let indexPath = item.indexPath else { return }
        self.scrollToItem(at: indexPath, at: scrollPosition, animated: animation)
    }
    
    /// 选中 Item
    /// Select item
    public func selectItem(item: Item) {
        handler.selectItem(item: item)
    }
    
    /// 获取指定 IndexPath 的 Cell
    /// Get cell at IndexPath
    public override func cellForItem(at indexPath: IndexPath) -> ItemCell? {
        return visibleItemCells[indexPath]
    }
    
    /// 获取所有可见 Cells
    /// Get all visible cells
    public var visibleCellsList: [ItemCell] {
        return Array(visibleItemCells.values)
    }
    
    // MARK: - Layout
    
    private var needReload = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var needUpdateLayout = true
    private var updateLayoutInAnimation: ListReloadAnimation?
    private var firstUpdateSection: Int = .max
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if needReload {
            needReload = false
            reload()
            needUpdateLayout = false
            firstUpdateSection = .max
        } else if needUpdateLayout, firstUpdateSection < form.count {
            handler.updateLayout(sections: nil, othersInAnimation: updateLayoutInAnimation)
            firstUpdateSection = .max
            updateLayoutInAnimation = nil
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            if oldValue.size != bounds.size {
                if bounds.size.width == 0 || bounds.size.height == 0 {
                    return
                }
                // 如果之前尺寸为零，现在有有效尺寸，需要触发完整 reload
                // If previous size was zero and now has valid size, trigger full reload
                if oldValue.size == .zero || oldValue.size.width == 0 || oldValue.size.height == 0 {
                    needReload = true
                } else {
                    handler.layout.reloadAll()
                }
            }
        }
    }
    
    /// 设置需要更新布局
    /// Set need update layout
    public func setNeedUpdateLayout(afterSection: Int, animation: ListReloadAnimation? = nil) {
        needUpdateLayout = true
        firstUpdateSection = min(firstUpdateSection, afterSection)
        updateLayoutInAnimation = animation ?? updateLayoutInAnimation
        setNeedsLayout()
    }
    
    /// 标记需要重新加载
    /// Mark needs reload
    public func setNeedsReloadData() {
        needReload = true
    }
    
    /// 重新加载数据
    /// Reload data
    public func reload() {
        if superview == nil {
            needReload = true
            return
        }
        if bounds.size == .zero {
            needReload = true
            return
        }
        handler.reloadScrollView()
    }
    
    // MARK: - Cell Management
    
    /// 回收所有 Cell
    /// Recycle all cells
    func recycleAllCells() {
        for (_, cell) in visibleItemCells {
            cell.didEndDisplay()
            cell.item?.didEndDisplay()
            cell.removeFromSuperview()
            reuseManager.recycleCell(cell)
        }
        visibleItemCells.removeAll()
        
        // 回收所有补充视图
        // Recycle all supplementary views
        for (_, views) in visibleReusableViews {
            for (_, view) in views {
                view.removeFromSuperview()
                reuseManager.recycleReusableView(view)
            }
        }
        visibleReusableViews.removeAll()
    }
    
    /// 回收指定 Cell
    /// Recycle specific cell
    func recycleCell(at indexPath: IndexPath) {
        guard let cell = visibleItemCells.removeValue(forKey: indexPath) else { return }
        cell.didEndDisplay()
        cell.item?.didEndDisplay()
        cell.removeFromSuperview()
        reuseManager.recycleCell(cell)
    }
    
    /// 添加 Cell
    /// Add cell
    func addCell(_ cell: ItemCell, at indexPath: IndexPath) {
        cell.indexPath = indexPath
        visibleItemCells[indexPath] = cell
        contentContainerView.addSubview(cell)
    }
    
    /// 添加补充视图
    /// Add supplementary view
    func addSupplementaryView(_ view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath) {
        if visibleReusableViews[kind] == nil {
            visibleReusableViews[kind] = [:]
        }
        visibleReusableViews[kind]?[indexPath] = view
        contentContainerView.addSubview(view)
    }
    
    /// 获取补充视图
    /// Get supplementary view
    func supplementaryView(ofKind kind: String, at indexPath: IndexPath) -> QuickScrollViewReusableView? {
        return visibleReusableViews[kind]?[indexPath]
    }
}

// MARK: - QuickListCollectionLayoutDelegate

extension QuickListScrollView: QuickListCollectionLayoutDelegate {
    public func collectionLayoutDidFinishLayout(_ layout: QuickListCollectionLayout) {
        let newContentSize = layout.collectionViewContentSize
        if currentContentSize != newContentSize {
            currentContentSize = newContentSize
            contentSize = newContentSize
            contentContainerView.frame = CGRect(origin: .zero, size: newContentSize)
            listSizeChangedBlock?(newContentSize)
        }
    }
}

// MARK: - FormViewLongTapProtorol

extension QuickListScrollView: FormViewLongTapProtorol {
    
    /// 长按手势位置获取indexPath
    /// Get indexPath for long press gesture position
    public func indexPathForItem(at point: CGPoint) -> IndexPath? {
        for (indexPath, cell) in visibleItemCells {
            if cell.frame.contains(point) {
                return indexPath
            }
        }
        return nil
    }
    
    /// 开始移动item
    /// Begin moving item
    public func beginInteractiveMovementForItem(at indexPath: IndexPath) -> Bool {
        // TODO: 实现交互式移动
        // TODO: Implement interactive movement
        return false
    }
    
    /// 移动过程
    /// Movement process
    public func updateInteractiveMovementTargetPosition(_ targetPosition: CGPoint) {
        // TODO: 实现移动位置更新
        // TODO: Implement movement position update
    }
    
    /// 移动结束
    /// Movement end
    public func endInteractiveMovement() {
        // TODO: 实现移动结束
        // TODO: Implement movement end
    }
    
    /// 移动取消
    /// Movement cancel
    public func cancelInteractiveMovement() {
        // TODO: 实现移动取消
        // TODO: Implement movement cancel
    }
}

// MARK: - QuickListScrollViewHandler

/// 处理器，负责管理数据源和代理
/// Handler, responsible for managing data source and delegate
public class QuickListScrollViewHandler: NSObject {
    
    // MARK: - Properties
    
    public var form: Form = Form() {
        didSet {
            form.delegate = self
        }
    }
    
    public weak var scrollView: QuickListScrollView?
    
    public private(set) var layout: QuickListCollectionLayout = QuickListCollectionLayout()
    
    public weak var delegate: FormViewHandlerDelegate?
    
    /// 已注册的标识符
    /// Registered identifiers
    var registedFormHeaderIdentifier = [String]()
    var registedFormFooterIdentifier = [String]()
    var registedHeaderIdentifier = [String]()
    var registedFooterIdentifier = [String]()
    var registedDecorationIdentifier = [String]()
    var registedSuspensionDecorationIdentifier = [String]()
    var registedCellIdentifier = [String]()
    
    /// 当前左滑展开的 cell
    /// Currently opened swipe cell
    public var currentOpenedSwipeCell: SwipeItemCell?
    
    /// 滚动方向
    /// Scroll direction
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            layout.scrollDirection = scrollDirection
            reloadScrollView()
        }
    }
    
    /// 是否正在滚动
    /// Whether is scrolling
    public var isScrolling: Bool = false
    
    /// 当前动画状态
    /// Current animation state
    private var currentUpdateSections: [Section]?
    private var currentUpdateSectionInAnimation: ListReloadAnimation?
    private var currentUpdateOthersInAnimation: ListReloadAnimation?
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        form.delegate = self
        layout.form = form
    }
    
    // MARK: - Public Methods
    
    /// 刷新数据
    /// Reload data
    public func reloadScrollView() {
        scrollView?.recycleAllCells()
        scrollView?.reloadData()
        layout.reloadAll()
        updateSelectedItemDecorationIfNeeded()
    }
    
    /// 更新布局
    /// Update layout
    public func updateLayout() {
        layout.reloadAll()
    }
    
    /// 更新背景装饰
    /// Update background decoration
    public func updateBackgroundDecoration(contentSize: CGSize) {
        scrollView?.addBackgroundViewIfNeeded(form.backgroundDecoration)
        form.backgroundDecoration?.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    /// 更新选中状态装饰
    /// Update selected item decoration
    public func updateSelectedItemDecorationIfNeeded() {
        var indexPath: IndexPath?
        var isItemHidden = false
        
        for section in form.sections {
            for item in section.items {
                if item.isSelected {
                    indexPath = item.indexPath
                    isItemHidden = item.isHidden
                    break
                }
            }
            if indexPath != nil {
                break
            }
        }
        
        guard
            let selectedItemDecoration = form.selectedItemDecoration,
            let scrollView = scrollView,
            let indexPath = indexPath,
            let layoutAttributes = layout.layoutAttributesForItem(at: indexPath)
        else {
            form.selectedItemDecoration?.alpha = 0
            return
        }
        
        scrollView.addDecorationViewIfNeeded(selectedItemDecoration)
        
        if selectedItemDecoration.bounds.width == 0 {
            selectedItemDecoration.frame = layoutAttributes.frame
            selectedItemDecoration.alpha = 0
            scrollView.layoutIfNeeded()
        }
        
        let targetZPosition = form.selectedItemDecorationPosition == .below ? CGFloat(layoutAttributes.zIndex) - 1 : CGFloat(layoutAttributes.zIndex) + 1
        
        if selectedItemDecoration.layer.zPosition != targetZPosition {
            UIView.animate(withDuration: form.selectedItemDecorationMoveDuration) {
                selectedItemDecoration.alpha = 0
                scrollView.layoutIfNeeded()
            } completion: { _ in
                selectedItemDecoration.layer.zPosition = targetZPosition
                selectedItemDecoration.frame = layoutAttributes.frame
                scrollView.layoutIfNeeded()
                UIView.animate(withDuration: self.form.selectedItemDecorationMoveDuration) {
                    selectedItemDecoration.alpha = isItemHidden ? 0 : 1
                    scrollView.layoutIfNeeded()
                }
            }
        } else {
            UIView.animate(withDuration: form.selectedItemDecorationMoveDuration) {
                selectedItemDecoration.alpha = isItemHidden ? 0 : 1
                selectedItemDecoration.frame = layoutAttributes.frame
                selectedItemDecoration.layer.zPosition = targetZPosition
                scrollView.layoutIfNeeded()
            }
        }
    }
    
    /// 根据位置更新选中装饰视图（支持滑动时的动态更新）
    /// Update selected item decoration to position (supports dynamic update during scrolling)
    public func updateSelectedItemDecorationTo(position: CGFloat) {
        guard
            let selectedItemDecoration = form.selectedItemDecoration,
            let scrollView = scrollView
        else {
            return
        }
        
        let floorIndex = Int(floor(position))
        let ceilIndex = Int(ceil(position))
        let progress = position - CGFloat(floorIndex)
        
        // 获取两个位置的 item
        // Get items at both positions
        var fromItem: Item?
        var toItem: Item?
        
        for section in form.sections {
            for (index, item) in section.items.enumerated() {
                if index == floorIndex {
                    fromItem = item
                }
                if index == ceilIndex {
                    toItem = item
                }
            }
        }
        
        guard
            let fromIndexPath = fromItem?.indexPath,
            let fromAttributes = layout.layoutAttributesForItem(at: fromIndexPath)
        else {
            form.selectedItemDecoration?.alpha = 0
            return
        }
        
        scrollView.addDecorationViewIfNeeded(selectedItemDecoration)
        
        // 计算插值后的 frame
        // Calculate interpolated frame
        var targetFrame = fromAttributes.frame
        
        if let toIndexPath = toItem?.indexPath,
           let toAttributes = layout.layoutAttributesForItem(at: toIndexPath) {
            // 线性插值计算位置
            // Linear interpolation for position
            targetFrame.origin.x = fromAttributes.frame.origin.x + (toAttributes.frame.origin.x - fromAttributes.frame.origin.x) * progress
            targetFrame.origin.y = fromAttributes.frame.origin.y + (toAttributes.frame.origin.y - fromAttributes.frame.origin.y) * progress
            targetFrame.size.width = fromAttributes.frame.width + (toAttributes.frame.width - fromAttributes.frame.width) * progress
            targetFrame.size.height = fromAttributes.frame.height + (toAttributes.frame.height - fromAttributes.frame.height) * progress
        }
        
        selectedItemDecoration.alpha = 1
        selectedItemDecoration.frame = targetFrame
    }
    
    /// 选中 Item
    /// Select item
    public func selectItem(item: Item) {
        if item.isSelectable {
            var needUpdateLayout: Bool = false
            var minSectionIndexNeedUpdate: Int = .max
            
            for (sectionIndex, section) in form.sections.enumerated() {
                for i in section.items {
                    var targetSelect: Bool = i.isSelected
                    if form.singleSelection || form.selectedItemDecoration != nil {
                        targetSelect = item == i
                    } else if item == i {
                        targetSelect = !i.isSelected
                    }
                    if i.isSelected != targetSelect {
                        i.isSelected = targetSelect
                        if i.onSelectedChanged() {
                            i.needReSize = true
                            section.needUpdateLayout = true
                            needUpdateLayout = true
                            minSectionIndexNeedUpdate = min(minSectionIndexNeedUpdate, sectionIndex)
                        }
                    }
                }
            }
            
            if needUpdateLayout {
                layout.reloadSectionsAfter(index: minSectionIndexNeedUpdate)
            }
        }
        
        item.didSelect()
        item.unHighlightCell()
        
        if item.isSelectable {
            if item.scrollToSelected {
                scrollView?.scrollToItem(item, at: [.centeredHorizontally, .centeredVertically], animation: true)
                DispatchQueue.main.async {
                    self.updateSelectedItemDecorationIfNeeded()
                }
            } else {
                updateSelectedItemDecorationIfNeeded()
            }
        }
    }
    
    /// 获取 RepresentableItem
    /// Get representable item
    fileprivate func representableItem(from item: Item, at indexPath: IndexPath) -> (any ItemViewRepresentable)? {
        var representableItem: (any ItemViewRepresentable)?
        if let item = item as? (any ItemViewRepresentable) {
            representableItem = item
        } else if let binder = form[indexPath.section].itemCellBinders.first(where: { $0.mateItem(item) }) {
            representableItem = binder
        } else if let binder = form.itemCellBinders.first(where: { $0.mateItem(item) }) {
            representableItem = binder
        }
        return representableItem
    }
}

// MARK: - FormDelegate

extension QuickListScrollViewHandler: FormDelegate {
    
    public var scrollFormView: QuickListScrollView? {
        return scrollView
    }
    
    public func updateLayout(sections: [Section]?, inAnimation: ListReloadAnimation? = ListReloadAnimation.transform, othersInAnimation: ListReloadAnimation? = ListReloadAnimation.transform, performBatchUpdates: ((QuickListScrollView?, QuickListCollectionLayout?) -> Void)? = nil, completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.scrollView?.superview != nil,
                  self.scrollView?.window != nil else { return }
            
            self.currentUpdateSections = sections?.sorted(by: { ($0.index ?? 0) < ($1.index ?? 0) })
            self.currentUpdateSectionInAnimation = inAnimation
            self.currentUpdateOthersInAnimation = othersInAnimation
            
            // 设置动画器
            // Setup animator
            self.scrollView?.animator.enterAnimation = inAnimation
            self.scrollView?.animator.otherSectionsEnterAnimation = othersInAnimation
            self.scrollView?.animator.updatingSections = self.currentUpdateSections
            
            let duration = othersInAnimation?.duration ?? inAnimation?.duration ?? 0.3
            
            self.scrollView?.performBatchUpdates({ [weak self] in
                if let customUpdates = performBatchUpdates {
                    customUpdates(self?.scrollView, self?.layout)
                } else {
                    self?.layout.reloadSectionsAfter(index: sections?.first?.index ?? 0, needOldSectionAttributes: true)
                }
            }, completion: { [weak self] _ in
                self?.layout.oldSectionAttributes.removeAll()
                self?.currentUpdateSections = nil
                self?.currentUpdateSectionInAnimation = nil
                self?.currentUpdateOthersInAnimation = nil
                self?.scrollView?.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self?.updateSelectedItemDecorationIfNeeded()
                    completion?()
                }
            })
        }
    }
    
    public func getViewSize() -> CGSize {
        guard let scrollView = self.scrollView else {
            return .zero
        }
        return CGSize(
            width: scrollView.bounds.width - scrollView.adjustedContentInset.left - scrollView.adjustedContentInset.right,
            height: scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
        )
    }
    
    public func getContentSize() -> CGSize {
        scrollView?.contentSize ?? .zero
    }
}

// MARK: - QuickScrollViewDataSource

extension QuickListScrollViewHandler: QuickScrollViewDataSource {
    
    public func numberOfSections(in scrollView: QuickScrollView) -> Int {
        return form.count
    }
    
    public func scrollView(_ scrollView: QuickScrollView, numberOfItemsInSection section: Int) -> Int {
        return form[section].count
    }
    
    public func scrollView(_ scrollView: QuickScrollView, cellForItemAt indexPath: IndexPath) -> QuickScrollViewCell {
        guard
            let item = form[indexPath],
            let representableItem = representableItem(from: item, at: indexPath),
            let listScrollView = scrollView as? QuickListScrollView
        else {
            return ItemCell()
        }
        
        // 注册（如果未注册）
        // Register (if not registered)
        if !registedCellIdentifier.contains(representableItem.identifier) {
            representableItem.regist(to: listScrollView)
            registedCellIdentifier.append(representableItem.identifier)
        }
        
        // 获取 Cell
        // Get cell
        guard let cell = representableItem.cellForItem(item, in: listScrollView, for: indexPath) else {
            return ItemCell()
        }
        
        // 设置关联
        // Setup association
        if cell.item?.cell == cell {
            cell.item?.cell = nil
        }
        cell.item = item
        item.cell = cell
        
        if !cell.isSetup {
            cell.setup()
        }
        item.updateCell()
        
        return cell
    }
    
    public func scrollView(_ scrollView: QuickScrollView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> QuickScrollViewReusableView? {
        guard
            let sectionIndex = indexPath.safeSection(),
            let listScrollView = scrollView as? QuickListScrollView
        else { return nil }
        
        // Form Header
        if kind == QuickListReusableType.formHeader.elementKind {
            guard let header = form.header else { return nil }
            let identifier = header.identifier
            if !registedFormHeaderIdentifier.contains(identifier) {
                header.regist(to: listScrollView, for: .formHeader)
                registedFormHeaderIdentifier.append(identifier)
            }
            guard let headerView = header.view(for: .formHeader, in: listScrollView, at: indexPath) else { return nil }
            headerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 503)
            return headerView
        }
        
        // Form Footer
        if kind == QuickListReusableType.formFooter.elementKind {
            guard let footer = form.footer else { return nil }
            let identifier = footer.identifier
            if !registedFormFooterIdentifier.contains(identifier) {
                footer.regist(to: listScrollView, for: .formFooter)
                registedFormFooterIdentifier.append(identifier)
            }
            guard let footerView = footer.view(for: .formFooter, in: listScrollView, at: indexPath) else { return nil }
            footerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 500)
            return footerView
        }
        
        let section: Section = form[sectionIndex]
        
        // Section Header
        if kind == QuickListReusableType.sectionHeader.elementKind {
            guard let header = section.header else { return nil }
            let identifier = header.identifier
            if !registedHeaderIdentifier.contains(identifier) {
                header.regist(to: listScrollView, for: .sectionHeader)
                registedHeaderIdentifier.append(identifier)
            }
            guard let headerView = header.viewForSection(section, in: listScrollView, type: .sectionHeader, for: indexPath) else { return nil }
            headerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 502)
            return headerView
        }
        
        // Section Footer
        if kind == QuickListReusableType.sectionFooter.elementKind {
            guard let footer = section.footer else { return nil }
            let identifier = footer.identifier
            if !registedFooterIdentifier.contains(identifier) {
                footer.regist(to: listScrollView, for: .sectionFooter)
                registedFooterIdentifier.append(identifier)
            }
            guard let footerView = footer.viewForSection(section, in: listScrollView, type: .sectionFooter, for: indexPath) else { return nil }
            footerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 501)
            return footerView
        }
        
        // Section Decoration
        if kind == QuickListReusableType.decoration.elementKind {
            guard let decoration = section.decoration else { return nil }
            let identifier = decoration.identifier
            if !registedDecorationIdentifier.contains(identifier) {
                decoration.regist(to: listScrollView, for: .decoration)
                registedDecorationIdentifier.append(identifier)
            }
            guard let decorationView = decoration.viewForSection(section, in: listScrollView, type: .decoration, for: indexPath) else { return nil }
            decorationView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 498)
            return decorationView
        }
        
        // Suspension Decoration
        if kind == QuickListReusableType.suspensionDecoration.elementKind {
            guard let decoration = section.suspensionDecoration else { return nil }
            let identifier = decoration.identifier
            if !registedSuspensionDecorationIdentifier.contains(identifier) {
                decoration.regist(to: listScrollView, for: .suspensionDecoration)
                registedSuspensionDecorationIdentifier.append(identifier)
            }
            guard let decorationView = decoration.viewForSection(section, in: listScrollView, type: .suspensionDecoration, for: indexPath) else { return nil }
            decorationView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 497)
            return decorationView
        }
        
        return nil
    }
    
    public func scrollView(_ scrollView: QuickScrollView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let item = form[indexPath], item.canMove else {
            return false
        }
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = form[sectionIndex] as? MultivalusedSection,
            section.moveAble && section.count > 1
        else {
            return item.canMove
        }
        return true
    }
    
    public func scrollView(_ scrollView: QuickScrollView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            let formSectionIndex = sourceIndexPath.safeSection(),
            let toSectionIndex = destinationIndexPath.safeSection(),
            let fromSection = form[formSectionIndex] as? MultivalusedSection,
            let toSection = form[toSectionIndex] as? MultivalusedSection,
            let fromItem = form[sourceIndexPath]
        else {
            return
        }
        
        if sourceIndexPath != destinationIndexPath {
            fromSection.remove(at: sourceIndexPath.row)
            toSection.insert(fromItem, at: destinationIndexPath.row)
            
            scrollView.setNeedsReload()
            
            let deadline = DispatchTime.now() + 0.25
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.layout.reloadAll()
            }
            
            fromSection.moveFinishClosure?(fromItem, sourceIndexPath, destinationIndexPath)
        }
    }
}

// MARK: - QuickScrollViewDelegate

extension QuickListScrollViewHandler: QuickScrollViewDelegate {
    
    public func scrollView(_ scrollView: QuickScrollView, willDisplay cell: QuickScrollViewCell, forItemAt indexPath: IndexPath) {
        guard let itemCell = cell as? ItemCell else { return }
        
        if let editItem = itemCell.item as? EditableItemType, editItem.isDragging {
            return
        }
        
        itemCell.willDisplay()
        itemCell.item?.willDisplay()
        
        // 执行进入动画
        // Execute enter animation
        doAnimationForCell(itemCell, at: indexPath)
    }
    
    private func doAnimationForCell(_ cell: ItemCell, at indexPath: IndexPath) {
        // 使用 cell 已经应用的布局属性作为 finalAttr，确保与 updateCells 中使用的一致
        // Use the layout attributes already applied to cell as finalAttr, ensuring consistency with updateCells
        let finalAttr = cell.layoutAttributes?.toCollectionViewLayoutAttributes()
        
        if let section = cell.item?.section, currentUpdateSections?.contains(section) ?? false {
            if let inAnimation = currentUpdateSectionInAnimation {
                let oldAttr = self.layout.initialLayoutAttributesForItem(at: indexPath)
                inAnimation.animateIn(view: cell, to: cell.item, at: section, lastAttributes: oldAttr, targetAttributes: finalAttr)
            }
        } else if let othersInAnimation = currentUpdateOthersInAnimation,
                  let section = cell.item?.section {
            let oldAttr = self.layout.initialLayoutAttributesForItem(at: indexPath)
            othersInAnimation.animateIn(view: cell, to: cell.item, at: section, lastAttributes: oldAttr, targetAttributes: finalAttr)
        }
    }
    
    public func scrollView(_ scrollView: QuickScrollView, didEndDisplaying cell: QuickScrollViewCell, forItemAt indexPath: IndexPath) {
        guard let itemCell = cell as? ItemCell else { return }
        
        itemCell.didEndDisplay()
        itemCell.item?.didEndDisplay()
    }
    
    public func scrollView(_ scrollView: QuickScrollView, willDisplaySupplementaryView view: QuickScrollViewReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let index = indexPath.safeSection(), form.count > index else { return }
        let section = form[index]
        
        // 使用 view 已经应用的布局属性作为 finalAttr，确保与 updateSupplementaryViews 中使用的一致
        // Use the layout attributes already applied to view as finalAttr, ensuring consistency with updateSupplementaryViews
        let finalAttr = view.layoutAttributes?.toCollectionViewLayoutAttributes()
        
        if currentUpdateSections?.contains(section) ?? false {
            if let inAnimation = currentUpdateSectionInAnimation {
                let oldAttr = self.layout.initialLayoutAttributesForElement(ofKind: elementKind, at: indexPath)
                inAnimation.animateIn(view: view, to: nil, at: section, lastAttributes: oldAttr, targetAttributes: finalAttr)
            }
        } else {
            if let othersInAnimation = currentUpdateOthersInAnimation {
                let oldAttr = self.layout.initialLayoutAttributesForElement(ofKind: elementKind, at: indexPath)
                othersInAnimation.animateIn(view: view, to: nil, at: section, lastAttributes: oldAttr, targetAttributes: finalAttr)
            }
        }
    }
    
    public func scrollView(_ scrollView: QuickScrollView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = form[indexPath] else { return false }
        return !item.isDisabled
    }
    
    public func scrollView(_ scrollView: QuickScrollView, didHighlightItemAt indexPath: IndexPath) {
        guard let item = form[indexPath] else { return }
        item.highlightCell()
    }
    
    public func scrollView(_ scrollView: QuickScrollView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let item = form[indexPath] else { return }
        item.unHighlightCell()
    }
    
    public func scrollView(_ scrollView: QuickScrollView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = form[indexPath] else { return false }
        return !item.isDisabled
    }
    
    public func scrollView(_ scrollView: QuickScrollView, didSelectItemAt indexPath: IndexPath) {
        currentOpenedSwipeCell?.closeSwipeActions()
        
        guard let item = form[indexPath] else { return }
        selectItem(item: item)
    }
    
    public func scrollView(_ scrollView: QuickScrollView, didDeselectItemAt indexPath: IndexPath) {
        // 取消选中处理
        // Deselect handling
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentOpenedSwipeCell?.closeSwipeActions()
        notifyBeginScroll()
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyEndScroll()
        }
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        notifyEndScroll()
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
    private func notifyBeginScroll() {
        if !isScrolling {
            isScrolling = true
            for (_, cell) in self.scrollView?.visibleItemCells ?? [:] {
                cell.willBeginScrolling()
            }
        }
    }
    
    private func notifyEndScroll() {
        if isScrolling {
            isScrolling = false
            for (_, cell) in self.scrollView?.visibleItemCells ?? [:] {
                cell.didEndScrolling()
            }
        }
    }
}
