//
//  UIImage+Ex.swift
//  GZCExtends
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Kingfisher

public extension UIImage {
    
    /// 根据给定的比例缩放图片，支持gif
    /// Resize image with given scale, supports gif
    /// 
    /// - Parameter scale: 缩放倍数 / Scale factor
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片 / Original data of the image, used to determine if it is gif, and to scale the gif, if not passed, it is assumed to be a non-static image
    /// - Returns: 新图对象 / New image object
    func reSize(scale: CGFloat, originData: Data? = nil) -> UIImage? {
        return reSizeWithJudgment(scale: scale,originData: originData).0
    }
    
    /// 根据给定的比例缩放图片，支持gif，返回值带是否gif的判断值
    /// Resize image with given scale, supports gif, returns value with whether gif is determined
    /// 
    /// - Parameter scale: 缩放倍数 / Scale factor
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片 / Original data of the image, used to determine if it is gif, and to scale the gif, if not passed, it is assumed to be a non-static image
    /// - Returns: 元组，(压缩后的UIImage对象, 是否gif图片) / Tuple, (compressed UIImage object, whether gif image)
    func reSizeWithJudgment(scale: CGFloat, originData: Data? = nil) -> (UIImage?, Bool) {
        /**
         * 有原始数据则判断是否gif
         * If there is original data, determine if it is gif
         */
        if let data = originData,
           data.kf.imageFormat == ImageFormat.GIF
        {
            /**
             * 返回压缩后的图片
             * Return the compressed image
             */
            return (KingfisherWrapper.animatedImage(data: data, options: .init(scale: 1/scale)), true)
        }
        let verificationScale = max(0, scale)
        /**
         * 计算目标尺寸
         * Calculate target size
         */
        let targetSize: CGSize = CGSize(width: Int(self.size.width * verificationScale), height: Int(self.size.height * verificationScale))
        /**
         * 重绘图片
         * Redraw image
         */
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let newImg = theImage else { return  (nil, false)}
        return (newImg, false)
    }
}
