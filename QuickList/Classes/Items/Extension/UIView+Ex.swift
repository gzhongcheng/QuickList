//
//  UIView+Ex.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit

// MARK:- List
extension UIView {

    public func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subView in subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
    
    /**
     * 未设置rect时，需要在设置完成frame后调用（自动布局建议在layoutsubviews方法中调用）
     * If rect is not set, it needs to be called after the frame is set (automatic layout suggests calling in the layoutsubviews method)
     */
    public func setCorners(_ corners: [CornerType], rect: CGRect? = nil) {
        let maskPath = CornerType.cornersPath(corners, rect: rect ?? self.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath?.cgPath
        layer.mask = maskLayer
    }
    
    /**
     * 获取所在的VC
     * Get the VC in which the view is located
     */
    public func getViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}){
            if let responder = view?.next{
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
}
