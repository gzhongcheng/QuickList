//
//  QuickScrollViewReusePool.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

/// 视图重用池
/// View reuse pool
public class QuickScrollViewReusePool<T: UIView> {
    
    // MARK: - Properties
    
    /// 重用池
    /// Reuse pool
    private var pool: [String: [T]] = [:]
    
    /// 注册的类型
    /// Registered types
    private var registeredClasses: [String: AnyClass] = [:]
    
    /// 注册的 NIB
    /// Registered NIBs
    private var registeredNibs: [String: UINib] = [:]
    
    /// 当前使用中的视图
    /// Currently in-use views
    private var inUseViews: [String: Set<ObjectIdentifier>] = [:]
    
    // MARK: - Registration
    
    /// 注册 Class
    /// Register Class
    public func register(_ cellClass: AnyClass?, forIdentifier identifier: String) {
        registeredClasses[identifier] = cellClass
        if pool[identifier] == nil {
            pool[identifier] = []
        }
    }
    
    /// 注册 NIB
    /// Register NIB
    public func register(_ nib: UINib?, forIdentifier identifier: String) {
        if let nib = nib {
            registeredNibs[identifier] = nib
        }
        if pool[identifier] == nil {
            pool[identifier] = []
        }
    }
    
    /// 检查是否已注册
    /// Check if registered
    public func isRegistered(identifier: String) -> Bool {
        return registeredClasses[identifier] != nil || registeredNibs[identifier] != nil
    }
    
    // MARK: - Dequeue
    
    /// 获取可重用视图
    /// Dequeue reusable view
    public func dequeue(identifier: String) -> T? {
        // 尝试从池中获取
        // Try to get from pool
        if var views = pool[identifier], !views.isEmpty {
            let view = views.removeLast()
            pool[identifier] = views
            
            // 准备重用
            // Prepare for reuse
            prepareViewForReuse(view, identifier: identifier)
            
            // 记录为使用中
            // Mark as in use
            if inUseViews[identifier] == nil {
                inUseViews[identifier] = []
            }
            inUseViews[identifier]?.insert(ObjectIdentifier(view))
            
            return view
        }
        
        // 创建新视图
        // Create new view
        return createView(identifier: identifier)
    }
    
    /// 创建新视图
    /// Create new view
    private func createView(identifier: String) -> T? {
        var view: T?
        
        // 尝试从 NIB 创建
        // Try to create from NIB
        if let nib = registeredNibs[identifier] {
            let objects = nib.instantiate(withOwner: nil, options: nil)
            view = objects.first as? T
        }
        
        // 尝试从 Class 创建
        // Try to create from Class
        if view == nil, let cellClass = registeredClasses[identifier] as? T.Type {
            view = cellClass.init(frame: .zero)
        }
        
        // 设置标识符
        // Set identifier
        if let scrollCell = view as? QuickScrollViewCell {
            scrollCell.reuseIdentifier = identifier
        } else if let reusableView = view as? QuickScrollViewReusableView {
            reusableView.reuseIdentifier = identifier
        }
        
        // 记录为使用中
        // Mark as in use
        if let view = view {
            if inUseViews[identifier] == nil {
                inUseViews[identifier] = []
            }
            inUseViews[identifier]?.insert(ObjectIdentifier(view))
        }
        
        return view
    }
    
    /// 准备视图重用
    /// Prepare view for reuse
    private func prepareViewForReuse(_ view: T, identifier: String) {
        if let scrollCell = view as? QuickScrollViewCell {
            scrollCell.prepareForReuse()
        } else if let reusableView = view as? QuickScrollViewReusableView {
            reusableView.prepareForReuse()
        }
    }
    
    // MARK: - Recycle
    
    /// 回收视图
    /// Recycle view
    public func recycle(_ view: T, identifier: String) {
        // 从使用中移除
        // Remove from in-use
        inUseViews[identifier]?.remove(ObjectIdentifier(view))
        
        // 准备重用
        // Prepare for reuse
        prepareViewForReuse(view, identifier: identifier)
        
        // 添加到池中
        // Add to pool
        if pool[identifier] == nil {
            pool[identifier] = []
        }
        pool[identifier]?.append(view)
    }
    
    /// 回收所有使用中的视图
    /// Recycle all in-use views
    public func recycleAll() {
        for (identifier, _) in inUseViews {
            inUseViews[identifier]?.removeAll()
        }
    }
    
    // MARK: - Clear
    
    /// 清空池
    /// Clear pool
    public func clear() {
        pool.removeAll()
        inUseViews.removeAll()
    }
    
    /// 清空指定标识符的池
    /// Clear pool for specific identifier
    public func clear(identifier: String) {
        pool[identifier]?.removeAll()
        inUseViews[identifier]?.removeAll()
    }
    
    /// 获取池中视图数量
    /// Get number of views in pool
    public func count(for identifier: String) -> Int {
        return pool[identifier]?.count ?? 0
    }
    
