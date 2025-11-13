//
//  EditableItemMoveIndicator.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2025/11/12.
//

import Foundation

public class EditableItemMoveIndicator: UIView {
    // MARK: - Public
    public var arrowColor: UIColor = .black {
        didSet {
            starArrowView.backgroundColor = arrowColor
            endArrowView.backgroundColor = arrowColor
        }
    }
    public var lineColor: UIColor = .black {
        didSet {
            lineView.backgroundColor = lineColor
        }
    }
    
    public var arrowSize: CGSize = CGSize(width: 16, height: 16)
    public var lineWidth: CGFloat = 2

    public func updatePosition(to targetFrame: CGRect, direction: UICollectionView.ScrollDirection) {
        self.frame = targetFrame
        switch direction {
        case .vertical:
            lineView.frame = CGRect(x: (targetFrame.width - lineWidth) * 0.5, y: 0, width: lineWidth, height: targetFrame.height)
            starArrowView.frame = CGRect(x: (targetFrame.width - arrowSize.width) * 0.5, y: -arrowSize.height, width: arrowSize.width, height: arrowSize.height)
            endArrowView.frame = CGRect(x: (targetFrame.width - arrowSize.width) * 0.5, y: targetFrame.height, width: arrowSize.width, height: arrowSize.height)
            let starArrowPath = UIBezierPath()
            starArrowPath.move(to: CGPoint(x: 0, y: arrowSize.height * 0.5))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.5))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5 + lineWidth * 0.5, y: arrowSize.height))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5 - lineWidth * 0.5, y: arrowSize.height))
            starArrowPath.close()
            starArrowLayer.path = starArrowPath.cgPath
            let endArrowPath = UIBezierPath()
            endArrowPath.move(to: CGPoint(x: 0, y: arrowSize.height * 0.5))
            endArrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.5))
            endArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5 + lineWidth * 0.5, y: 0))
            endArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5 - lineWidth * 0.5, y: 0))
            endArrowPath.close()
            endArrowLayer.path = endArrowPath.cgPath
        case .horizontal:
            lineView.frame = CGRect(x: 0, y: (targetFrame.height - lineWidth) * 0.5, width: targetFrame.width, height: lineWidth)
            starArrowView.frame = CGRect(x: -arrowSize.width, y: (targetFrame.height - arrowSize.height) * 0.5, width: arrowSize.width, height: arrowSize.height)
            endArrowView.frame = CGRect(x: targetFrame.width, y: (targetFrame.height - arrowSize.height) * 0.5, width: arrowSize.width, height: arrowSize.height)
            let starArrowPath = UIBezierPath()
            starArrowPath.move(to: CGPoint(x: arrowSize.width * 0.5, y: 0))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5, y: arrowSize.height))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.5 + lineWidth * 0.5))
            starArrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.5 - lineWidth * 0.5))
            starArrowPath.close()
            starArrowLayer.path = starArrowPath.cgPath
            let endArrowPath = UIBezierPath()
            endArrowPath.move(to: CGPoint(x: arrowSize.width * 0.5, y: 0))
            endArrowPath.addLine(to: CGPoint(x: arrowSize.width * 0.5, y: arrowSize.height))
            endArrowPath.addLine(to: CGPoint(x: 0, y: arrowSize.height * 0.5 + lineWidth * 0.5))
            endArrowPath.addLine(to: CGPoint(x: 0, y: arrowSize.height * 0.5 - lineWidth * 0.5))
            endArrowPath.close()
            endArrowLayer.path = endArrowPath.cgPath
        default:
            return
        }
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
    
    func setupUI() {
        addSubview(lineView)
        addSubview(starArrowView)
        addSubview(endArrowView)
        starArrowView.layer.mask = starArrowLayer
        endArrowView.layer.mask = endArrowLayer
    }
    
    // MARK: Private
    private var lineView: UIView = UIView()
    private var starArrowView: UIView = UIView()
    private var endArrowView: UIView = UIView()
    private var starArrowLayer: CAShapeLayer = CAShapeLayer()
    private var endArrowLayer: CAShapeLayer = CAShapeLayer()

}
