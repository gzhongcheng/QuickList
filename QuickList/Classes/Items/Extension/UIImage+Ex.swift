//
//  UIImage+Ex.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Foundation

public extension UIImage {
    
    /// 添加圆角
    /// - Parameters:
    ///   - corners: 圆角配置数组
    ///   - imageScale: 圆角缩放倍数
    ///   - opaque: 是否包含透明通道，默认false
    /// - Returns: 添加了圆角的图片
    func corners(_ corners: [CornerType], imageScale: CGFloat = 1, toSize: CGSize? = nil, opaque: Bool = false) -> UIImage? {
        var targetSize: CGSize = size
        if toSize != nil {
            targetSize = toSize!
        }
        /// 开始画布
        UIGraphicsBeginImageContextWithOptions(targetSize, opaque, UIScreen.main.scale)
        /// 画圆角
        let rect = CGRect(origin: .zero, size: targetSize)
        CornerType.cornersPath(corners, rect: rect, scale: imageScale)?.addClip()
        draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
