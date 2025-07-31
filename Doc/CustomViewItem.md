# CustomViewItem

用于将已有的View快速包装成Item的容器

## 属性

> **identifier**：初始化时传入的自定义identifier，避免被复用
> **customViewLayoutBuilder**：自定义view的布局逻辑，需要在此添加约束，以撑开Item

## 使用举例

```
Section()
    <<< CustomViewItem(identifier: "leftTipItem", viewCreator: {
        return self.leftTipItem
    }, { item in
        item.customViewLayoutBuilder = { view in
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.greaterThanOrEqualTo(350)
            }
        }
    })
    <<< CustomViewItem(identifier: "rightTipItem", viewCreator: {
        return self.rightTipItem
    }, { item in
        item.customViewLayoutBuilder = { view in
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.greaterThanOrEqualTo(350)
            }
        }
    })
```

