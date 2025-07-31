//
//  CornerType.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit

/// 圆角枚举
public struct CornerType {
    
    // MARK:- 快速创建
    // 左上
    public static func leftTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftTop, value: value)
    }
    // 右上
    public static func rightTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightTop, value: value)
    }
    // 左下
    public static func leftBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftBottom, value: value)
    }
    // 右下
    public static func rightBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightBottom, value: value)
    }
    // 全部
    public static func all(_ value: CGFloat) -> [CornerType] {
        return [CornerType(position: .leftTop, value: value),
                CornerType(position: .rightTop, value: value),
                CornerType(position: .leftBottom, value: value),
                CornerType(position: .rightBottom, value: value)]
    }
    
    // MARK:- 获取路径
    /// 生成圆角裁剪的路径
    /// - Parameters:
    ///   - corners: 圆角设置数组
    ///   - size: 目标大小
    ///   - scale: 圆角缩放倍数（corners的value会乘上这个数）
    /// - Returns: 圆角路径
    public static func cornersPath(_ corners: [CornerType], rect: CGRect, scale: CGFloat = 1) -> UIBezierPath? {
        if corners.count == 0 {
            return UIBezierPath(rect: rect)
        } else {
            /// 默认值
            var leftTop: CGFloat = 0
            var rightTop: CGFloat = 0
            var leftBottom: CGFloat = 0
            var rightBottom: CGFloat = 0
            /// 遍历设置圆角值
            for corner in corners {
                switch corner.position {
                    case .leftTop:
                        leftTop = corner.value * scale
                    case .rightTop:
                        rightTop = corner.value * scale
                    case .leftBottom:
                        leftBottom = corner.value * scale
                    case .rightBottom:
                        rightBottom = corner.value * scale
                }
            }
            
            let path = UIBezierPath()
            let maxRadius = min(rect.width, rect.height)
            /// 画左上角圆弧
            var tempValue = min(maxRadius,abs(leftTop))
            if leftTop < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.minY),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: true)
            }
            /// 画右上角圆弧
            tempValue = min(maxRadius,abs(rightTop))
            if rightTop < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.minY),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: true)
            }
            /// 画右下角圆弧
            tempValue = min(maxRadius,abs(rightBottom))
            if rightBottom < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: true)
            }
            /// 画左下角圆弧
            tempValue = min(maxRadius,abs(leftBottom))
            if leftBottom < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: true)
            }
            path.close()
            return path
        }
    }
    
    // 圆角位置
    public enum Position {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }
    // 圆角描述
    public var position: Position
    public var value: CGFloat
}
