//
//  SwipedItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/9/5.
//

import Foundation
import SnapKit

/// 支持左滑事件的cell
open class SwipeItemCell: ItemCell {
    /// 是否可以左滑
    public var canSwiped: Bool = true
    
    /// 左滑时显示的按钮
    public var swipedActionButtons: [SwipeActionButton] = [] {
        didSet {
            for button in buttonsContainerView.subviews {
                button.removeFromSuperview()
            }
            var totalWidth: CGFloat = 0
            for button in swipedActionButtons.reversed() {
                button.rightSpacingToCell = totalWidth
                button.didTouchUpInsideAction = { [weak self] in
                    self?.closeSwipeActions()
                }
                buttonsContainerView.addSubview(button)
                button.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    if button == swipedActionButtons.first {
                        make.width.greaterThanOrEqualTo(button.width)
                        make.leading.equalTo(0)
                    } else {
                        make.width.equalTo(button.width)
                    }
                    make.trailing.equalTo(0).priority(.high)
                }
                totalWidth += button.width
            }
        }
    }
    
    /// 左滑超过cell一半时放手，是否自动触发第一个按钮的事件
    public var autoTriggerFirstButton: Bool = false
    
    /// 会跟随左滑的内容视图
    public var swipeContentView: UIView = UIView()
    
    /// 左滑出现的按钮容器
    public var buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    open override func setup() {
        super.setup()
        self.clipsToBounds = true
        
        self.contentView.addSubview(swipeContentView)
        self.swipeContentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.contentView.addSubview(buttonsContainerView)
        buttonsContainerView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(0)
        }
        configureSwipeGesture()
    }
    
    private func configureSwipeGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        self.isUserInteractionEnabled = true
    }
    
    var gestureBeginProgress: CGFloat = 0
    var lastGestureProgress: CGFloat = 0
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard canSwiped, !swipedActionButtons.isEmpty else { return }
        
        let translation = gesture.translation(in: self.contentView)
        let velocity = gesture.velocity(in: self.contentView)
        let totalWidth = totalButtonsWidth()
        
        switch gesture.state {
        case .began:
            gestureBeginProgress = swipeProgress
            self.contentView.bringSubviewToFront(self.buttonsContainerView)
        case .changed:
            let progress = max(0, -translation.x / totalWidth + gestureBeginProgress)
            swipeProgressUpdated(progress: progress)
            lastGestureProgress = progress
        case .ended, .cancelled:
            if velocity.x > 500 {
                closeSwipeActions()
                return
            }
            if velocity.x < -500 {
                openSwipeActions()
                return
            }
            let shouldOpen = swipeProgress > 0.5
            if shouldOpen {
                openSwipeActions()
            } else {
                closeSwipeActions()
            }
        default:
            break
        }
    }
    
    private func totalButtonsWidth() -> CGFloat {
        return swipedActionButtons.reduce(0) { $0 + $1.width }
    }
    
    private var swipeProgress: CGFloat = 0 // 0 ~ 1
    public func swipeProgressUpdated(progress: CGFloat) {
        let realProgress = min(max(progress, 0), 1)
        let totalWidth = totalButtonsWidth()
        self.swipeContentView.snp.updateConstraints { make in
            make.centerX.equalToSuperview().offset(-totalWidth * realProgress)
        }
        self.buttonsContainerView.snp.updateConstraints { make in
            make.width.equalTo(totalWidth * progress)
        }
        for button in swipedActionButtons {
            button.snp.updateConstraints { make in
                make.trailing.equalTo(-button.rightSpacingToCell * realProgress).priority(.high)
            }
        }
        swipeProgress = realProgress
    }

    public func openSwipeActions() {
        if autoTriggerFirstButton, lastGestureProgress * totalButtonsWidth() > self.bounds.width * 0.5 {
            self.swipedActionButtons.first?.touchUpInsideAction?()
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.swipedActionButtons.first?.snp.updateConstraints({ make in
                    make.trailing.equalTo(0).priority(.high)
                })
                self.buttonsContainerView.snp.updateConstraints { make in
                    make.width.equalTo(self.bounds.width)
                }
                self.layoutIfNeeded()
                self.buttonsContainerView.alpha = 0
            } completion: { f in
                self.swipeProgressUpdated(progress: 0)
                self.layoutIfNeeded()
                self.buttonsContainerView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.swipeProgressUpdated(progress: 1)
                self.layoutIfNeeded()
            }
        }
    }
    
    public func closeSwipeActions() {
        UIView.animate(withDuration: 0.25) {
            self.swipeProgressUpdated(progress: 0)
            self.layoutIfNeeded()
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        closeSwipeActions()
    }
}

