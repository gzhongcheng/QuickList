## Form的使用

Form作为Section的集合容器，实现了Collection相关集合协议，支持通过下标获取Section元素，支持通过append、insert、replace和remove方式对Section进行操作。

####  通用属性

> **header**：列表的Header
> **footer**：列表的Footer
> **singleSelection**：是否单选
> **selectedItemDecorationPosition**：选中item装饰view与item的图层关系，默认为below
> **selectedItemDecoration**：列表通用的选中item的装饰view，通常展示在选中item图层之下，尺寸为item大小，设置后，列表将强制变成单选状态
> **selectedItemDecorationMoveDuration**：选中item装饰view的移动动画时长，默认为0.25s
>
> **backgroundDecoration**：列表整体的背景装饰view，展示在列表最底层，尺寸为列表大小，且内部会将它的交互禁用

#### 布局相关

> **needCenterIfNotFull**：内容未填满列表时是否需要在控件范围内居中展示
> **contentInset**：内容边距
> **layout**：列表整体的自定义布局方式，未设置时默认使用`QuickListFlowLayout`布局

#### 常用方法
> **section(for tag:)**: 获取tag对应的Section
> **firstItem(for tag:)**: 获取tag对应的第一个item

#### 动画操作方法
> **replaceSections(with:, inAnimation:, outAnimation:, completion:)**: 替换所有Section，支持不同的进入和退出动画
> **replaceSections(with:, at:, inAnimation:, outAnimation:, completion:)**: 在指定范围替换Section数组
> **deleteSections(with:, inAnimation:, outAnimation:, completion:)**: 删除指定的Section数组，支持动画效果

#### 基础操作方法
> **append(_:)**: 添加单个Section到末尾
> **append(contentsOf:)**: 添加Section数组到末尾
> **insert(_:, at:)**: 在指定位置插入Section
> **replaceSubrange(_:, with:)**: 替换指定范围的Section
> **remove(at:)**: 删除指定位置的Section
> **remove(at:, updateUI:)**: 删除指定位置的Section，可选择是否更新UI
> **removeFirst()**: 删除第一个Section
> **removeFirst(updateUI:)**: 删除第一个Section，可选择是否更新UI
> **removeAll(keepingCapacity:)**: 删除所有Section
> **removeAll(keepingCapacity:, updateUI:)**: 删除所有Section，可选择是否更新UI
> **removeAll(where:)**: 根据条件删除Section
> **removeAll(updateUI:, where:)**: 根据条件删除Section，可选择是否更新UI

## 使用举例
```
let form = Form()

// 动画替换所有Section
let newSections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "项目1", value: "值1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "项目2", value: "值2")
    }
]
form.replaceSections(with: newSections, inAnimation: .fade, outAnimation: .scale) {
    print("Section替换完成")
}

// 动画删除Section
form.deleteSections(with: [newSections[0]], inAnimation: .leftSlide, outAnimation: .rightSlide) {
    print("Section删除完成")
}

// 基础操作
let section = Section(header: "新Section")
form.append(section)  // 添加Section
form.insert(section, at: 0)  // 在指定位置插入
form.remove(at: 0)  // 删除指定位置的Section
```
