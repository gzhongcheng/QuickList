//
//  UIImage+Ex.swift
//  GZCExtends
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Kingfisher

public extension UIImage {
    
    /// 根据给定的比例缩放图片，支持gif
    ///
    /// - Parameter scale: 缩放倍数
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片
    /// - Returns: 新图对象
    func reSize(scale: CGFloat, originData: Data? = nil) -> UIImage? {
        return reSizeWithJudgment(scale: scale,originData: originData).0
    }
    
    /// 根据给定的比例缩放图片，支持gif，返回值带是否gif的判断值
    ///
    /// - Parameter scale: 缩放倍数
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片
    /// - Returns: 元组，(压缩后的UIImage对象, 是否gif图片)
    func reSizeWithJudgment(scale: CGFloat, originData: Data? = nil) -> (UIImage?, Bool) {
        /// 有原始数据则判断是否gif
        if let data = originData,
           data.kf.imageFormat == ImageFormat.GIF
        {
            /// 返回压缩后的图片
            return (KingfisherWrapper.animatedImage(data: data, options: .init(scale: 1/scale)), true)
        }
        let verificationScale = max(0, scale)
        /// 计算目标尺寸
        let targetSize: CGSize = CGSize(width: Int(self.size.width * verificationScale), height: Int(self.size.height * verificationScale))
        /// 重绘图片
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let newImg = theImage else { return  (nil, false)}
        return (newImg, false)
    }
}
