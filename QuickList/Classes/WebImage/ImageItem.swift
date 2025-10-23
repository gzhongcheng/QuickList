//
//  ImageItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import UIKit
import SnapKit
import Kingfisher

public extension ScrollObserverCellType where Self: UICollectionViewCell {
    /**
     * 所在的Scrollview是否正在滚动
     * Whether the Scrollview is scrolling
     */
    func isScrolling() -> Bool {
        var superView = superview
        while superView != nil {
            if let collectionView = superView as? UICollectionView {
                if let handler = collectionView.delegate as? FormDelegate {
                    return handler.isScrolling
                }
                return false
            }
            superView = superView?.superview
        }
        return false
    }
}

// MARK: - ImageCell
open class CollectionImageCell: ItemCell, ScrollObserverCellType {
    
    public let imageBoxView: AnimatedImageView = AnimatedImageView()
    
    open override func setup() {
        super.setup()
        
        imageBoxView.clipsToBounds = true
        contentView.addSubview(imageBoxView)
        
        imageBoxView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    /**
     * 滚动时停止播放gif
     * Stop playing gif when scrolling
     */
    public func willBeginScrolling() {
        imageBoxView.stopAnimating()
    }
    
    public func didEndScrolling() {
        imageBoxView.startAnimating()
    }
}

// MARK: - ImageItem
/**
 * 图片展示Item，可设置图片预估比例、内容边距、圆角等，支持网络图片加载
 * Image display item, can set image estimated ratio, content margins, corners, etc., supports network image loading
 */
public final class ImageItem: ItemOf<CollectionImageCell>, ItemType {
    
    /**
     * 是否自动调整宽度/高度
     * Whether to automatically adjust width/height
     */
    public var autoSize: Bool = true
    /**
     * 固定宽高比
     * Fixed aspect ratio
     */
    public var aspectRatio: CGSize?
    
    /**
     * 图片url字符串
     * Image url string
     */
    public var imageUrl: String?
    
    /**
     * uiimage对象
     * uiimage object
     */
    public var image: UIImage?
    
    /** 
     * 加载中的样式
     * Loading style
     *  .none 默认没有菊花 / Default no indicator
     *  .activity 使用系统菊花 / Use system indicator
     *  .image(imageData: Data) 使用一张图片作为菊花，支持gif图 / Use an image as indicator, supports gif
     *  .custom(indicator: Indicator) 使用自定义菊花，要遵循Indicator协议 / Use custom indicator, must conform to Indicator protocol
     */
    public var loadingIndicatorType: IndicatorType = .activity
    
    /**
     * 加载中占位图片
     * Loading placeholder image
     */
    public var placeholderImage: UIImage?
    
    /**
     * 加载失败图片
     * Loading failed image
     */
    public var loadFaildImage: UIImage?
    
    /**
     * 图片填充模式
     * Image fill mode
     */
    public var contentMode: UIView.ContentMode = .scaleAspectFill
    
    /**
     * 圆角
     * Corners
     */
    public var corners: [CornerType] = []
 
    /**
     * 更新cell的布局
     * Update cell layout
     */
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? CollectionImageCell else {
            return
        }
        
