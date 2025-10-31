# SwitchItem

带switch控件的单元格，可展示标题和switch，同时提供自定义标题、switch样式和位置等属性

![](./SwitchItem.gif)

## 属性 

### 整体设置 (基类中已有属性未列出)

> **verticalAlignment**: 竖直方向排列方式

### 标题(title)样式

> **title**：标题内容文字
>
> **titlePosition**：位置(自动宽度/固定宽度)
>
> **titleFont**：字体
>
> **titleColor**：字体颜色
>
> **titleLines**: 行数
>
> **titleAlignment**：对齐方式
>
> **attributeTitle**：富文本标题，如果设置了，则会替换掉title显示这个

### 右侧滑块样式

>**value**：Switch控件的开关状态，默认为false
>
>**switchOffBackgroundColor**：off状态的开关背景色
>**switchOnBackgroundColor**：on状态的开关背景色
>
>**switchOffIndicatorColor**：off状态的滑块颜色
>**switchOnIndicatorColor**：on状态的滑块颜色
>
>**switchOffIndicatorText**：off状态时滑块上添加的文字显示（建议单字）
>**switchOnIndicatorText**：on状态时滑块上添加的文字显示（建议单字）
>
>**switchOffText**：off状态时，展示在背景中的文字
>**switchOnText**：on状态时，展示在背景中的文字
>
>**minimumSwitchSize**：开关的最小尺寸（如果内容文本尺寸超过会撑大）
>**switchContentInsets**：开关内间距


## 使用举例

***不建议***将SwitchItem添加到横向滚动的CollectionView中

```
Section("SwitchItem") { section in
    section.lineSpace = 0
    section.column = 1
}
    <<< SwitchItem("设为默认") { item in
        item.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 5, right: 15)
        item.value = true
    }.onValueChanged({ (item) in
        /// 值改变的回调
        guard let labelItem = item.form?.firstItem(for: "DEFAULT_LABEL") as? LabelItem else {
            return
        }
        if item.value {
            labelItem.titlePosition = .width(200)
            labelItem.value = "已设为默认"
        } else {
            labelItem.titlePosition = .left
            labelItem.title = "value清空了，可以改成自动宽度，整行都能显示title的值"
            labelItem.value = ""
        }
        labelItem.updateCell()
    })
    <<< SwitchItem("自定义样式1") { item in
        item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        item.switchOffBackgroundColor = .red
        item.switchOnBackgroundColor = .blue
        item.switchOffIndicatorColor = .yellow
        item.switchOnIndicatorColor = .orange
        item.switchOffText = "关"
        item.switchOnText = "开"
        item.switchOffIndicatorTextColor = .darkGray
        item.switchOnIndicatorTextColor = .white
    }
    <<< SwitchItem("自定义样式2") { item in
        item.contentInsets = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
        item.switchOffBackgroundColor = .red
        item.switchOnBackgroundColor = .blue
        item.switchOffIndicatorColor = .yellow
        item.switchOnIndicatorColor = .orange
        item.switchOffIndicatorText = "关"
        item.switchOnIndicatorText = "开"
        item.switchOffIndicatorTextColor = .darkGray
        item.switchOnIndicatorTextColor = .white
    }
```



