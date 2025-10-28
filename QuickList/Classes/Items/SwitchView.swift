//
//  SwitchView.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/6/23.
//

import Foundation
import UIKit
import SnapKit

public class SwitchView: UIView {
    // MARK: - Public
    /**
     * 开关的最小尺寸
     * Minimum switch size
     */
    public var minimumSize: CGSize = CGSize(width: 50, height: 30)

    /**
     * 滑块之外的区域的最小宽度，默认为15
     * Minimum width of the area outside the slider, default is 15
     */
    public var outsideAreaMinimumWidth: CGFloat = 15
    
    /**
     * 当前开关状态
     * Current switch state
     */
    public private(set) var isOn: Bool = false
    /**
     * 开关状态变化的回调
     * Callback when switch state changes
     */
    public var onSwitchChanged: ((_ isOn: Bool, _ fromTouch: Bool) -> Void)?
    /**
     * 设置开关状态
     * Set switch state
     */
    public func setOn(_ on: Bool, animated: Bool = false) {
        let needNotice = isOn != on
        isOn = on
        updateUIForSwitchState(animated: animated)
        if needNotice {
            onSwitchChanged?(isOn, false)
        }
    }
    
    /**
     * 滑块上的文案设置
     * Set text on indicator
     */
    public var onIndicatorText: String? {
        didSet {
            setNeedsLayout()
        }
    }
    public var offIndicatorText: String? {
        didSet {
            setNeedsLayout()
        }
    }
    /**
     * 设置开关状态的文本
     * Set text for switch state
     */
    public var onText: String? {
        didSet {
            onTextLabel.text = onText
            setNeedsLayout()
        }
    }
    public var offText: String? {
        didSet {
            offTextLabel.text = offText
            setNeedsLayout()
        }
    }
    
    /**
     * 内容边距（滑块、文案等和背景的间距）
     * Content insets (spacing between indicator, text, and background)
     */
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    /**
     * 颜色配置
     * Color configuration
     */
    public var offIndicatorTextColor: UIColor = .black
    public var onIndicatorTextColor: UIColor = .white
    
    public var offBackgroundColor: UIColor = .lightGray
    public var onBackgroundColor: UIColor = .systemGreen
    
    public var onIndicatorColor: UIColor = .white
    public var offIndicatorColor: UIColor = .white
    
    public var onTextColor: UIColor = .white {
        didSet {
            onTextLabel.textColor = onTextColor
        }
    }
    public var offTextColor: UIColor = .black {
        didSet {
            offTextLabel.textColor = offTextColor
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var maxIndicatorTextWidth = max(onIndicatorText?.size(withAttributes: [.font: indicatorTextLabel.font ?? UIFont.systemFont(ofSize: 14)]).width ?? 0, offIndicatorText?.size(withAttributes: [.font: indicatorTextLabel.font ?? UIFont.systemFont(ofSize: 14)]).width ?? 0)
        maxIndicatorTextWidth = ceil(maxIndicatorTextWidth)
        var maxTextLabelWidth = max(onText?.size(withAttributes: [.font: onTextLabel.font ?? UIFont.systemFont(ofSize: 14)]).width ?? 0, offText?.size(withAttributes: [.font: offTextLabel.font ?? UIFont.systemFont(ofSize: 14)]).width ?? 0)
        maxTextLabelWidth = ceil(maxTextLabelWidth)
        let contentHeight = minimumSize.height - contentInsets.top - contentInsets.bottom
        if maxTextLabelWidth == 0, maxIndicatorTextWidth == 0 {
            return CGSize(
                width: max(minimumSize.width, outsideAreaMinimumWidth + contentHeight + contentInsets.left + contentInsets.right), 
                height: minimumSize.height
            )
        }
        if maxIndicatorTextWidth == 0, maxTextLabelWidth > 0 {
            return CGSize(
                width: max(minimumSize.width, maxTextLabelWidth + contentInsets.left + contentInsets.right + contentHeight + contentHeight * 0.4),
                height: minimumSize.height
            )
        }
        if maxTextLabelWidth == 0, maxIndicatorTextWidth > 0 {
            return CGSize(
                width: max(minimumSize.width, maxIndicatorTextWidth + contentHeight * 0.4 + contentInsets.left + contentInsets.right + outsideAreaMinimumWidth),
                height: minimumSize.height
            )
        }
        return CGSize(
            width: max(minimumSize.width, maxIndicatorTextWidth + contentHeight * 0.4 + maxTextLabelWidth + contentHeight * 0.4 + contentInsets.left + contentInsets.right),
            height: minimumSize.height
        )
    }
    
    // MARK: - Life Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private var indicatorViewWidth: CGFloat = 30
    public override func layoutSubviews() {
        super.layoutSubviews()
        indicatorTextLabel.text = isOn ? onIndicatorText : offIndicatorText
        indicatorTextLabel.sizeToFit()
        let indicatorTextWidth = indicatorTextLabel.bounds.size.width
        let contentHeight = bounds.height - contentInsets.top - contentInsets.bottom
        indicatorViewWidth = max(contentHeight, indicatorTextWidth + contentHeight * 0.4)
        self.indicatorView.frame = CGRect(
            x: isOn ? bounds.width - contentInsets.right - indicatorViewWidth : contentInsets.left,
            y: contentInsets.top,
            width: indicatorViewWidth,
            height: bounds.height - contentInsets.top - contentInsets.bottom
        )
        self.onTextLabel.frame = CGRect(
            x: contentInsets.left + contentHeight * 0.2,
            y: contentInsets.top,
            width: bounds.width - contentInsets.left - contentInsets.right - indicatorViewWidth - contentHeight * 0.2,
            height: contentHeight
        )
        self.offTextLabel.frame = CGRect(
            x: contentInsets.left + indicatorViewWidth,
            y: contentInsets.top,
            width: bounds.width - contentInsets.left - contentInsets.right - indicatorViewWidth - contentHeight * 0.2,
            height: contentHeight
        )
        
        self.indicatorView.layer.cornerRadius = contentHeight * 0.5
        self.backgroundView.layer.cornerRadius = self.bounds.height * 0.5
    }
    
    func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubview(onTextLabel)
        backgroundView.addSubview(offTextLabel)
        addSubview(indicatorView)
        indicatorView.addSubview(indicatorTextLabel)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(minimumSize)
        }
        
        indicatorTextLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began:
            /*
             * 当手势开始或改变时，滑块往中间稍微放大
             * When the gesture starts or changes, the indicator moves slightly inward
             */
            var targetFrame = indicatorView.frame
            if isOn {
                targetFrame = CGRect(
                    x: targetFrame.origin.x - 5,
                    y: targetFrame.origin.y,
                    width: targetFrame.size.width + 5,
                    height: targetFrame.size.height
                )
            } else {
                targetFrame = CGRect(
                    x: targetFrame.origin.x,
                    y: targetFrame.origin.y,
                    width: targetFrame.size.width + 5,
                    height: targetFrame.size.height
                )
            }
            UIView.animate(withDuration: 0.2) {
                self.indicatorView.frame = targetFrame
            }
        case .ended:
            /*
             * 当手势结束时，如果点击区域还在开关范围内，则切换开关状态
             * When the gesture ends, if the click area is still within the switch range, switch the switch state
             */
            guard sender.view == self else { return }
            let touchPoint = sender.location(in: self)
            guard self.bounds.contains(touchPoint) else {
                /*
                 * 否则恢复原样
                 * Otherwise restore to original state
                 */
                UIView.animate(withDuration: 0.2) {
                    self.indicatorView.frame = CGRect(
                        x: self.isOn ? self.bounds.width - self.contentInsets.right - self.indicatorViewWidth : self.contentInsets.left,
                        y: self.contentInsets.top,
                        width: self.indicatorViewWidth,
                        height: self.bounds.height - self.contentInsets.top - self.contentInsets.bottom
                    )
                }
                return
            }
            isOn.toggle()
            onSwitchChanged?(isOn, true)
            UIView.animate(withDuration: 0.2) {
                self.indicatorView.frame = CGRect(
                    x: self.isOn ? self.bounds.width - self.contentInsets.right - self.indicatorViewWidth : self.contentInsets.left,
                    y: self.contentInsets.top,
                    width: self.indicatorViewWidth,
                    height: self.bounds.height - self.contentInsets.top - self.contentInsets.bottom
                )
                self.updateUIForSwitchState()
            }
        default:
            break
        }
    }
        
    public func updateUIForSwitchState(animated: Bool = false) {
        let updateBlock = {
            self.backgroundView.backgroundColor = self.isOn ? self.onBackgroundColor : self.offBackgroundColor
            self.indicatorView.backgroundColor = self.isOn ? self.onIndicatorColor : self.offIndicatorColor
            self.indicatorTextLabel.textColor = self.isOn ? self.onIndicatorTextColor : self.offIndicatorTextColor
            self.onTextLabel.alpha = self.isOn ? 1.0 : 0
            self.offTextLabel.alpha = self.isOn ? 0 : 1.0
            self.indicatorTextLabel.text = self.isOn ? self.onIndicatorText : self.offIndicatorText
            self.backgroundView.snp.updateConstraints { make in
                make.size.equalTo(self.intrinsicContentSize)
            }
            self.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                updateBlock()
            }
        } else {
            updateBlock()
        }
    }

        
    
    // MARK: Private
    public let backgroundView: UIControl = {
        let view = UIControl()
        view.backgroundColor = .lightGray
        return view
    }()
    
    public let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public let indicatorTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    public let onTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    public let offTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
}
