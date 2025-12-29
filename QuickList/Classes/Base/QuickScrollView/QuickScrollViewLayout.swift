//
//  QuickScrollViewLayout.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/12/29.
//

import UIKit

/// 布局属性
/// Layout attributes
public class QuickScrollViewLayoutAttributes: NSObject {
    
    /// 位置
    /// Frame
    public var frame: CGRect = .zero
    
    /// 透明度
    /// Alpha
    public var alpha: CGFloat = 1.0
    
    /// 变换
    /// Transform
    public var transform: CGAffineTransform = .identity
    
    /// 3D变换
    /// 3D Transform
    public var transform3D: CATransform3D = CATransform3DIdentity
    
    /// zIndex
    public var zIndex: Int = 0
    
    /// 是否隐藏
    /// Is hidden
    public var isHidden: Bool = false
    
    /// IndexPath
    public var indexPath: IndexPath?
    
    /// 元素类型 (cell 或 supplementary)
    /// Element type (cell or supplementary)
    public var representedElementCategory: QuickScrollViewElementCategory = .cell
    
    /// 补充视图类型
    /// Supplementary view kind
    public var representedElementKind: String?
    
    /// 从 UICollectionViewLayoutAttributes 转换
    /// Convert from UICollectionViewLayoutAttributes
    public static func from(_ attributes: UICollectionViewLayoutAttributes) -> QuickScrollViewLayoutAttributes {
        let result = QuickScrollViewLayoutAttributes()
        result.frame = attributes.frame
        result.alpha = attributes.alpha
        result.transform = attributes.transform
        result.transform3D = attributes.transform3D
        result.zIndex = attributes.zIndex
        result.isHidden = attributes.isHidden
        result.indexPath = attributes.indexPath
        result.representedElementKind = attributes.representedElementKind
        
        if attributes.representedElementCategory == .cell {
            result.representedElementCategory = .cell
        } else if attributes.representedElementCategory == .supplementaryView {
            result.representedElementCategory = .supplementaryView
        } else {
            result.representedElementCategory = .decorationView
        }
        
        return result
    }
    
    /// 转换为 UICollectionViewLayoutAttributes
    /// Convert to UICollectionViewLayoutAttributes
    public func toCollectionViewLayoutAttributes() -> UICollectionViewLayoutAttributes {
        let attributes: UICollectionViewLayoutAttributes
        
        switch representedElementCategory {
        case .cell:
            attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath ?? IndexPath(item: 0, section: 0))
        case .supplementaryView:
            attributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: representedElementKind ?? "",
                with: indexPath ?? IndexPath(item: 0, section: 0)
            )
        case .decorationView:
            attributes = UICollectionViewLayoutAttributes(
                forDecorationViewOfKind: representedElementKind ?? "",
                with: indexPath ?? IndexPath(item: 0, section: 0)
            )
        }
        
        attributes.frame = frame
        attributes.alpha = alpha
        attributes.transform = transform
        attributes.transform3D = transform3D
        attributes.zIndex = zIndex
        attributes.isHidden = isHidden
        
        return attributes
    }
    
    public override func copy() -> Any {
        let copy = QuickScrollViewLayoutAttributes()
        copy.frame = frame
        copy.alpha = alpha
        copy.transform = transform
        copy.transform3D = transform3D
        copy.zIndex = zIndex
        copy.isHidden = isHidden
        copy.indexPath = indexPath
        copy.representedElementCategory = representedElementCategory
        copy.representedElementKind = representedElementKind
        return copy
    }
}

/// 元素类别
/// Element category
public enum QuickScrollViewElementCategory {
    case cell
    case supplementaryView
    case decorationView
}

/// 布局管理器协议
/// Layout manager protocol
public protocol QuickScrollViewLayoutProtocol: AnyObject {
    
    /// 关联的滚动视图
    /// Associated scroll view
    var scrollView: QuickScrollView? { get set }
    
    /// 准备布局
    /// Prepare layout
    func prepare()
    
    /// 使布局失效
    /// Invalidate layout
    func invalidateLayout()
    
    /// 内容尺寸
    /// Content size
    var contentSize: CGSize { get }
    
    /// 获取指定区域内的所有元素属性
    /// Get all element attributes in specified rect
    func layoutAttributesForElements(in rect: CGRect) -> [QuickScrollViewLayoutAttributes]?
    
    /// 获取指定 IndexPath 的 Cell 属性
    /// Get cell attributes for specified IndexPath
    func layoutAttributesForItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
    
    /// 获取指定 IndexPath 的补充视图属性
    /// Get supplementary view attributes for specified IndexPath
    func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
    
    /// 是否应在边界变化时使布局失效
    /// Whether layout should be invalidated for bounds change
    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    
    /// 初始动画属性
    /// Initial animation attributes
    func initialLayoutAttributesForAppearingItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
    
    /// 最终动画属性
    /// Final animation attributes
    func finalLayoutAttributesForDisappearingItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
    
    /// 初始补充视图动画属性
    /// Initial supplementary view animation attributes
    func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
    
    /// 最终补充视图动画属性
    /// Final supplementary view animation attributes
    func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes?
}

/// 布局管理器适配器，用于包装现有的 QuickListCollectionLayout
/// Layout manager adapter, used to wrap existing QuickListCollectionLayout
public class QuickScrollViewLayoutAdapter: QuickScrollViewLayoutProtocol {
    
    /// 内部布局
    /// Internal layout
    public let collectionLayout: QuickListCollectionLayout
    
    /// 关联的滚动视图
    /// Associated scroll view
    public weak var scrollView: QuickScrollView?
    
    /// 代理内部的 UICollectionView（用于布局计算）
    /// Proxy internal UICollectionView (for layout calculation)
    private weak var proxyCollectionView: UICollectionView?
    
    public init(collectionLayout: QuickListCollectionLayout) {
        self.collectionLayout = collectionLayout
    }
    
    public func prepare() {
        collectionLayout.prepare()
    }
    
    public func invalidateLayout() {
        collectionLayout.invalidateLayout()
    }
    
    public var contentSize: CGSize {
        return collectionLayout.collectionViewContentSize
    }
    
    public func layoutAttributesForElements(in rect: CGRect) -> [QuickScrollViewLayoutAttributes]? {
        return collectionLayout.layoutAttributesForElements(in: rect)?.map { QuickScrollViewLayoutAttributes.from($0) }
    }
    
    public func layoutAttributesForItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        guard let attr = collectionLayout.layoutAttributesForItem(at: indexPath) else { return nil }
        return QuickScrollViewLayoutAttributes.from(attr)
    }
    
    public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        guard let attr = collectionLayout.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        return QuickScrollViewLayoutAttributes.from(attr)
    }
    
    public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionLayout.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    public func initialLayoutAttributesForAppearingItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        guard let attr = collectionLayout.initialLayoutAttributesForItem(at: indexPath) else { return nil }
        return QuickScrollViewLayoutAttributes.from(attr)
    }
    
    public func finalLayoutAttributesForDisappearingItem(at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        // UICollectionViewLayout 默认返回当前属性
        return layoutAttributesForItem(at: indexPath)
    }
    
    public func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        guard let attr = collectionLayout.initialLayoutAttributesForElement(ofKind: elementKind, at: indexPath) else { return nil }
        return QuickScrollViewLayoutAttributes.from(attr)
    }
    
    public func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at indexPath: IndexPath) -> QuickScrollViewLayoutAttributes? {
        return layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
}
