//
//  SectionReusable.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation
import UIKit
import SnapKit

// MARK: - Enum
/**
 * 表示列表的装饰控件类型
 * Represents decoration control types for lists
 */
public enum QuickListReusableType: String {
    case formHeader
    case formFooter
    case sectionHeader
    case sectionFooter
    case decoration
    case suspensionDecoration
    
    /**
     * 对应的 elementKind
     * Corresponding elementKind
     */
    var elementKind: String {
        switch self {
        case .formHeader:
            return "QuickListFormHeaderView"
        case .formFooter:
            return "QuickListFormFooterView"
        case .sectionHeader:
            return "QuickListSectionHeaderView"
        case .sectionFooter:
            return "QuickListSectionFooterView"
        case .decoration:
            return "QuickListSectionDecorationView"
        case .suspensionDecoration:
            return "QuickListSectionSuspensionDecorationView"
        }
    }
}

/**
 * 表示列表header或footer的展示区域类型
 * Represents display area types for list header or footer
 */
public enum FormHeaderFooterDisplayType {
    /**
     * 正常展示, 不做拉伸
     * Normal display, no stretching
     */
    case normal        
    /**
     * 拉伸, 只在最顶部/最底部展示, 下/上拉时会拉伸header/footer
     * Stretch, only display at top/bottom, header/footer will stretch when pulling down/up
     */
    case stretch       
    /**
     * 只在顶部展示, 下拉时不拉伸header
     * Only display at top, header won't stretch when pulling down
     */ 
    case top           
    /**
     * 只在底部展示, 上拉时不拉伸footer
     * Only display at bottom, footer won't stretch when pulling up
     */
    case bottom       
}

// MARK: - Protocols
public protocol FormHeaderFooterReusable {
    /**
     * 复用的identifier
     * Reuse identifier
     */
    var identifier: String { get set }
    
    /**
     * 展示区域类型
     * Display area type
     */
    var displayType: FormHeaderFooterDisplayType { get set }
    
    /**
     * 是否需要悬浮
     * Whether to suspend
     */
    var shouldSuspension: Bool { get set }
    
    /**
     * 高度
     * Height
     */
    var height: ((_ form: Form, _ estimateItemSize: CGSize, _ scrollDirection: UICollectionView.ScrollDirection) -> CGFloat) { get set }
    
    /**
     * 调用此方法来注册
     * Call this method to register
     */
    func regist(to view: QuickListScrollView, for type: QuickListReusableType)
    
    /**
     * 调用此方法来获取指定form的header或footer相对应的view
     * Call this method to get the view corresponding to the specified form's header or footer
     * - parameter type:       类型（header或footer）/ Type (header or footer)
     * - parameter view:       所在的view / The view it belongs to
     * - returns: 对应的view / Corresponding view
     */
    func view(for type: QuickListReusableType, in view: QuickListScrollView, at indexPath: IndexPath) -> QuickScrollViewReusableView?
}

public protocol FormCompressibleHeaderFooterReusable: FormHeaderFooterReusable {
    /**
     * 压缩的最小高度
     * Minimum height for compression
     */
    var minSize: CGSize? { get set }
    /**
     * 展示范围变化的回调方法
     * Callback method for display range changes
     */
    func didChangeDispalySize(to visibleSize: CGSize)
}

/**
 * collectionView的header和footer需要实现的协议
 * Protocol that collectionView's header and footer need to implement
 * header和footer可以设置为String或View
 * header and footer can be set as String or View
 */
public protocol SectionReusableViewRepresentable {
    /**
     * 复用的identifier
     * Reuse identifier
     */
    var identifier: String { get set }
    
    /**
     * 调用此方法来注册
     * Call this method to register
     */
    func regist(to view: QuickListScrollView, for type: QuickListReusableType)

    /**
     * 调用此方法来获取指定section的header或footer相对应的view
     * Call this method to get the view corresponding to the specified section's header or footer
     *
     * - parameter section:    要获取view的section / Section to get view for
     * - parameter view:       所在的view / The view it belongs to
     * - parameter type:       类型（header或footer）/ Type (header or footer)
     *
     * - returns: 对应的view / Corresponding view
     */
    func viewForSection(_ section: Section, in view: QuickListScrollView, type: QuickListReusableType, for indexPath: IndexPath) -> QuickScrollViewReusableView?
}

public protocol SectionHeaderFooterViewRepresentable: SectionReusableViewRepresentable {
    /**
     * 高度
     * Height
     */
    var height: ((_ section: Section, _ estimateItemSize: CGSize, _ scrollDirection: UICollectionView.ScrollDirection) -> CGFloat) { get set }
    
