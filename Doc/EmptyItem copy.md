# EmptyItem

定义好的空白占位item

## 属性

> **itemSize**：固定尺寸
> **itemHeight**：固定高度（适用于纵向滚动的List）
> **itemWidth**：固定宽度（适用于横向滚动的List）
> **itemRatio**：固定比例

优先级: itemSize > itemHeight/itemWidth > itemRatio > 0

## 使用举例

```
Section("LineItem(分割线)") { section in
    section.lineSpace = 0
    section.column = 3
    section.header?.shouldSuspension = true
}
    <<< EmptyItem(size: CGSize(width: 10, height: 100))
    <<< EmptyItem(height: 20, weight: 2)
    <<< EmptyItem(ratio: 0.8)
```

