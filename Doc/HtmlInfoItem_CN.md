# HtmlInfoItem

带webview的item，用于展示html代码，会根据网页内容大小和用户设置自动调整最终展示大小

## 属性

> **value**：要显示的html代码内容
>
> **contentInsets**：四周边距
>
> **estimatedSize**：预设大小（如html代码为图片，且后台有给出图片大小，可使用此属性直接设置大小）

## 使用举例

### HtmlInfoItem

```swift
Section("HtmlInfoItem") { section in
    section.lineSpace = 0
    section.column = 1
}
<<< HtmlInfoItem() { item in
    item.value = "<img src = \"http://img.alicdn.com/imgextra/i3/124158638/O1CN01AlLzW02DgFnqvcWtB_!!124158638.jpg\"/>"
    item.estimatedSize = CGSize(width: 750, height: 730)
    item.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
}
```