    /**
     * 如果Section的Header或Footer是用字符串创建的，则它将存储在title中，需要在viewForSection中实现具体展示
     * If Section's Header or Footer is created with string, it will be stored in title and needs to implement specific display in viewForSection
     */
    var title: String? { get set }
    
    /**
     * 是否需要悬浮
     * Whether to suspend
     */
    var shouldSuspension: Bool { get set }
}

// MARK: - Classes
/**
 * 用于生成decoration
 * Used to generate decoration
 */
public class FormDecorationView<ViewType: QuickScrollViewReusableView>: FormHeaderFooterReusable {
    
    public typealias ViewSetupBlock = ((_ view: ViewType) -> Void)
    
    /**
     * 复用的ID
     * Reuse ID
     */
    public var identifier: String = "FormDecorationView_\(ViewType.self)"
    /**
     * view获取到之后会走的回调
     * Callback that will be called after view is obtained
     */
    public var onSetupView: ViewSetupBlock?
    /**
     * 当前view的持有
     * Current view holder
     */
    public weak var currentView: ViewType?
    
    /**
     * 是否需要悬浮
     * Whether to suspend
     */
    public var shouldSuspension: Bool = false
    
    /**
     * 展示区域类型
     * Display area type
     */
    public var displayType: FormHeaderFooterDisplayType = .normal
    
    /**
     * view的高度（不设置使用自动布局高度）
     * View height (use autolayout height if not set)
     */
    public var height: ((Form, CGSize, UICollectionView.ScrollDirection) -> CGFloat) {
        set {
            _height = newValue
        }
        get {
            if let heightBlock = _height {
                return heightBlock
            }
            /**
             * 自动布局计算高度
             * Autolayout calculate height
             */
            return { (form, size, direction) in
                if direction == .vertical {
                    return self.autolayoutSize(for: form, estimateItemSize: size, scrollDirection: direction).height
                }
                return self.autolayoutSize(for: form, estimateItemSize: size, scrollDirection: direction).width
            }
        }
    }
    private var _height: ((Form, CGSize, UICollectionView.ScrollDirection) -> CGFloat)?
    
    /**
     * 从xib创建的对象传入对应的xib（将影响注册逻辑）
     * Pass the corresponding xib for objects created from xib (will affect registration logic)
     */
    private var fromNib: UINib?
    
    /**
     调用此方法来获取指定form的header或footer相对应的view
     - parameter type:       类型（header或footer）
     - parameter view:       所在的view
     - parameter indexPath:  位置
     - returns: 对应的view
     */
    public func view(for type: QuickListReusableType, in view: QuickListScrollView, at indexPath: IndexPath) -> QuickScrollViewReusableView? {
        var resultView: ViewType?
        
        // 从重用池获取或创建新的
        // Get from reuse pool or create new
        if let reusedView = view.reuseManager.dequeueReusableView(
            elementKind: type.elementKind,
            identifier: identifier,
            indexPath: indexPath
        ) as? ViewType {
            resultView = reusedView
        } else if let fromNib = self.fromNib {
            resultView = fromNib.instantiate(withOwner: nil, options: nil).first as? ViewType
        } else {
            resultView = ViewType(frame: .zero)
        }
        
        guard let v = resultView else { return nil }
        v.reuseIdentifier = identifier
        v.elementKind = type.elementKind
        v.indexPath = indexPath
        onSetupView?(v)
        self.currentView = v
        return v
    }
    
    /// 注册decoration
    public func regist(to view: QuickListScrollView, for type: QuickListReusableType) {
        view.reuseManager.registerReusableView(ViewType.self, elementKind: type.elementKind, identifier: identifier)
    }

    /**
     初始化
     
     - parameter fromNib:    从xib创建传入对应的xib，否则不传
     - parameter block:      view生成时回调，在此设置一些样式等
     */
    public init(fromNib: UINib? = nil, _ block: ViewSetupBlock? = nil) {
        self.onSetupView = block
        self.fromNib = fromNib
    }
    
