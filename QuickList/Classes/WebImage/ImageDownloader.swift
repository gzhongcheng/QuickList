//
//  ImageDownloader.swift
//  GZCExtends
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import Kingfisher

/**
 * 图片下载进度回调
 * Image download progress callback
 */
public typealias ImageDownloadProgressCallBack = (String, Int64, Int64) -> Void
/**
 * 图片下载完成回调
 * Image download completion callback
 */
public typealias ImageDownloadFinishCallBack = (String, Result<ImageLoadingResult, KingfisherError>) -> Void

/**
 * 下载完成结果回调
 * Download completion result callback
 */
public typealias ImageLoadResult = (Result<KFCrossPlatformImage?, KingfisherError>) -> Void

/**
 * 图片下载管理
 * Image download manager
 */
public class ImageDownloadManager {
    
    /**
     * 单例
     * Singleton
     */
    public static let shared: ImageDownloadManager = ImageDownloadManager()
    
    /**
     * 下载的最大线程数量
     * Maximum number of threads for downloading
     */
    public var maxOperationCount: Int {
        set {
            queue.maxConcurrentOperationCount = newValue
        }
        get {
            return queue.maxConcurrentOperationCount
        }
    }
    
    var queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 5
        q.name = "ImageDownloadQueue"
        return q
    }()
    
    /**
     * 添加下载任务
     * Add download task
     */
    public func addTask(
        url: URL,
        options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh], //.backgroundDecode,
        progressBlock: ImageDownloadProgressCallBack? = nil,
        completionHandler: ImageDownloadFinishCallBack? = nil
    ) -> ImageDownloadTask {
        let task = ImageDownloadTask(
            url: url,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
        queue.addOperation(task)
        return task
        
    }
}

/**
 * 下载的任务
 * Download task
 */
public class ImageDownloadTask: Operation {
    public var url: URL
    public var options: KingfisherOptionsInfo
    public var progressBlock: ImageDownloadProgressCallBack?
    public var completionHandler: ImageDownloadFinishCallBack?
    
    public init(
        url: URL,
        options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh], //.backgroundDecode,
        progressBlock: ImageDownloadProgressCallBack? = nil,
        completionHandler: ImageDownloadFinishCallBack? = nil
    ) {
        self.url = url
        self.options = options
        self.progressBlock = progressBlock
        self.completionHandler = completionHandler
    }
    
    /**
     * 状态
     * State
     */
    enum State: String {
        case ready, executing, finished
        fileprivate var keyPath: String {
            return "is\(rawValue.capitalized)"
        }
    }
    
    /**
     * 当前状态
     * Current state
     */
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        } didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    public override var isReady: Bool {
        /**
         * 一定要先检测isReady 因为它是受系统任务计划程序控制的
         * It must be checked first because it is controlled by the system task scheduler
         */
        return super.isReady && state == .ready 
    }
    public override var isExecuting: Bool {
        return state == .executing
    }
    public override var isFinished: Bool {
        return state == .finished
    }
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override func start() {
        /**
         * 官方文档说明在重写start()的时候不可以调用super
         * The official documentation states that super cannot be called when overriding start()
         */
        if isCancelled {
            state = .finished
            return
        }
        main()
    }
    
    public override func main() {
        /**
         * 标记异步任务开始
         * Mark the asynchronous task as started
         */
        state = .executing
        ImageDownloader.default.downloadImage(with: url, options: options) {[weak self] (p, t) in
            if let callback = self?.progressBlock,
               let key = self?.url.absoluteString {
                callback(key, p, t)
            }
        } completionHandler: {[weak self] (result) in
            if let callback = self?.completionHandler,
               let key = self?.url.absoluteString {
                callback(key, result)
            }
            /**
             * 标记异步任务完成
             * Mark the asynchronous task as finished
             */
            self?.state = .finished
        }
    }
 }
