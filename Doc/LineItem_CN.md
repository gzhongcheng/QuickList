# LineItem

定义好的分割线Item，可自定义线的宽度、圆角、内容边距、线的颜色以及背景色
![](./LineItem.png) 

## 属性

> **lineColor**：线的颜色
> **lineRadius**：线的圆角
> **lineWidth**：线宽
> **contentInsets**：边距

## 使用举例

```
Section("LineItem(分割线)") { section in
    section.lineSpace = 0
    section.column = 1
    section.header?.shouldSuspension = true
}
    <<< LineItem() { item in
        item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        item.lineWidth = 30
        item.lineRadius = 15
    }
    <<< LineItem() { item in
        item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 0)
        item.lineWidth = 3
        item.lineRadius = 1.5
    }
    <<< LineItem() { item in
        item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        item.lineColor = .red
    }
    <<< LineItem() { item in
        item.contentInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
```

