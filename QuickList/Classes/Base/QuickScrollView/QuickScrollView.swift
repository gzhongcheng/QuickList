//
//  QuickScrollView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

// MARK: - Protocols

/// 数据源协议
/// Data source protocol
public protocol QuickScrollViewDataSource: AnyObject {
    
    /// Section 数量
    /// Number of sections
    func numberOfSections(in scrollView: QuickScrollView) -> Int
    
    /// 指定 Section 中的 Item 数量
    /// Number of items in specified section
    func scrollView(_ scrollView: QuickScrollView, numberOfItemsInSection section: Int) -> Int
    
    /// 获取指定 IndexPath 的 Cell（返回 QuickScrollViewCell，ItemCell 继承自它）
    /// Get cell for specified IndexPath (returns QuickScrollViewCell, ItemCell inherits from it)
    func scrollView(_ scrollView: QuickScrollView, cellForItemAt indexPath: IndexPath) -> QuickScrollViewCell
    
    /// 获取补充视图
    /// Get supplementary view
    func scrollView(_ scrollView: QuickScrollView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> QuickScrollViewReusableView?
    
    /// 是否可以移动
    /// Whether can move
    func scrollView(_ scrollView: QuickScrollView, canMoveItemAt indexPath: IndexPath) -> Bool
    
    /// 移动 Item
    /// Move item
    func scrollView(_ scrollView: QuickScrollView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

/// 数据源协议默认实现
/// Data source protocol default implementation
public extension QuickScrollViewDataSource {
    func numberOfSections(in scrollView: QuickScrollView) -> Int { return 1 }
    func scrollView(_ scrollView: QuickScrollView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> QuickScrollViewReusableView? { return nil }
    func scrollView(_ scrollView: QuickScrollView, canMoveItemAt indexPath: IndexPath) -> Bool { return false }
    func scrollView(_ scrollView: QuickScrollView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}

/// 代理协议
/// Delegate protocol
public protocol QuickScrollViewDelegate: UIScrollViewDelegate {
    
    /// Cell 即将显示
    /// Cell will display
    func scrollView(_ scrollView: QuickScrollView, willDisplay cell: QuickScrollViewCell, forItemAt indexPath: IndexPath)
    
    /// Cell 结束显示
    /// Cell did end display
    func scrollView(_ scrollView: QuickScrollView, didEndDisplaying cell: QuickScrollViewCell, forItemAt indexPath: IndexPath)
    
    /// 补充视图即将显示
    /// Supplementary view will display
    func scrollView(_ scrollView: QuickScrollView, willDisplaySupplementaryView view: QuickScrollViewReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
    
    /// 补充视图结束显示
    /// Supplementary view did end display
    func scrollView(_ scrollView: QuickScrollView, didEndDisplayingSupplementaryView view: QuickScrollViewReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)
    
    /// 是否应该高亮 Item
    /// Should highlight item
    func scrollView(_ scrollView: QuickScrollView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    
    /// Item 高亮
    /// Item did highlight
    func scrollView(_ scrollView: QuickScrollView, didHighlightItemAt indexPath: IndexPath)
    
    /// Item 取消高亮
    /// Item did unhighlight
    func scrollView(_ scrollView: QuickScrollView, didUnhighlightItemAt indexPath: IndexPath)
    
    /// 是否应该选择 Item
    /// Should select item
    func scrollView(_ scrollView: QuickScrollView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    
    /// Item 选中
    /// Item did select
    func scrollView(_ scrollView: QuickScrollView, didSelectItemAt indexPath: IndexPath)
    
    /// Item 取消选中
    /// Item did deselect
    func scrollView(_ scrollView: QuickScrollView, didDeselectItemAt indexPath: IndexPath)
}

/// 代理协议默认实现
/// Delegate protocol default implementation
public extension QuickScrollViewDelegate {
    func scrollView(_ scrollView: QuickScrollView, willDisplay cell: QuickScrollViewCell, forItemAt indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, didEndDisplaying cell: QuickScrollViewCell, forItemAt indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, willDisplaySupplementaryView view: QuickScrollViewReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, didEndDisplayingSupplementaryView view: QuickScrollViewReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return true }
    func scrollView(_ scrollView: QuickScrollView, didHighlightItemAt indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, didUnhighlightItemAt indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }
    func scrollView(_ scrollView: QuickScrollView, didSelectItemAt indexPath: IndexPath) {}
    func scrollView(_ scrollView: QuickScrollView, didDeselectItemAt indexPath: IndexPath) {}
}

/// 动画代理协议
/// Animation delegate protocol
public protocol QuickScrollViewAnimationDelegate: AnyObject {
    
    /// Cell 进入动画
    /// Cell enter animation
    func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?)
    
    /// Cell 退出动画
    /// Cell exit animation
    func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?)
    
    /// 补充视图进入动画
    /// Supplementary view enter animation
    func scrollView(_ scrollView: QuickScrollView, animateInSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?)
    
    /// 补充视图退出动画
    /// Supplementary view exit animation
    func scrollView(_ scrollView: QuickScrollView, animateOutSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?)
}

/// 动画代理协议默认实现
/// Animation delegate protocol default implementation
public extension QuickScrollViewAnimationDelegate {
    func scrollView(_ scrollView: QuickScrollView, animateIn cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {}
    func scrollView(_ scrollView: QuickScrollView, animateOut cell: QuickScrollViewCell, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {}
    func scrollView(_ scrollView: QuickScrollView, animateInSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {}
    func scrollView(_ scrollView: QuickScrollView, animateOutSupplementaryView view: QuickScrollViewReusableView, ofKind kind: String, at indexPath: IndexPath, from initialAttributes: QuickScrollViewLayoutAttributes?, to finalAttributes: QuickScrollViewLayoutAttributes?) {}
}

// MARK: - QuickScrollView

/// 自定义滚动视图容器
/// Custom scroll view container
open class QuickScrollView: UIScrollView {
    
    // MARK: - Properties
    
    /// 数据源
    /// Data source
    public weak var dataSourceDelegate: QuickScrollViewDataSource?
    
    /// 代理
    /// Delegate
    public weak var scrollViewDelegate: QuickScrollViewDelegate? {
        didSet {
            super.delegate = self
        }
    }
    
    /// 动画代理
    /// Animation delegate
    public weak var animationDelegate: QuickScrollViewAnimationDelegate?
    
    /// 布局管理器
    /// Layout manager
    public var layout: QuickScrollViewLayoutProtocol? {
        didSet {
            layout?.scrollView = self
            setNeedsReload()
        }
    }
    
    /// 当前可见的 Cells
    /// Currently visible cells
    public private(set) var visibleCells: [IndexPath: QuickScrollViewCell] = [:]
    
    /// 当前可见的补充视图
    /// Currently visible supplementary views
    public private(set) var visibleSupplementaryViews: [String: [IndexPath: QuickScrollViewReusableView]] = [:]
    
    /// 内容容器视图
    /// Content container view
    public let contentContainerView: UIView = UIView()
    
    /// 是否需要重新加载
    /// Whether needs reload
    private var needsReload: Bool = true
    
    /// 是否正在执行批量更新
    /// Whether performing batch updates
    private var isPerformingBatchUpdates: Bool = false
    
    /// 批量更新的插入 IndexPaths
    /// Batch update insert IndexPaths
    private var batchInsertIndexPaths: [IndexPath] = []
    
    /// 批量更新的删除 IndexPaths
    /// Batch update delete IndexPaths
    private var batchDeleteIndexPaths: [IndexPath] = []
    
    /// 批量更新的重载 IndexPaths
    /// Batch update reload IndexPaths
    private var batchReloadIndexPaths: [IndexPath] = []
    
    /// 当前动画配置
    /// Current animation configuration
    private var currentAnimationDuration: TimeInterval = 0.3
    private var currentAnimationOptions: UIView.AnimationOptions = [.curveEaseInOut]
    
    /// 滚动方向
    /// Scroll direction
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        super.delegate = self
        
        // 设置内容容器
        // Setup content container
        contentContainerView.frame = bounds
        addSubview(contentContainerView)
        
        // 默认设置
        // Default settings
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsReload {
            needsReload = false
            reloadData()
        } else {
            // 更新可见视图
            // Update visible views
            updateVisibleViews()
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            if oldValue.size != bounds.size {
                layout?.invalidateLayout()
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Registration
    
    /// 注册 Cell Class
    /// Register cell class
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        // 子类实现
        // Subclass implementation
    }
    
    /// 注册 Cell NIB
    /// Register cell NIB
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        // 子类实现
        // Subclass implementation
    }
    
    /// 注册补充视图 Class
    /// Register supplementary view class
    public func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        // 子类实现
        // Subclass implementation
    }
    
    /// 注册补充视图 NIB
    /// Register supplementary view NIB
    public func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        // 子类实现
        // Subclass implementation
    }
    
    // MARK: - Reload
    
    /// 标记需要重新加载
    /// Mark needs reload
    public func setNeedsReload() {
        needsReload = true
        setNeedsLayout()
    }
    
    /// 重新加载数据
    /// Reload data
    public func reloadData() {
        // 回收所有视图
        // Recycle all views
        recycleAllViews()
        
        // 准备布局
        // Prepare layout
        layout?.prepare()
        
        // 更新内容尺寸
        // Update content size
        updateContentSize()
        
        // 更新可见视图
        // Update visible views
        updateVisibleViews()
    }
    
    /// 更新内容尺寸
    /// Update content size
    private func updateContentSize() {
        let size = layout?.contentSize ?? .zero
        contentSize = size
        contentContainerView.frame = CGRect(origin: .zero, size: size)
    }
    
    /// 回收所有视图
    /// Recycle all views
    private func recycleAllViews() {
        // 回收所有 Cells
        // Recycle all cells
        for (_, cell) in visibleCells {
            cell.didEndDisplay()
            cell.removeFromSuperview()
        }
        visibleCells.removeAll()
        
        // 回收所有补充视图
        // Recycle all supplementary views
        for (_, views) in visibleSupplementaryViews {
            for (_, view) in views {
                view.removeFromSuperview()
            }
        }
        visibleSupplementaryViews.removeAll()
    }
    
    // MARK: - Update Visible Views
    
    /// 更新可见视图
    /// Update visible views
    private func updateVisibleViews() {
        guard !isPerformingBatchUpdates else { return }
        
        let visibleRect = CGRect(
            x: contentOffset.x - bounds.width * 0.5,
            y: contentOffset.y - bounds.height * 0.5,
            width: bounds.width * 2,
            height: bounds.height * 2
        )
        
        guard let allAttributes = layout?.layoutAttributesForElements(in: visibleRect) else { return }
        
        // 分离 Cell 和补充视图属性
        // Separate cell and supplementary view attributes
        var cellAttributes: [IndexPath: QuickScrollViewLayoutAttributes] = [:]
        var supplementaryAttributes: [String: [IndexPath: QuickScrollViewLayoutAttributes]] = [:]
        
        for attr in allAttributes {
            guard let indexPath = attr.indexPath else { continue }
            
            switch attr.representedElementCategory {
            case .cell:
                cellAttributes[indexPath] = attr
            case .supplementaryView, .decorationView:
                let kind = attr.representedElementKind ?? ""
                if supplementaryAttributes[kind] == nil {
                    supplementaryAttributes[kind] = [:]
                }
                supplementaryAttributes[kind]?[indexPath] = attr
            }
        }
        
        // 更新 Cells
        // Update cells
        updateCells(with: cellAttributes)
        
        // 更新补充视图
        // Update supplementary views
        updateSupplementaryViews(with: supplementaryAttributes)
    }
    
    /// 更新 Cells
    /// Update cells
    private func updateCells(with attributes: [IndexPath: QuickScrollViewLayoutAttributes]) {
        // 找出需要移除的 Cells
        // Find cells to remove
        let currentIndexPaths = Set(visibleCells.keys)
        let newIndexPaths = Set(attributes.keys)
        let toRemove = currentIndexPaths.subtracting(newIndexPaths)
        let toAdd = newIndexPaths.subtracting(currentIndexPaths)
        let toUpdate = currentIndexPaths.intersection(newIndexPaths)
        
        // 移除不可见的 Cells
        // Remove invisible cells
        for indexPath in toRemove {
            if let cell = visibleCells.removeValue(forKey: indexPath) {
                // 通知代理
                // Notify delegate
                scrollViewDelegate?.scrollView(self, didEndDisplaying: cell, forItemAt: indexPath)
                
                cell.didEndDisplay()
                cell.removeFromSuperview()
            }
        }
        
        // 添加新的 Cells
        // Add new cells
        for indexPath in toAdd {
            guard let attr = attributes[indexPath],
                  let cell = dataSourceDelegate?.scrollView(self, cellForItemAt: indexPath) else {
                continue
            }
            
            // 应用布局属性
            // Apply layout attributes
            cell.apply(attr)
            
            // 添加到容器
            // Add to container
            contentContainerView.addSubview(cell)
            visibleCells[indexPath] = cell
            
            // 设置
            // Setup
            if !cell.isSetup {
                cell.setup()
            }
            
            // 通知代理
            // Notify delegate
            cell.willDisplay()
            scrollViewDelegate?.scrollView(self, willDisplay: cell, forItemAt: indexPath)
            
            // 进入动画
            // Enter animation
            if let animationDelegate = animationDelegate {
                let initialAttr = layout?.initialLayoutAttributesForAppearingItem(at: indexPath)
                animationDelegate.scrollView(self, animateIn: cell, at: indexPath, from: initialAttr, to: attr)
            }
        }
        
        // 更新已存在的 Cells
        // Update existing cells
        for indexPath in toUpdate {
            if let cell = visibleCells[indexPath],
               let attr = attributes[indexPath] {
                cell.apply(attr)
            }
        }
        
        // 按 zIndex 排序子视图
        // Sort subviews by zIndex
        sortSubviewsByZIndex()
    }
    
    /// 更新补充视图
    /// Update supplementary views
    private func updateSupplementaryViews(with attributes: [String: [IndexPath: QuickScrollViewLayoutAttributes]]) {
        // 收集当前所有的补充视图
        // Collect all current supplementary views
        var allCurrentViews: [(String, IndexPath, QuickScrollViewReusableView)] = []
        for (kind, views) in visibleSupplementaryViews {
            for (indexPath, view) in views {
                allCurrentViews.append((kind, indexPath, view))
            }
        }
        
        // 找出需要移除的视图
        // Find views to remove
        for (kind, indexPath, view) in allCurrentViews {
            let shouldKeep = attributes[kind]?[indexPath] != nil
            if !shouldKeep {
                scrollViewDelegate?.scrollView(self, didEndDisplayingSupplementaryView: view, forElementOfKind: kind, at: indexPath)
                view.removeFromSuperview()
                visibleSupplementaryViews[kind]?.removeValue(forKey: indexPath)
            }
        }
        
        // 添加或更新视图
        // Add or update views
        for (kind, indexPathAttrs) in attributes {
            if visibleSupplementaryViews[kind] == nil {
                visibleSupplementaryViews[kind] = [:]
            }
            
            for (indexPath, attr) in indexPathAttrs {
                if let existingView = visibleSupplementaryViews[kind]?[indexPath] {
                    // 更新已存在的视图
                    // Update existing view
                    existingView.apply(attr)
                } else {
                    // 添加新视图
                    // Add new view
                    guard let view = dataSourceDelegate?.scrollView(self, viewForSupplementaryElementOfKind: kind, at: indexPath) else {
                        continue
                    }
                    
                    view.apply(attr)
                    contentContainerView.addSubview(view)
                    visibleSupplementaryViews[kind]?[indexPath] = view
                    
                    scrollViewDelegate?.scrollView(self, willDisplaySupplementaryView: view, forElementKind: kind, at: indexPath)
                    
                    // 进入动画
                    // Enter animation
                    if let animationDelegate = animationDelegate {
                        let initialAttr = layout?.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: kind, at: indexPath)
                        animationDelegate.scrollView(self, animateInSupplementaryView: view, ofKind: kind, at: indexPath, from: initialAttr, to: attr)
                    }
                }
            }
        }
        
        // 按 zIndex 排序子视图
        // Sort subviews by zIndex
        sortSubviewsByZIndex()
    }
    
    /// 按 zIndex 排序子视图
    /// Sort subviews by zIndex
    private func sortSubviewsByZIndex() {
        contentContainerView.subviews.sorted { $0.layer.zPosition < $1.layer.zPosition }.forEach {
            contentContainerView.bringSubviewToFront($0)
        }
    }
    
    // MARK: - Batch Updates
    
    /// 执行批量更新
    /// Perform batch updates
    public func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        guard let updates = updates else {
            completion?(true)
            return
        }
        
        isPerformingBatchUpdates = true
        batchInsertIndexPaths.removeAll()
        batchDeleteIndexPaths.removeAll()
        batchReloadIndexPaths.removeAll()
        
        // 执行更新
        // Execute updates
        updates()
        
        // 应用更新
        // Apply updates
        applyBatchUpdates(completion: completion)
    }
    
    /// 插入 Items
    /// Insert items
    public func insertItems(at indexPaths: [IndexPath]) {
        if isPerformingBatchUpdates {
            batchInsertIndexPaths.append(contentsOf: indexPaths)
        } else {
            performBatchUpdates {
                self.batchInsertIndexPaths.append(contentsOf: indexPaths)
            }
        }
    }
    
    /// 删除 Items
    /// Delete items
    public func deleteItems(at indexPaths: [IndexPath]) {
        if isPerformingBatchUpdates {
            batchDeleteIndexPaths.append(contentsOf: indexPaths)
        } else {
            performBatchUpdates {
                self.batchDeleteIndexPaths.append(contentsOf: indexPaths)
            }
        }
    }
    
    /// 重载 Items
    /// Reload items
    public func reloadItems(at indexPaths: [IndexPath]) {
        if isPerformingBatchUpdates {
            batchReloadIndexPaths.append(contentsOf: indexPaths)
        } else {
            performBatchUpdates {
                self.batchReloadIndexPaths.append(contentsOf: indexPaths)
            }
        }
    }
    
    /// 应用批量更新
    /// Apply batch updates
    private func applyBatchUpdates(completion: ((Bool) -> Void)?) {
        // 执行删除动画并移除 cells
        // Execute delete animations and remove cells
        for indexPath in batchDeleteIndexPaths {
            if let cell = visibleCells.removeValue(forKey: indexPath) {
                let finalAttr = layout?.finalLayoutAttributesForDisappearingItem(at: indexPath)
                animationDelegate?.scrollView(self, animateOut: cell, at: indexPath, from: nil, to: finalAttr)
                
                // 通知代理并回收 cell
                // Notify delegate and recycle cell
                scrollViewDelegate?.scrollView(self, didEndDisplaying: cell, forItemAt: indexPath)
                cell.didEndDisplay()
                cell.removeFromSuperview()
            }
        }
        
        // 更新布局
        // Update layout
        layout?.invalidateLayout()
        layout?.prepare()
        updateContentSize()
        
        // 在动画前将标志设为 false，以便 updateVisibleViews 可以正常执行
        // Set flag to false before animation so updateVisibleViews can execute
        isPerformingBatchUpdates = false
        
        // 直接更新可见视图，不在系统动画块中执行
        // 因为新添加的 cells 需要先设置正确的 frame，然后再执行自定义的进入动画
        // Update visible views directly, not in system animation block
        // because new cells need to set correct frame first, then execute custom enter animation
        updateVisibleViews()
        
        // 给一个小延迟让动画执行完成
        // Add a small delay for animations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + currentAnimationDuration) { [weak self] in
            self?.batchInsertIndexPaths.removeAll()
            self?.batchDeleteIndexPaths.removeAll()
            self?.batchReloadIndexPaths.removeAll()
            completion?(true)
        }
    }
    
    // MARK: - Selection
    
    /// 选中的 IndexPaths
    /// Selected IndexPaths
    public private(set) var selectedIndexPaths: Set<IndexPath> = []
    
    /// 选中 Item
    /// Select item
    public func selectItem(at indexPath: IndexPath, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        selectedIndexPaths.insert(indexPath)
        
        if let cell = visibleCells[indexPath] {
            cell.isSelected = true
        }
        
        if scrollPosition != [] {
            scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    /// 取消选中 Item
    /// Deselect item
    public func deselectItem(at indexPath: IndexPath, animated: Bool) {
        selectedIndexPaths.remove(indexPath)
        
        if let cell = visibleCells[indexPath] {
            cell.isSelected = false
        }
    }
    
    // MARK: - Scrolling
    
    /// 滚动到指定 Item
    /// Scroll to item
    public func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let attr = layout?.layoutAttributesForItem(at: indexPath) else { return }
        
        var targetOffset = contentOffset
        
        if scrollDirection == .vertical {
            if scrollPosition.contains(.top) {
                targetOffset.y = attr.frame.minY
            } else if scrollPosition.contains(.bottom) {
                targetOffset.y = attr.frame.maxY - bounds.height
            } else if scrollPosition.contains(.centeredVertically) {
                targetOffset.y = attr.frame.midY - bounds.height / 2
            }
        } else {
            if scrollPosition.contains(.left) {
                targetOffset.x = attr.frame.minX
            } else if scrollPosition.contains(.right) {
                targetOffset.x = attr.frame.maxX - bounds.width
            } else if scrollPosition.contains(.centeredHorizontally) {
                targetOffset.x = attr.frame.midX - bounds.width / 2
            }
        }
        
        // 限制在有效范围内
        // Limit to valid range
        targetOffset.x = max(0, min(targetOffset.x, contentSize.width - bounds.width))
        targetOffset.y = max(0, min(targetOffset.y, contentSize.height - bounds.height))
        
        setContentOffset(targetOffset, animated: animated)
    }
    
    // MARK: - Cell Lookup
    
    /// 获取指定 IndexPath 的 Cell
    /// Get cell at IndexPath
    public func cellForItem(at indexPath: IndexPath) -> QuickScrollViewCell? {
        return visibleCells[indexPath]
    }
    
    /// 获取指定 Cell 的 IndexPath
    /// Get IndexPath for cell
    public func indexPath(for cell: QuickScrollViewCell) -> IndexPath? {
        for (indexPath, visibleCell) in visibleCells {
            if visibleCell === cell {
                return indexPath
            }
        }
        return nil
    }
    
    /// 获取所有可见 Cell 的 IndexPaths
    /// Get IndexPaths for visible cells
    public var indexPathsForVisibleItems: [IndexPath] {
        return Array(visibleCells.keys)
    }
}

// MARK: - UIScrollViewDelegate

extension QuickScrollView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleViews()
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 通知所有可见 cell
        // Notify all visible cells
        for (_, cell) in visibleCells {
            cell.willBeginScrolling()
        }
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyScrollingEnded()
        }
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyScrollingEnded()
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyScrollingEnded()
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    private func notifyScrollingEnded() {
        for (_, cell) in visibleCells {
            cell.didEndScrolling()
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollViewDelegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

// MARK: - Touch Handling

extension QuickScrollView {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: contentContainerView)
        
        if let (indexPath, cell) = findCell(at: location) {
            if scrollViewDelegate?.scrollView(self, shouldHighlightItemAt: indexPath) ?? true {
                cell.isHighlighted = true
                scrollViewDelegate?.scrollView(self, didHighlightItemAt: indexPath)
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: contentContainerView)
        
        if let (indexPath, cell) = findCell(at: location) {
            cell.isHighlighted = false
            scrollViewDelegate?.scrollView(self, didUnhighlightItemAt: indexPath)
            
            if scrollViewDelegate?.scrollView(self, shouldSelectItemAt: indexPath) ?? true {
                cell.isSelected = true
                selectedIndexPaths.insert(indexPath)
                scrollViewDelegate?.scrollView(self, didSelectItemAt: indexPath)
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // 取消所有高亮
        // Cancel all highlights
        for (indexPath, cell) in visibleCells {
            if cell.isHighlighted {
                cell.isHighlighted = false
                scrollViewDelegate?.scrollView(self, didUnhighlightItemAt: indexPath)
            }
        }
    }
    
    private func findCell(at location: CGPoint) -> (IndexPath, QuickScrollViewCell)? {
        for (indexPath, cell) in visibleCells {
            if cell.frame.contains(location) {
                return (indexPath, cell)
            }
        }
        return nil
    }
}
