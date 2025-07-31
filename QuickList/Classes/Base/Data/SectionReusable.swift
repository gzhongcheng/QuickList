//
//  SectionReusable.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation
import UIKit
import SnapKit

/**
 * 表示Section的header或footer
 */
public enum SectionReusableType: String {
    case header
    case footer
    case decoration
    case suspensionDecoration
    
    /// 系统collectionview对应的kind
    var elementKind: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        case .decoration:
            return "QuickListSectionDecorationView"
        case .suspensionDecoration:
            return "QuickListSectionSuspensionDecorationView"
        }
    }
}

/**
 *  collectionView的header和footer需要实现的协议
 *  header和footer可以设置为String或View
 */
public protocol SectionReusableViewRepresentable {
    /// 复用的identifier
    var identifier: String { get set }
    
    /// 调用此方法来注册
    func regist(to view: FormViewProtocol, for type: SectionReusableType)

    /**
     调用此方法来获取指定section的header或footer相对应的view
     
     - parameter section:    要获取view的section
     - parameter collectionView: 所在的view
     - parameter type:       类型（header或footer）
     
     - returns: 对应的view
     */
    func viewForSection(_ section: Section,in view: FormViewProtocol, type: SectionReusableType, for indexPath: IndexPath) -> UICollectionReusableView?
}

public protocol SectionHeaderFooterViewRepresentable: SectionReusableViewRepresentable {
    /// 高度
    var height: ((_ section: Section, _ estimateItemSize: CGSize, _ scrollDirection: UICollectionView.ScrollDirection) -> CGFloat) { get set }
    
    /// 如果Section的Header或Footer是用字符串创建的，则它将存储在title中，需要在viewForSection中实现具体展示
    var title: String? { get set }
    
    /// 是否需要悬浮
    var shouldSuspension: Bool { get set }
}

/**
 *  用于生成decoration
 */
public class SectionDecorationView<ViewType: UICollectionReusableView>: SectionReusableViewRepresentable {
    
    public typealias ViewCreatedBlock = ((_ view: ViewType) -> Void)
    
    /// 复用的ID
    public var identifier: String = "SectionDecorationView_\(ViewType.self)"
    /// 标题
    public var title: String?
    /// view获取到之后会走的回调
    public var onCreated: ViewCreatedBlock?
    /// view创建完成的回调
    public var onSetupView: ((_ view: ViewType, _ section: Section) -> Void)?
    /// 当前view的持有
    public weak var currentView: ViewType?
    
    /// view的高度（不设置使用自动布局高度）
    public var height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat) {
        set {
            _height = newValue
        }
        get {
            if let heightBlock = _height {
                return heightBlock
            }
            /// 自动布局计算高度
            return { (section, size, direction) in
                if direction == .vertical {
                    return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).height
                }
                return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).width
            }
        }
    }
    private var _height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat)?
    
    /// 是否需要悬浮
    public var shouldSuspension: Bool = false
    
    /// 从xib创建的对象传入对应的xib（将影响注册逻辑）
    private var fromNib: UINib?

    /**
     CollectionView中调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: Section, in view: FormViewProtocol, type: SectionReusableType, for indexPath: IndexPath) -> UICollectionReusableView? {
        let resultView: ViewType? = view.dequeueReusableSupplementaryView(ofKind: type.elementKind, withReuseIdentifier: identifier, for: indexPath) as? ViewType
        guard let v = resultView else { return nil }
        onCreated?(v)
        onSetupView?(v, section)
        self.currentView = v
        return v
    }
    
    /// 注册decoration
    public func regist(to view: FormViewProtocol, for type: SectionReusableType) {
        if let fromNib = self.fromNib {
            view.register(fromNib, forCellWithReuseIdentifier: identifier)
        } else {
            view.register(ViewType.self, forSupplementaryViewOfKind: type.elementKind, withReuseIdentifier: identifier)
        }
    }

    /**
     初始化
     
     - parameter fromNib:    从xib创建传入对应的xib，否则不传
     - parameter block:      view生成时回调，在此设置一些样式等
     */
    public init(fromNib: UINib? = nil, _ block: @escaping ViewCreatedBlock) {
        self.onCreated = block
        self.fromNib = fromNib
    }
    
    /// 自动布局计算高度
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
        onCreated?(view)
        onSetupView?(view, section)
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
        return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

/**
 *  用于生成header或footer
 */
public class SectionHeaderFooterView<ViewType: UICollectionReusableView>: SectionHeaderFooterViewRepresentable {
    
    public typealias ViewCreatedBlock = ((_ view: ViewType, _ section: Section) -> Void)
    
    /// 复用的ID
    public var identifier: String = "CollectionHeaderFooterView_\(ViewType.self)"
    /// 标题
    public var title: String?
    /// view获取到之后会走的回调
    public var onCreated: ViewCreatedBlock?
    /// view创建完成的回调
    public var onSetupView: ((_ view: ViewType, _ section: Section) -> Void)?
    /// 当前view的持有
    public weak var currentView: ViewType?
    /// view的高度（不设置使用自动布局高度）
    public var height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat) {
        set {
            _height = newValue
        }
        get {
            if let heightBlock = _height {
                return heightBlock
            }
            /// 自动布局计算高度
            return { (section, size, direction) in
                if direction == .vertical {
                    return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).height
                }
                return self.autolayoutSize(for: section, estimateItemSize: size, scrollDirection: direction).width
            }
        }
    }
    private var _height: ((Section, CGSize, UICollectionView.ScrollDirection) -> CGFloat)?
    
    /// 是否需要悬浮
    public var shouldSuspension: Bool = false
    
    /// 从xib创建的对象传入对应的xib（将影响注册逻辑）
    private var fromNib: UINib?

    /**
     CollectionView中调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: Section, in view: FormViewProtocol, type: SectionReusableType, for indexPath: IndexPath) -> UICollectionReusableView? {
        let resultView: ViewType? = view.dequeueReusableSupplementaryView(ofKind: type.elementKind, withReuseIdentifier: identifier, for: indexPath) as? ViewType
        guard let v = resultView else { return nil }
        onCreated?(v, section)
        onSetupView?(v, section)
        currentView = v
        return v
    }
    
    /// 注册Header/Footer
    public func regist(to view: FormViewProtocol, for type: SectionReusableType) {
        if let fromNib = self.fromNib {
            view.register(fromNib, forCellWithReuseIdentifier: identifier)
        } else {
            view.register(ViewType.self, forSupplementaryViewOfKind: type.elementKind, withReuseIdentifier: identifier)
        }
    }

    /**
     初始化
     
     - parameter fromNib:    从xib创建传入对应的xib，否则不传
     - parameter block:      view生成时回调，在此设置一些样式等
     */
    public init(fromNib: UINib? = nil, _ block: @escaping ViewCreatedBlock) {
        self.onCreated = block
        self.fromNib = fromNib
    }
    
    /// 自动布局计算高度
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
        onCreated?(view, section)
        onSetupView?(view, section)
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
        return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

class SectionStringHeaderFooterView: UICollectionReusableView {
    /// 展示的标题内容
    var title: String? {
        didSet {
            updateText()
        }
    }
    
    /// 滚动方向,默认为竖直方向滚动
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
    
    override init(frame: CGRect) {
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