    /**
     * 自动布局计算高度
     * Autolayout calculate height
     */
    public func autolayoutSize(for form: Form, estimateItemSize: CGSize, scrollDirection: UICollectionView.ScrollDirection) -> CGSize {
        var tempView: ViewType?
        if let fromNib = fromNib {
            tempView = fromNib.instantiate(withOwner: nil, options: nil).first as? ViewType
        } else {
            tempView = ViewType(frame: CGRect(x: 0, y: 0, width: estimateItemSize.width, height: estimateItemSize.height))
        }
        guard let view = tempView else {
            return .zero
        }
        onSetupView?(view)
        /// 自适应尺寸时需要先设置宽度约束，才能准确使用autolayout计算需要的高度，尤其iOS8及以下
        switch scrollDirection {
        case .vertical:
            view.snp.remakeConstraints { make in
                make.width.equalTo(estimateItemSize.width)
            }
        case .horizontal:
            view.snp.remakeConstraints { make in
                make.height.equalTo(estimateItemSize.height)
            }
        @unknown default:
            return .zero
        }
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        view.snp.removeConstraints()
        return size
    }
}

public class FormCompressibleDecorationView<ViewType: FormCompressibleHeaderFooterView>: FormDecorationView<ViewType>, FormCompressibleHeaderFooterReusable {
    /**
     * 压缩的最小高度（用于支持压缩header的功能，不设置时默认不压缩）
     * Minimum height for compression (used to support compression header functionality, default is not compressed if not set)
     */
    public var minSize: CGSize?
    
    /**
     * 展示内容尺寸变化的方法，子类中可以在这里做内容的压缩、拉伸等处理
     * Method for display content size changes, subclasses can handle content compression, stretching, etc. here
     */
    public func didChangeDispalySize(to visibleSize: CGSize) {
        self.currentView?.didChangeDispalySize(to: visibleSize)
    }
}

/**
 *  用于生成decoration
 */
public class SectionDecorationView<ViewType: QuickScrollViewReusableView>: SectionReusableViewRepresentable {
    
    public typealias ViewSetupBlock = ((_ view: ViewType, _ section: Section) -> Void)
    
    /**
     * 复用的ID
     * Reuse ID
     */
    public var identifier: String = "SectionDecorationView_\(ViewType.self)"
    /**
     * view创建完成的回调
     * Callback that will be called after view is created
     */
    public var onSetupView: ViewSetupBlock?
    /**
     * 当前view的持有
     * Current view holder
     */
    public weak var currentView: ViewType?
    
    /**
     * 从xib创建的对象传入对应的xib（将影响注册逻辑）
     * Pass the corresponding xib for objects created from xib (will affect registration logic)
     */
    private var fromNib: UINib?

    /**
     调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: Section, in view: QuickListScrollView, type: QuickListReusableType, for indexPath: IndexPath) -> QuickScrollViewReusableView? {
        var resultView: ViewType?
        
        // 从重用池获取或创建新的
        // Get from reuse pool or create new
        if let reusedView = view.reuseManager.dequeueReusableView(
            elementKind: type.elementKind,
            identifier: identifier,
            indexPath: indexPath
        ) as? ViewType {
            resultView = reusedView
        } else if let fromNib = self.fromNib {
            resultView = fromNib.instantiate(withOwner: nil, options: nil).first as? ViewType
        } else {
            resultView = ViewType(frame: .zero)
        }
        
        guard let v = resultView else { return nil }
        v.reuseIdentifier = identifier
        v.elementKind = type.elementKind
        v.indexPath = indexPath
        onSetupView?(v, section)
        self.currentView = v
        return v
    }
    
    /**
     * 注册decoration
     * Register decoration
     */
    public func regist(to view: QuickListScrollView, for type: QuickListReusableType) {
        view.reuseManager.registerReusableView(ViewType.self, elementKind: type.elementKind, identifier: identifier)
    }

    /**
     初始化
     
     - parameter fromNib:    从xib创建传入对应的xib，否则不传
     - parameter block:      view生成时回调，在此设置一些样式等
     */
    public init(fromNib: UINib? = nil, _ block: @escaping ViewSetupBlock) {
        self.onSetupView = block
        self.fromNib = fromNib
    }
}

/**
 *  用于生成header或footer
 */
public class SectionHeaderFooterView<ViewType: QuickScrollViewReusableView>: SectionHeaderFooterViewRepresentable {
    
    public typealias ViewSetupBlock = ((_ view: ViewType, _ section: Section) -> Void)
    