extension SwipeItemCell: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: self)
            if abs(velocity.x) > abs(velocity.y) {
                return true
            }
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            return false
        }
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
    }
}

public protocol SwipeItemType {
    func configureSwipe()
}

// MARK: - SwipedAutolayoutItemOf
// SwipedAutolayoutItemOf
open class SwipeAutolayoutItemOf<Cell: SwipeItemCell>: AutolayoutItemOf<Cell>, SwipeItemType {
    /// 是否可以左滑
    public var canSwiped: Bool = true
    /// 左滑时显示的按钮
    public var swipedActionButtons: [SwipeActionButton] = []
    /// 左滑超过cell一半时放手，是否自动触发第一个按钮的事件
    public var autoTriggerFirstButton: Bool = false
    
    public func configureSwipe() {
        guard let cell = self.cell as? SwipeItemCell else { return }
        cell.canSwiped = canSwiped
        cell.swipedActionButtons = swipedActionButtons
        cell.autoTriggerFirstButton = autoTriggerFirstButton
    }
}

// MARK: - SwipedItemOf
// SwipedAutolayoutItemOf
open class SwipeItemOf<Cell: SwipeItemCell>: ItemOf<Cell>, SwipeItemType {
    /// 是否可以左滑
    public var canSwiped: Bool = true
    /// 左滑时显示的按钮
    public var swipedActionButtons: [SwipeActionButton] = []
    /// 左滑超过cell一半时放手，是否自动触发第一个按钮的事件
    public var autoTriggerFirstButton: Bool = false
    
    public func configureSwipe() {
        guard let cell = self.cell as? SwipeItemCell else { return }
        cell.canSwiped = canSwiped
        cell.swipedActionButtons = swipedActionButtons
        cell.autoTriggerFirstButton = autoTriggerFirstButton
    }
}

// MARK: - SwipedActionButton
/// 左滑时显示的按钮
public class SwipeActionButton: UIControl {
    /// 展示到cell上时的右侧距离
    var rightSpacingToCell: CGFloat = 0
    
    /// 点击按钮后是否自动收起
    public var autoCloseSwipe: Bool = true
    
    /// 按钮宽度
    public var width: CGFloat = 80
    
    /// 图标和文字的间距
    public var iconTextSpace: CGFloat = 5 {
        didSet {
            titleLabel.snp.updateConstraints { _ in
                iconTextSpaceConstraint?.offset(iconTextSpace)
            }
        }
    }
    
    /// 文字
    public var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            iconTextSpaceConstraint?.constraint.isActive = (newValue != nil && icon != nil)
        }
    }
    
    public var titleColor: UIColor {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    public var font: UIFont {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }
    
    public var icon: UIImage? {
        get { return iconImageView.image }
        set {
            iconImageView.image = newValue
            iconTextSpaceConstraint?.constraint.isActive = (newValue != nil && icon != nil)
        }
    }
    
    public var iconTintColor: UIColor {
        get { return iconImageView.tintColor ?? .white }
        set { iconImageView.tintColor = newValue }
    }
    
    /// 点击事件
    public var touchUpInsideAction: (() -> Void)?
    /// 点击事件完成回调
    var didTouchUpInsideAction: (() -> Void)?
    
    public init(icon: UIImage? = nil, iconTintColor: UIColor = .white, title: String? = nil, titleColor: UIColor = .white, font: UIFont = .systemFont(ofSize: 14), backgroundColor: UIColor = .red, width: CGFloat = 80, autoCloseSwipe: Bool = true, touchUpInside: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.width = width
        self.icon = icon
        self.iconTintColor = iconTintColor
        self.titleLabel.text = title
        self.titleColor = titleColor
        self.font = font
        self.buttonBackgroundColor = backgroundColor
        self.touchUpInsideAction = touchUpInside
        self.autoCloseSwipe = autoCloseSwipe
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = buttonBackgroundColor
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.top.greaterThanOrEqualToSuperview().offset(5)
        }
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(0)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().priority(.low)
            iconTextSpaceConstraint = make.top.equalTo(iconImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(0)
            make.bottom.equalToSuperview()
        }
        
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        touchUpInsideAction?()
        if autoCloseSwipe {
            didTouchUpInsideAction?()
        }
    }
    
    private var iconTextSpaceConstraint: ConstraintMakerEditable?
    private let contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    public lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public var buttonBackgroundColor: UIColor = .red {
        didSet {
            self.backgroundColor = buttonBackgroundColor
        }
    }
}