        cell.imageBoxView.contentMode = contentMode
        cell.imageBoxView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInsets)
        }
        loadImage()
    }
    
    public override func willDisplay() {
        super.willDisplay()
    }
    
    public override func didEndDisplay() {
        super.didEndDisplay()
        guard let cell = cell as? CollectionImageCell else {
            return
        }
        cell.imageBoxView.stopAnimating()
    }
    
    public override var identifier: String {
        return "ImageItem"
    }
    
    /**
     * 设置内容边距默认为0
     * Set content insets to 0 by default
     */
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        contentInsets = .zero
    }
    
    public convenience init(url: String, _ initializer: (ImageItem) -> Void = { _ in }) {
        self.init(nil, tag: nil)
        imageUrl = url
        initializer(self)
    }
    
    /**
     * 加载图片
     * Load image
     */
    func loadImage() {
        guard let cell = cell as? CollectionImageCell else {
            return
        }
        if let url = imageUrl {
            let estimateItemSize = self.section?.estimateItemSize(with: self.weight) ?? cell.bounds.size
            var maxWidth: CGFloat?
            var maxHeigh: CGFloat?
            if contentMode == .scaleAspectFit {
                if scrollDirection == .vertical {
                    maxWidth = estimateItemSize.width - contentInsets.left - contentInsets.right
                } else {
                    maxHeigh = estimateItemSize.height - contentInsets.top - contentInsets.bottom
                }
            } else {
                maxWidth = estimateItemSize.width - contentInsets.left - contentInsets.right
                maxHeigh = estimateItemSize.height - contentInsets.top - contentInsets.bottom
                let maxValue: CGFloat = max(maxWidth!, maxHeigh!)
                maxWidth = maxValue
                maxHeigh = maxValue
            }
            cell.imageBoxView.loadWebImage(url, placeholderImage: placeholderImage, indicatorType: self.loadingIndicatorType, loadFaildImage: loadFaildImage, maxWidth: maxWidth, maxHeight: maxHeigh, completionHandler:  { [weak self] (result) in
                switch result {
                    case .success(let imageOption):
                        guard let image = imageOption
                        else {
                            guard let errorImage = self?.loadFaildImage else {
                                return
                            }
                            self?.setImage(errorImage, to: cell)
                            return
                        }
                        self?.setImage(image, to: cell)
                    case .failure(_):
                        self?.setImage(nil, to: cell)
                }
            })
        } else if let image = image {
            self.setImage(image, to: cell)
        }
    }
    
    func setImage(_ image: UIImage?, to cell: CollectionImageCell) {
        if cell.isScrolling() {
            /**
             * 正在滚动时不播放gif动画
             * Do not play gif animation when scrolling
             */
            cell.imageBoxView.stopAnimating()
        }
        let estimateItemSize = self.section?.estimateItemSize(with: self.weight) ?? cell.bounds.size
        if autoSize, let image = image {
            if self.scrollDirection == .vertical {
                let imageWidth: CGFloat = estimateItemSize.width - contentInsets.left - contentInsets.right
                let imageHeight = imageWidth * image.size.height / image.size.width
                let cellHeight: Int = Int(imageHeight + contentInsets.top + contentInsets.bottom)
                /**
                 * 相差2以上才更新尺寸
                 * Update size if the difference is greater than 2
                 */
                if let ratio = aspectRatio, abs(cellHeight - Int(ratio.height)) > 2 || abs(Int(estimateItemSize.width) - Int(ratio.width)) > 2 {
                    aspectRatio = CGSize(width: Int(estimateItemSize.width), height: cellHeight)
                    updateLayout(animation: true)
                } else if aspectRatio == nil {
                    aspectRatio = CGSize(width: Int(estimateItemSize.width), height: cellHeight)
                    updateLayout(animation: true)
                }
                cell.imageBoxView.setCorners(corners, rect: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            } else {
                let imageHeight: CGFloat = estimateItemSize.height - contentInsets.top - contentInsets.bottom
                let imageWidth = imageHeight * image.size.width / image.size.height
                let cellWidth: Int = Int(imageWidth + contentInsets.left + contentInsets.right)
                /**
                 * 相差2以上才更新尺寸
                 * Update size if the difference is greater than 2
                 */
                if let ratio = aspectRatio, abs(Int(estimateItemSize.height) - Int(ratio.height)) > 2 || abs(cellWidth - Int(ratio.width)) > 2 {
                    aspectRatio = CGSize(width: cellWidth, height: Int(estimateItemSize.height))
                    updateLayout(animation: true)
                } else if aspectRatio == nil {
                    aspectRatio = CGSize(width: cellWidth, height: Int(estimateItemSize.height))
                    updateLayout(animation: true)
                }
                cell.imageBoxView.setCorners(corners, rect: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
        } else {
            cell.imageBoxView.setCorners(corners, rect: CGRect(x: 0, y: 0, width: estimateItemSize.width, height: estimateItemSize.height))
        }
    }
    
    public override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return CGSize(width: estimateItemSize.width, height: cellHeight(for: estimateItemSize.width))
        case .horizontal:
            return CGSize(width: cellWidth(for: estimateItemSize.height), height: estimateItemSize.height)
        default:
            return nil
        }
    }
}

// MARK: - Size calculation
extension ImageItem {
    private func cellHeight(for width: CGFloat) -> CGFloat {
        if let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        // Default is 1:1
        return width
    }
    
    private func cellWidth(for height: CGFloat) -> CGFloat {
        if let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        // Default is 1:1
        return height
    }
    
    /**
     * 根据设定好的宽高比计算宽/高值
     * Calculate width/height based on the set aspect ratio
     */
    public func aspectWidth(_ height: CGFloat) -> CGFloat? {
        if aspectRatio != nil {
            let width = height * aspectRatio!.width / aspectRatio!.height
            return width
        }
        return height
    }
    public func aspectHeight(_ width: CGFloat) -> CGFloat? {
        if aspectRatio != nil {
            let height = width * aspectRatio!.height / aspectRatio!.width
            return height
        }
        return width
    }
}
