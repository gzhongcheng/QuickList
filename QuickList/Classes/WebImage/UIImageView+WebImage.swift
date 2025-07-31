//
//  UIImageView+WebImage.swift
//  GZCExtends
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Kingfisher
import KingfisherWebP

private var imageDownloadUrlKey: Void?
private var imageDownloadTaskKey: Void?
private var imageCacheKeyKey: Void?
private var originImageCacheKeyKey: Void?

public extension UIImageView {
    
    /// 全局添加webP格式解析
    static func addWebPParsing() {
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
    }
    
    /// 最新一次图片下载地址
    private var imageDownloadUrl: String? {
        get { return objc_getAssociatedObject(self, &imageDownloadUrlKey) as? String }
        set { objc_setAssociatedObject(self, &imageDownloadUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 最新一次图片下载任务
    private var imageDownloadTask: ImageDownloadTask? {
        get { return objc_getAssociatedObject(self, &imageDownloadTaskKey) as? ImageDownloadTask }
        set { objc_setAssociatedObject(self, &imageDownloadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 最新一次原图缓存Key
    private var originImageCacheKey: String? {
        get { return objc_getAssociatedObject(self, &originImageCacheKeyKey) as? String }
        set { objc_setAssociatedObject(self, &originImageCacheKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 最新一次小图缓存Key
    private var imageCacheKey: String? {
        get { return objc_getAssociatedObject(self, &imageCacheKeyKey) as? String }
        set { objc_setAssociatedObject(self, &imageCacheKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 为减少列表加载图片的卡顿，加载网络图片时使用自己的缓存策略，限制图片的最大宽高进行缓存（宽高超过的话会先压缩再缓存压缩后的图片，并且设置独立的缓存Key）
    /// - Parameters:
    ///   - urlString: 图片地址，可为空，传cacheKey来获取已缓存的图片
    ///   - placeholderImage: 加载中的图片
    ///   - indicatorType: 加载时展示的加载动画，默认为无
    ///   - loadFaildImage: 加载失败展示的图片
    ///   - cacheOriginImage: 是否缓存原图，默认为true
    ///   - cacheKey: 缓存key，不传则对压缩的图片采用原地址+_resize_+限制的宽度/高度 格式进行缓存
    ///   - maxWidth: 限制的最大宽度，可不传，内部会自动乘上屏幕的scale
    ///   - maxHeight: 限制的最大高度，可不传，内部会自动乘上屏幕的scale
    ///   - options: 下载图片时用到，默认为[], 如果不设置processor的话，默认会使用.processor(WebPProcessor.default)进行解码
    ///   - progressBlock: 进度回调
    ///   - completionHandler: 加载完成回调
    func loadWebImage(
        _ urlString: String? = nil,
        placeholderImage: UIImage? = nil,
        indicatorType: IndicatorType? = nil,
        loadFaildImage: UIImage? = nil,
        cacheOriginImage: Bool = true,
        cacheKey: String? = nil,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        options: KingfisherOptionsInfo = [], //.fromMemoryCacheOrRefresh，.backgroundDecode
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ImageLoadResult? = nil
    ) {
        mainThread {
            self.image = placeholderImage
        }
        if let task = imageDownloadTask {
            if task.url.absoluteString != urlString {
                /// url不一致, 取消上一次的下载
                task.cancel()
                imageDownloadTask = nil
            } else {
                /// url一致，不用再下载
                return
            }
        }
        /// 记录当前请求地址
        imageDownloadUrl = urlString
        ///如果无法直接转换为URL，需要进行转码操作
        if URL(string: imageDownloadUrl ?? "") == nil {
            let decodeUrlString: String? = imageDownloadUrl?.removingPercentEncoding
            if let finalUrlString = decodeUrlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                /// 记录当前请求地址
                imageDownloadUrl = finalUrlString
            }
        }
        
        /// 拼装Key
        /// 小图的key
        var key: String!
        /// 原图的key
        var originKey: String!
        
        /// 为减少缓存图片的数量，将图片向上使用 divPoint 取整进行缓存
        let divPoint: Int = 50
        var width: Int? = maxWidth != nil ? Int(maxWidth!) : nil
        var height: Int? = maxHeight != nil ? Int(maxHeight!) : nil
        var reizeString = "_resize_"
        if width != nil {
            let remainder = width! % divPoint
            width = width! - (remainder > 0 ? (remainder - divPoint) : 0)
            reizeString += "width_\(width!)"
        }
        if height != nil {
            let remainder = height! % divPoint
            height = height! - (remainder > 0 ? (remainder - divPoint) : 0)
            reizeString += "height_\(height!)"
        }
        
        if cacheKey != nil {
            originKey = cacheKey
            if width != nil || height != nil {
                key = cacheKey! + reizeString
            } else {
                key = cacheKey
            }
        } else if imageDownloadUrl != nil {
            originKey = imageDownloadUrl
            if width != nil || height != nil {
                key = imageDownloadUrl! + reizeString
            } else {
                key = imageDownloadUrl
            }
        } else {
            /// urlString和cacheKey都没有传
            self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource), completionHandler: completionHandler)
            return
        }
        originImageCacheKey = originKey
        imageCacheKey = key
        /// 查看是否已缓存小图
        if ImageCache.default.imageCachedType(forKey: key) == .none {
            /// 查看是否有原图的缓存
            /// 未缓存
            if ImageCache.default.imageCachedType(forKey: originKey) == .none {
                /// 未缓存，从web下载图片，并缓存
                guard let urlStr = imageDownloadUrl else {
                    /// urlString未正确设置，且缓存中不存在cacheKey
                    self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource), completionHandler: completionHandler)
                    return
                }
                guard let finalUrl = URL(string: urlStr) else {
                    /// url创建失败
                    self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource), completionHandler: completionHandler)
                    return
                }
                /// 未缓存，开始下载
                /// 显示加载控件
                self.kf.indicatorType = indicatorType ?? .none
                mainThread {
                    self.kf.indicator?.startAnimatingView()
                }
                /// 拼装Options
                var totalOptions: KingfisherOptionsInfo = []
                var shouldAddProcessor: Bool = true
                for option in options {
                    switch option {
                    case .processor(_):
                        shouldAddProcessor = false
                    default:
                        break
                    }
                    totalOptions.append(option)
                }
                if shouldAddProcessor {
                    totalOptions.append(.processor(WebPProcessor.default))
                }
                imageDownloadTask = ImageDownloadManager.shared.addTask(url: finalUrl, options: totalOptions) {[weak self] (url, current, total) in
                    if let progressCallBack = progressBlock,
                       self?.imageDownloadUrl == finalUrl.absoluteString {
                        progressCallBack(current, total)
                    }
                } completionHandler: {[weak self] (url, result) in
                    guard self?.imageDownloadUrl == finalUrl.absoluteString else {
                        /// 请求地址与当前回调不一致，不做处理
                        self?.imageDownloadTask = nil
                        return
                    }
                    mainThread {
                        self?.kf.indicator?.stopAnimatingView()
                    }
                    switch result {
                    case .success(let loadingResult): // ImageLoadingResult
                        let originData = loadingResult.originalData
                        let originImage = loadingResult.image
                        var resultImage: UIImage?
                        var isGif: Bool = false
                        /// 取大的倍数缩放
                        var scale: CGFloat?
                        if width != nil {
                            scale = CGFloat(width!) / originImage.size.width
                        }
                        if height != nil {
                            let heightScale = CGFloat(height!) / originImage.size.height
                            scale = scale == nil ? heightScale : max(scale!, heightScale)
                        }
                        if scale != nil {
                            (resultImage, isGif) = originImage.reSizeWithJudgment(scale: scale!, originData: originData)
                        } else {
                            resultImage = originImage
                        }
                        /// 缓存图片
                        if resultImage != nil {
                            if isGif {
                                ImageCache.default.store(resultImage!, original: resultImage?.kf.data(format: .GIF), forKey: key)
                            } else {
                                ImageCache.default.store(resultImage!, forKey: key)
                            }
                        }
                        if cacheOriginImage {
                            ImageCache.default.store(originImage, original: loadingResult.originalData, forKey: originKey)
                        }
                        guard !isGif, self?.needsTransition(options: totalOptions) == true else{
                            self?.noticeLoadImageSuccessed(resultImage!, completionHandler: completionHandler)
                            return
                        }
                        mainThread {
                            self?.makeTransition(image: resultImage!, options: totalOptions, done: {
                                self?.noticeLoadImageSuccessed(resultImage!, completionHandler: completionHandler)
                            })
                        }
                        self?.imageDownloadTask = nil
                    case .failure(let error): // KingfisherError
                        self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error, completionHandler: completionHandler)
                        self?.imageDownloadTask = nil
                    }
                }
            } else {
                /// 已缓存原图，从缓存中获取原图图片展示
                // 直接获取图片（获取后才知道是 memory 还是 disk）
                ImageCache.default.retrieveImage(forKey: originKey) {[weak self] (result) in
                    if self?.originImageCacheKey != originKey {
                        /// print("图片与目标key不一致")
                        return
                    }
                    switch result {
                    case .success(let loadingResult): // ImageLoadingResult
                        guard let imageData = loadingResult.image else {
                            self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: .cacheError(reason: .imageNotExisting(key: originKey)), completionHandler: completionHandler)
                            return
                        }
                        var resultImage: UIImage?
                        var isGif: Bool = false
                        /// 取大的倍数缩放
                        var scale: CGFloat?
                        if width != nil {
                            scale = CGFloat(width!) / imageData.size.width
                        }
                        if height != nil {
                            let heightScale = CGFloat(height!) / imageData.size.height
                            scale = scale == nil ? heightScale : max(scale!, heightScale)
                        }
                        if scale != nil {
                            let cacheImagePath = ImageCache.default.cachePath(forKey: originKey)
                            if let data = try? Data(contentsOf: URL(fileURLWithPath: cacheImagePath)) {
                                (resultImage, isGif) = imageData.reSizeWithJudgment(scale: scale!, originData: data)
                            }
                        } else {
                            resultImage = imageData
                        }
                        /// 缓存图片
                        if resultImage != nil {
                            if isGif {
                                ImageCache.default.store(resultImage!, original: resultImage?.kf.data(format: .GIF), forKey: key)
                            } else {
                                ImageCache.default.store(resultImage!, forKey: key)
                            }
                        }
                        mainThread {
                            self?.noticeLoadImageSuccessed(imageData, completionHandler: completionHandler)
                        }
                        return
                    case .failure(let error): // KingfisherError
                        self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error, completionHandler: completionHandler)
                        return
                    }
                }
            }
        } else {
            /// 已缓存小图，从缓存中获取图片展示
            // 直接获取图片（获取后才知道是 memory 还是 disk）
            ImageCache.default.retrieveImage(forKey: key) { [weak self] (result) in
                if key != self?.imageCacheKey {
                    /// print("图片与目标key不一致")
                    return
                }
                switch result {
                case .success(let loadingResult): // ImageLoadingResult
                    guard let imageData = loadingResult.image else {
                        self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: .cacheError(reason: .imageNotExisting(key: key)), completionHandler: completionHandler)
                        return
                    }
                    mainThread {
                        self?.noticeLoadImageSuccessed(imageData, completionHandler: completionHandler)
                    }
                    return
                case .failure(let error): // KingfisherError
                    self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error, completionHandler: completionHandler)
                    return
                }
            }
        }
    }
    
