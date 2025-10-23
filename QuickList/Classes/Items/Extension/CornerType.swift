//
//  CornerType.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit

/**
 * 圆角枚举
 * Corner radius enumeration
 */
public struct CornerType {
    
    // MARK: - Quick creation
    /**
     * 左上 
     * Left top
     * - Parameters:
     *   - value: 圆角值 / Corner value
     * - Returns: 圆角类型 / Corner type
     */
    public static func leftTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftTop, value: value)
    }
    /**
     * 右上 
     * Right top
     * - Parameters:
     *   - value: 圆角值 / Corner value
     * - Returns: 圆角类型 / Corner type
     */
    public static func rightTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightTop, value: value)
    }
    /**
     * 左下 
     * Left bottom
     * - Parameters:
     *   - value: 圆角值 / Corner value
     * - Returns: 圆角类型 / Corner type
     */
    public static func leftBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftBottom, value: value)
    }
    /**
     * 右下 
     * Right bottom
     * - Parameters:
     *   - value: 圆角值 / Corner value
     * - Returns: 圆角类型 / Corner type
     */
    public static func rightBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightBottom, value: value)
    }
    /**
     * 全部 
     * All
     * - Parameters:
     *   - value: 圆角值 / Corner value
     * - Returns: 圆角类型数组 / Corner type array
     */
    public static func all(_ value: CGFloat) -> [CornerType] {
        return [CornerType(position: .leftTop, value: value),
                CornerType(position: .rightTop, value: value),
                CornerType(position: .leftBottom, value: value),
                CornerType(position: .rightBottom, value: value)]
    }
    
    // MARK: - Get path
    /**
     * 生成圆角裁剪的路径
     * Generate corner radius clipping path
     * - Parameters:
     *   - corners: 圆角设置数组 / Corner settings array
     *   - size: 目标大小 / Target size
     *   - scale: 圆角缩放倍数（corners的value会乘上这个数） / Corner radius scale multiplier (corners' value will be multiplied by this number)
     * - Returns: 圆角路径 / Corner path
     */
    public static func cornersPath(_ corners: [CornerType], rect: CGRect, scale: CGFloat = 1) -> UIBezierPath? {
        if corners.count == 0 {
            return UIBezierPath(rect: rect)
        } else {
            var leftTop: CGFloat = 0
            var rightTop: CGFloat = 0
            var leftBottom: CGFloat = 0
            var rightBottom: CGFloat = 0
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
            /**
             * 画左上角圆弧
             * Draw left top corner arc
             */
            var tempValue = min(maxRadius,abs(leftTop))
            if leftTop < 0 {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + tempValue))
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.minY),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: false)
            } else if leftTop > 0 {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + tempValue))
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: true)
            } else {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            }
            /**
             * 画右上角圆弧
             * Draw right top corner arc
             */
            tempValue = min(maxRadius,abs(rightTop))
            if rightTop < 0 {
                path.addLine(to: CGPoint(x: rect.maxX - tempValue, y: rect.minY))
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.minY),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: false)
            } else if rightTop > 0 {
                path.addLine(to: CGPoint(x: rect.maxX - tempValue, y: rect.minY))
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: true)
            } else {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            }
            /**
             * 画右下角圆弧
             * Draw right bottom corner arc
             */
            tempValue = min(maxRadius,abs(rightBottom))
            if rightBottom < 0 {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tempValue))
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: false)
            } else if rightBottom > 0 {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tempValue))
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: true)
            } else {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            }
            /**
             * 画左下角圆弧
             * Draw left bottom corner arc
             */
            tempValue = min(maxRadius,abs(leftBottom))
            if leftBottom < 0 {
                path.addLine(to: CGPoint(x: rect.minX + tempValue, y: rect.maxY))
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: false)
            } else if leftBottom > 0 {
                path.addLine(to: CGPoint(x: rect.minX + tempValue, y: rect.maxY))
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: true)
            } else {
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            }
            path.close()
            return path
        }
    }
    
    /**
     * 圆角位置 
     * Corner position
     */
    public enum Position {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }
    /**
     * 圆角描述 
     * Corner description
     */
    public var position: Position
    /**
     * 圆角值 
     * Corner value
     */
    public var value: CGFloat
}