    /**
     * 复用的ID
     * Reuse ID
     */
    public var identifier: String = "CollectionHeaderFooterView_\(ViewType.self)"
    /**
     * 标题
     * Title
     */
    public var title: String?
    /**
     * view创建完成的回调
     * Callback that will be called after view is created
     */
    public var onSetupView: ViewSetupBlock?
    /**
     * 当前view的持有
     * Current view holder
     */
    public weak var currentView: ViewType?
    /**
     * view的高度（不设置使用自动布局高度）
     * View height (use autolayout height if not set)
     */
    public var height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat) {
        set {
            _height = newValue
        }
        get {
            if let heightBlock = _height {
                return heightBlock
            }
            return { (section, size, direction) in
                if direction == .vertical {
                    return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).height
                }
                return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).width
            }
        }
    }
    private var _height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat)?
    
    /**
     * 是否需要悬浮
     * Whether to suspend
     */
    public var shouldSuspension: Bool = false
    
    /**
     * 从xib创建的对象传入对应的xib（将影响注册逻辑）
     * Pass the corresponding xib for objects created from xib (will affect registration logic)
     */
    private var fromNib: UINib?

    /**
     调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: Section, in view: QuickListScrollView, type: QuickListReusableType, for indexPath: IndexPath) -> QuickScrollViewReusableView? {
        var resultView: ViewType?
        
        // 从重用池获取或创建新的
        // Get from reuse pool or create new
        if let reusedView = view.reuseManager.dequeueReusableView(
            elementKind: type.elementKind,
            identifier: identifier,
            indexPath: indexPath
        ) as? ViewType {
            resultView = reusedView
        } else if let fromNib = self.fromNib {
            resultView = fromNib.instantiate(withOwner: nil, options: nil).first as? ViewType
        } else {
            resultView = ViewType(frame: .zero)
        }
        
        guard let v = resultView else { return nil }
        v.reuseIdentifier = identifier
        v.elementKind = type.elementKind
        v.indexPath = indexPath
        onSetupView?(v, section)
        currentView = v
        return v
    }
    
    /**
     * 注册Header/Footer
     * Register Header/Footer
     */
    public func regist(to view: QuickListScrollView, for type: QuickListReusableType) {
        view.reuseManager.registerReusableView(ViewType.self, elementKind: type.elementKind, identifier: identifier)
    }

    /**
     初始化
     
     - parameter fromNib:    从xib创建传入对应的xib，否则不传
     - parameter block:      view生成时回调，在此设置一些样式等
     */
    public init(fromNib: UINib? = nil, _ block: ViewSetupBlock? = nil) {
        self.onSetupView = block
        self.fromNib = fromNib
    }
    
    /**
     * 自动布局计算高度
     * Autolayout calculate height
     */
    public func autolayoutSize(for section: Section, estimateItemSize: CGSize, scrollDirection: UICollectionView.ScrollDirection) -> CGSize {
        var tempView: ViewType?
        if let fromNib = fromNib {
            tempView = fromNib.instantiate(withOwner: nil, options: nil).first as? ViewType
        } else {
            tempView = ViewType(frame: CGRect(x: 0, y: 0, width: estimateItemSize.width, height: estimateItemSize.height))
        }
        guard let view = tempView else {
            return .zero
        }
        onSetupView?(view, section)
        switch scrollDirection {
        case .vertical:
            view.snp.remakeConstraints { make in
                make.width.equalTo(estimateItemSize.width)
            }
        case .horizontal:
            view.snp.remakeConstraints { make in
                make.height.equalTo(estimateItemSize.height)
            }
        @unknown default:
            return .zero
        }
        return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

/// 字符串类型的 Header/Footer 视图
/// String type Header/Footer view
class SectionStringHeaderFooterView: QuickScrollViewReusableView {
    /**
     * 展示的标题内容
     * Title content to be displayed
     */
    var title: String? {
        didSet {
            updateText()
        }
    }
    
    /**
     * 滚动方向,默认为竖直方向滚动
     * Scroll direction, default is vertical scrolling
     */
    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            updateText()
            if scrollDirection == .vertical {
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.lessThanOrEqualTo(-16)
                }
            } else {
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(16)
                    make.bottom.lessThanOrEqualTo(-16)
                    make.width.equalTo(17)
                }
            }
        }
    }
    
    func updateText() {
        if scrollDirection == .vertical {
            titleLabel.text = title
        } else {
            if let title = title {
                var changeTitle: String = ""
                for index in title.indices {
                    changeTitle += "\(title[index])\n"
                }
                titleLabel.text = changeTitle
            } else {
                titleLabel.text = title
            }
        }
    }
    
    public let titleLabel: UILabel = UILabel()
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(white: 0.88, alpha: 1.0)
        
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16.7, weight: .medium)
        titleLabel.textColor = UIColor.init(white: 0.1, alpha: 1.0)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.right.lessThanOrEqualTo(-16)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