    /// 展示加载成功的图片
    /// - Parameters:
    ///   - faildImage: 加载失败图片
    ///   - error: 失败信息
    ///   - completionHandler: 回调函数
    private func noticeLoadImageSuccessed(_ image: UIImage, completionHandler: ImageLoadResult? = nil) {
        mainThread {
            self.image = image
            completionHandler?(.success(image))
        }
    }
    
    /// 展示加载失败并回调
    /// - Parameters:
    ///   - faildImage: 加载失败图片
    ///   - error: 失败信息
    ///   - completionHandler: 回调函数
    private func noticeLoadImageFaild(faildImage: UIImage?, error: KingfisherError, completionHandler: ImageLoadResult? = nil) {
        mainThread {
            self.image = faildImage
            completionHandler?(.failure(error))
        }
    }
    
    /// 判断是否需要渐变动画
    private func needsTransition(options: KingfisherOptionsInfo) -> Bool {
        for item in options {
            switch item {
            case .transition(let transition):
                switch transition {
                case .none:
                    return false
                #if !os(macOS)
                default:
                    return true
                #endif
                }
            default:
                continue
            }
        }
        return false
    }
    
    /// 展示动画
    private func makeTransition(image: KFCrossPlatformImage, options: KingfisherOptionsInfo, done: @escaping () -> Void) {
        #if !os(macOS)
        // 获取动画类型
        var transition: ImageTransition = .none
        for item in options {
            switch item {
            case .transition(let t):
                transition = t
                break
            default:
                continue
            }
        }
        // 先隐藏加载提示
        UIView.transition(
            with: self,
            duration: 0.0,
            options: [],
            animations: { self.kf.indicator?.stopAnimatingView() },
            completion: { _ in
                /// 参数转换
                var duration: TimeInterval = 0
                var options: AnimationOptions = []
                var animations: ((UIImageView, UIImage) -> Void)? = { $0.image = $1 }
                var completion: ((Bool) -> Void)?
                switch transition {
                case .none:
                    break
                case .fade(let d):
                    duration = d
                    options = .transitionCrossDissolve
                case .flipFromLeft(let d):
                    duration = d
                    options = .transitionFlipFromLeft
                case .flipFromRight(let d):
                    duration = d
                    options = .transitionFlipFromRight
                case .flipFromTop(let d):
                    duration = d
                    options = .transitionFlipFromTop
                case .flipFromBottom(let d):
                    duration = d
                    options = .transitionFlipFromBottom
                case .custom(duration: let d, options: let o, animations: let a, completion: let c):
                    duration = d
                    options = o
                    animations = a
                    completion = c
                }
                /// 展示动画
                UIView.transition(
                    with: self,
                    duration: duration,
                    options: [options, .allowUserInteraction],
                    animations: { animations?(self, image) },
                    completion: { finished in
                        completion?(finished)
                        done()
                    }
                )
            }
        )
        #else
        done()
        #endif
    }
}
