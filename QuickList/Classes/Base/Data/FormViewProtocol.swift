//
//  FormViewProtocol.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

/// 展示列表对象的协议
public protocol FormViewProtocol: UIScrollView {
    /// section的悬浮header的起始点（扩展属性），用于支持isFormHeader
    var suspensionStartPoint: CGPoint? { get set }
    
    /// layout
    var collectionViewLayout: UICollectionViewLayout { get set }
    
    /// 可见的cell
    var visibleCells: [UICollectionViewCell] { get }
    
    /// 注册Cell
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String)

    /// 注册Header/Footer
    func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String)

    /// 获取cell
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell
    /// 获取Header/Footer
    func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView
    
    /// 获取对应的展示view的宽高
    func displaySize() -> CGSize
    
    /// 数据重载
    func reloadData()
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
    func reloadSections(_ sections: IndexSet)
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func reloadItems(at indexPaths: [IndexPath])
    
    /// 滚动到指定cell
    func scrollToItem(_ item: Item, at scrollPosition: UICollectionView.ScrollPosition, animation: Bool)
    
    /// 动画刷新
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    /// 添加全局装饰控件到全局背景之上，如果没有全局背景，则放在最底层（例：单选的item选中提示）
    func addDecorationViewIfNeeded(_ view: UIView)
    
    /// 添加全局背景到最底层
    func addBackgroundViewIfNeeded(_ view: UIView?)
    
    /// 更新Layout方法
    func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool)
}

/// 长按事件处理代理
public protocol FormViewLongTapProtorol: UIView {
    /// 长按手势位置获取indexPath
    func indexPathForItem(at point: CGPoint) -> IndexPath?
    /// 开始移动item
    func beginInteractiveMovementForItem(at indexPath: IndexPath) -> Bool
    /// 移动过程
    func updateInteractiveMovementTargetPosition(_ targetPosition: CGPoint)
    /// 移动结束
    func endInteractiveMovement()
    /// 移动取消
    func cancelInteractiveMovement()
}

@propertyWrapper
public class UniqueAddress {
  public var wrappedValue: UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
  }

  public init() { }
}

extension UICollectionView: FormViewProtocol {
    private struct AssociatedKey {
        @UniqueAddress static var currentDecorationViewIdentifier
        @UniqueAddress static var currentBackgroundViewIdentifier
        @UniqueAddress static var suspensionStartPointIdentifier
    }
    
    /// section的悬浮header的起始点（扩展属性），用于支持isFormHeader
    public var suspensionStartPoint: CGPoint? {
        get {
            return objc_getAssociatedObject(self, AssociatedKey.suspensionStartPointIdentifier) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.suspensionStartPointIdentifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 当前装饰控件（扩展属性）
    var currentDecorationView: UIView? {
        get {
            return objc_getAssociatedObject(self, AssociatedKey.currentDecorationViewIdentifier) as? UIView
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.currentDecorationViewIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 当前全局背景（扩展属性)
    var currentBackgroundView: UIView? {
        get {
            return objc_getAssociatedObject(self, AssociatedKey.currentBackgroundViewIdentifier) as? UIView
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.currentBackgroundViewIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 添加全局装饰控件到全局背景之上，如果没有全局背景，则放在最底层
    public func addDecorationViewIfNeeded(_ view: UIView) {
        if currentDecorationView != nil, currentDecorationView == view {
            return
        }
        if currentDecorationView != view {
            currentDecorationView?.removeFromSuperview()
        }
        addSubview(view)
    }
    
    /// 添加全局背景到最底层
    public func addBackgroundViewIfNeeded(_ view: UIView?) {
        if currentBackgroundView != nil, currentBackgroundView == view {
            return
        }
        if currentBackgroundView != view {
            currentBackgroundView?.removeFromSuperview()
        }
        guard let view = view else { return }
        view.layer.zPosition = 0
        addSubview(view)
    }
    
    public func displaySize() -> CGSize {
        self.bounds.size
    }
    
    public func scrollToItem(_ item: Item, at scrollPosition: UICollectionView.ScrollPosition, animation: Bool) {
        guard let indexPath = item.indexPath else { return }
        self.scrollToItem(at: indexPath, at: scrollPosition, animated: animation)
    }
}
