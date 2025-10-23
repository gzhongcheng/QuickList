# ImageItem

纯图片展示Item，可设置图片预估比例、内容边距、圆角等，支持网络图片加载，可设置是否自动调整高度。采用了图片压缩缓存的策略，以解决大图片的卡顿问题，提升滑动的流畅度。

![](./ImageRow.gif)

## 属性

> **aspectRatio**：图片预估比例
> **autoSize**：是否自动调整尺寸，设置为true后，将在图片加载完成后，按实际图片的尺寸比例更新尺寸
>
> **imageUrl**：网络图片地址字符串
>
> **image**：本地图片UIImage
>
> **loadingIndicatorType**：图片加载中的样式，`IndicatorType`类型，具体为：
> ```
> .none 默认没有菊花
> .activity 使用系统菊花
> .image(imageData: Data) 使用一张图片作为菊花，支持gif图
> .custom(indicator: Indicator) 使用自定义菊花，要遵循Indicator协议
> ```
>
> **placeholderImage**：加载中的占位图片
>
> **loadFaildImage**：加载失败图片
>
> **contentMode**：图片填充模式
>
> **corners**：图片圆角的数组，`[CornerType]`类型，如果要四个角全部圆角，可使用`CornerType.all(10)`

## 使用举例
```
Section("自动大小三列图片") { section in
    section.column = 3
    section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    section.lineSpace = 5
    section.itemSpace = 5
}
    <<< ImageItem() { row in
        row.imageUrl = "xxx"                                //url
        row.corners = [.leftTop(10),.rightBottom(15)] 		// 左上、右下圆角
        row.autoSize = true									// 自动调整大小
        row.aspectRatio = CGSize(width: 1, height: 1) 		// 预设比例
        row.loadFaildImage = UIImage(named: "load_faild")   // 加载失败图片
    }
```