    /// 获取所有注册的标识符
    /// Get all registered identifiers
    public var registeredIdentifiers: [String] {
        return Array(registeredClasses.keys) + Array(registeredNibs.keys)
    }
}

// MARK: - QuickScrollViewReuseManager

/// 重用管理器，管理 Cell 和 ReusableView 的重用
/// Reuse manager, manages reuse of Cell and ReusableView
public class QuickScrollViewReuseManager {
    
    /// Cell 重用池（直接使用 QuickScrollViewCell，ItemCell 继承自它）
    /// Cell reuse pool (directly use QuickScrollViewCell, ItemCell inherits from it)
    public let cellPool = QuickScrollViewReusePool<QuickScrollViewCell>()
    
    /// ReusableView 重用池
    /// ReusableView reuse pool
    public let reusableViewPool = QuickScrollViewReusePool<QuickScrollViewReusableView>()
    
    /// 已注册的 Cell 标识符
    /// Registered cell identifiers
    private var registeredCellIdentifiers: Set<String> = []
    
    /// 已注册的 ReusableView 标识符（按 elementKind 分类）
    /// Registered reusable view identifiers (categorized by elementKind)
    private var registeredReusableViewIdentifiers: [String: Set<String>] = [:]
    
    // MARK: - Cell Registration
    
    /// 注册 Cell Class
    /// Register Cell Class
    public func registerCell(_ cellClass: AnyClass, identifier: String) {
        cellPool.register(cellClass, forIdentifier: identifier)
        registeredCellIdentifiers.insert(identifier)
    }
    
    /// 注册 Cell NIB
    /// Register Cell NIB
    public func registerCell(_ nib: UINib, identifier: String) {
        cellPool.register(nib, forIdentifier: identifier)
        registeredCellIdentifiers.insert(identifier)
    }
    
    /// 检查 Cell 是否已注册
    /// Check if Cell is registered
    public func isCellRegistered(identifier: String) -> Bool {
        return registeredCellIdentifiers.contains(identifier)
    }
    
    // MARK: - ReusableView Registration
    
    /// 注册 ReusableView Class
    /// Register ReusableView Class
    public func registerReusableView(_ viewClass: AnyClass, elementKind: String, identifier: String) {
        let key = "\(elementKind)_\(identifier)"
        reusableViewPool.register(viewClass, forIdentifier: key)
        if registeredReusableViewIdentifiers[elementKind] == nil {
            registeredReusableViewIdentifiers[elementKind] = []
        }
        registeredReusableViewIdentifiers[elementKind]?.insert(identifier)
    }
    
    /// 注册 ReusableView NIB
    /// Register ReusableView NIB
    public func registerReusableView(_ nib: UINib, elementKind: String, identifier: String) {
        let key = "\(elementKind)_\(identifier)"
        reusableViewPool.register(nib, forIdentifier: key)
        if registeredReusableViewIdentifiers[elementKind] == nil {
            registeredReusableViewIdentifiers[elementKind] = []
        }
        registeredReusableViewIdentifiers[elementKind]?.insert(identifier)
    }
    
    /// 检查 ReusableView 是否已注册
    /// Check if ReusableView is registered
    public func isReusableViewRegistered(elementKind: String, identifier: String) -> Bool {
        return registeredReusableViewIdentifiers[elementKind]?.contains(identifier) ?? false
    }
    
    // MARK: - Dequeue
    
    /// 获取可重用 Cell
    /// Dequeue reusable cell
    public func dequeueCell(identifier: String, indexPath: IndexPath) -> QuickScrollViewCell? {
        if let cell = cellPool.dequeue(identifier: identifier) {
            cell.indexPath = indexPath
            return cell
        }
        return nil
    }
    
    /// 获取可重用 ReusableView
    /// Dequeue reusable view
    public func dequeueReusableView(elementKind: String, identifier: String, indexPath: IndexPath) -> QuickScrollViewReusableView? {
        let key = "\(elementKind)_\(identifier)"
        
        if let view = reusableViewPool.dequeue(identifier: key) {
            view.indexPath = indexPath
            view.elementKind = elementKind
            return view
        }
        
        return nil
    }
    
    // MARK: - Recycle
    
    /// 回收 Cell
    /// Recycle cell
    public func recycleCell(_ cell: QuickScrollViewCell) {
        let identifier = cell.reuseIdentifier
        cellPool.recycle(cell, identifier: identifier)
    }
    
    /// 回收 ReusableView
    /// Recycle reusable view
    public func recycleReusableView(_ view: QuickScrollViewReusableView) {
        let key = "\(view.elementKind)_\(view.reuseIdentifier)"
        reusableViewPool.recycle(view, identifier: key)
    }
    
    /// 清空所有池
    /// Clear all pools
    public func clearAll() {
        cellPool.clear()
        reusableViewPool.clear()
    }
}
