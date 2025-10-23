//
//  FormViewProtocol.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/6.
//

import Foundation

/**
 * 长按事件处理代理
 * Long press event handling delegate
 */
public protocol FormViewLongTapProtorol: UIView {
    /**
     * 长按手势位置获取indexPath
     * Get indexPath for long press gesture position
     */
    func indexPathForItem(at point: CGPoint) -> IndexPath?
    /**
     * 开始移动item
     * Begin moving item
     */
    func beginInteractiveMovementForItem(at indexPath: IndexPath) -> Bool
    /**
     * 移动过程
     * Movement process
     */
    func updateInteractiveMovementTargetPosition(_ targetPosition: CGPoint)
    /**
     * 移动结束
     * Movement end
     */
    func endInteractiveMovement()
    /**
     * 移动取消
     * Movement cancel
     */
    func cancelInteractiveMovement()
}

@propertyWrapper
public class UniqueAddress {
  public var wrappedValue: UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
  }

  public init() { }
}
