//
//  HtmlInfoItem.swift
//  QuickList
//
//  Created by Guo ZhongCheng on 2025/4/4.
//

import WebKit
import SnapKit

/**
 * 带webview的cell，用于展示html代码
 * Cell with webview for displaying html code
 */
open class CollectionHtmlInfoCell : ItemCell {
    /**
     * 当前展示内容
     * Current content
     */
    fileprivate var currentContent: String? {
        didSet {
            guard let currentContent = currentContent else {
                return
            }
            self.htmlView.loadHTMLString(currentContent, baseURL: nil)
        }
    }
    
    
    /**
     * 设置展示区域,html的内容不用一次性全部展示,减少卡顿
     * Set display area, html content is not displayed at once to reduce lag
     */
    open var showRect: CGRect = .zero {
        didSet {
            if showRect.minY + showRect.height <= contentView.frame.height {
                htmlView.frame = CGRect(
                    x: contentInsets.left,
                    y: max(contentInsets.top, showRect.minY),
                    width: contentView.bounds.width - contentInsets.left - contentInsets.right,
                    height: min(contentView.frame.height,showRect.height)
                )
                htmlView.scrollView.contentOffset = CGPoint(x: 0, y: max(0, showRect.minY - contentInsets.top))
            }
        }
    }
    
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            htmlView.frame = CGRect(
                x: contentInsets.left,
                y: contentInsets.top,
                width: contentView.bounds.width - contentInsets.left - contentInsets.right,
                height: contentView.bounds.height - contentInsets.top - contentInsets.bottom
            )
        }
    }
    
    public lazy var htmlView: WKWebView = {
        let config = WKWebViewConfiguration()
        let preference = WKPreferences()
        preference.minimumFontSize = 40
        config.preferences = preference
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.isUserInteractionEnabled = false
        webview.allowsLinkPreview = true
        webview.scrollView.isScrollEnabled = false
        webview.scrollView.bounces = false
        webview.isOpaque = false
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            webview.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webview
    }()

    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(htmlView)
        
        htmlView.frame = contentView.bounds
    }

    
}

/**
 * 带webview的item，用于展示html代码，会根据网页内容大小和用户设置自动调整最终展示大小
 * Item with webview for displaying html code, will automatically adjust the final display size according to the size of the web page and user settings
 */
public final class HtmlInfoItem: ItemOf<CollectionHtmlInfoCell>, ItemType{
    
    public override var identifier: String {
        return "HtmlInfoItem"
    }
    
    /**
     * 预估大小
     * Estimated size
     */
    public var estimatedSize: CGSize?
    /**
     * 实际网页高度
     * Actual web page height
     */
    private var actualHeight: CGFloat?
    /**
     * 实际内容比例 (宽/高)
     * Actual content ratio (width/height)
     */
    private var actualRatio: CGFloat?
    
    /**
     * 传入的内容
     * Input content
     */
    public var content: String? {
        didSet {
            guard let content = content else {
                currentContent = nil
                return
            }
            currentContent = formatHtml(content)
        }
    }
    /**
     * 当前展示内容
     * Current content
     */
    private var currentContent: String?
    
    public convenience init(content: String) {
        self.init()
        self.content = content
    }
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: nil, tag: nil)
    }
    
    /**
     * 格式化html字符串
     * Format html string
     */
    func formatHtml(_ body: String) -> String {
        return  """
        <html>
            <head>
            <meta charset="UTF-8">
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <style type="text/css">
                html{
                    margin:0;
                    padding:0;
                    -webkit-text-size-adjust:none;
                }
                body{
                    margin: 0;
                    padding: 0;
                }
                img{
                    width: 100%;
                    height: auto;
                    display: block;
                    margin-left: auto;
                    margin-right: auto;
                }
            </style>
            </head>
            <body>
                \(body)
            </body>
        </html>
        """
    }
    
    public override func didEndDisplay() {
        super.didEndDisplay()
        guard
            let cell = cell as? CollectionHtmlInfoCell
        else {
            return
        }
        cell.htmlView.stopLoading()
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard
            let cell = cell as? CollectionHtmlInfoCell
        else {
            return
        }
        
        updateCellData(cell)
    }
    
    public func updateCellData(_ cell: CollectionHtmlInfoCell) {
        cell.htmlView.navigationDelegate = self
        
        cell.backgroundColor = backgroundColor
        cell.htmlView.backgroundColor = backgroundColor
        cell.contentInsets = contentInsets
        cell.htmlView.frame = CGRect(
            x: cell.htmlView.frame.minX,
            y: cell.htmlView.frame.minY,
            width: cell.htmlView.frame.width,
            height: actualHeight ?? 0
        )
        
        DispatchQueue.main.async {
            cell.currentContent = self.currentContent
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
    
    private func cellWidth(for height: CGFloat) -> CGFloat {
        if let ratio = actualRatio {
            actualHeight = height - contentInsets.top - contentInsets.bottom
            let width = min(UIScreen.main.bounds.width, height * ratio)
            if let cell = cell as? CollectionHtmlInfoCell {
                cell.htmlView.frame = CGRect(
                    x: cell.htmlView.frame.minX,
                    y: cell.htmlView.frame.minY,
                    width: cell.htmlView.frame.width,
                    height: actualHeight!
                )
            }
            return width
        }
        if estimatedSize != nil {
            let width = height * estimatedSize!.width / estimatedSize!.height
            return width
        }
        return height
    }
    
    private func cellHeight(for width: CGFloat) -> CGFloat {
        if let ratio = actualRatio {
            let actualWidth = width - contentInsets.left - contentInsets.right
            actualHeight = actualWidth / ratio
            if let cell = cell as? CollectionHtmlInfoCell {
                cell.htmlView.frame = CGRect(
                    x: cell.htmlView.frame.minX,
                    y: cell.htmlView.frame.minY,
                    width: cell.htmlView.frame.width,
                    height: actualHeight!
                )
            }
            return actualHeight! + contentInsets.top + contentInsets.bottom
        }
        if estimatedSize != nil {
            let height = (width - contentInsets.left - contentInsets.right) * estimatedSize!.height / estimatedSize!.width + contentInsets.top + contentInsets.bottom
            return height
        }
        return width
    }
}

extension HtmlInfoItem: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard
            let cell = cell as? CollectionHtmlInfoCell,
            cell.currentContent == self.currentContent
        else {
            return
        }
        if actualRatio != nil {
            return
        }
        /**
         * 修改高度
         * Modify height
         */
        webView.evaluateJavaScript("document.body.scrollWidth/document.body.scrollHeight") {[weak self] (value, error) in
            guard let ratio = value as? CGFloat else {
                return
            }
            DispatchQueue.main.async {
                self?.actualRatio = ratio
                self?.updateLayout()
            }
        }
    }
}
