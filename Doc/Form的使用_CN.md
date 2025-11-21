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

所有动画操作方法都支持 `ListReloadAnimation` 类型的动画参数，可用的动画类型包括：
- `.none`：无动画
- `.fade`：淡入淡出动画
- `.scaleX`：X轴缩放动画
- `.scaleY`：Y轴缩放动画
- `.scaleXY`：X轴和Y轴同时缩放动画
- `.threeDFold`：3D折叠动画
- `.leftSlide`：从左滑入/滑出动画
- `.rightSlide`：从右滑入/滑出动画
- `.topSlide`：从上滑入/滑出动画
- `.bottomSlide`：从下滑入/滑出动画
- `.transform`：从旧位置移动到新位置的动画

> **addSections(with:animation:completion:)**: 添加Section数组到末尾，支持动画效果
> - `sections`: Section数组
> - `animation`: 进入动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **addSection(with:animation:completion:)**: 添加单个Section到末尾，支持动画效果
> - `section`: 要添加的Section
> - `animation`: 进入动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **insetSection(with:at:animation:completion:)**: 在指定位置插入Section，支持动画效果
> - `section`: 要插入的Section
> - `at`: 插入位置索引
> - `animation`: 进入动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **replaceSections(with:inAnimation:outAnimation:completion:)**: 替换所有Section，支持不同的进入和退出动画
> - `sections`: 新的Section数组
> - `inAnimation`: 新Section的进入动画，默认为nil（无动画）
> - `outAnimation`: 旧Section的退出动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **replaceSections(with:at:inAnimation:outAnimation:completion:)**: 在指定范围替换Section数组，支持不同的进入和退出动画
> - `sections`: 新的Section数组
> - `at`: 替换的范围（Range<Int>）
> - `inAnimation`: 新Section的进入动画，默认为nil（无动画）
> - `outAnimation`: 旧Section的退出动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **deleteSections(with:inAnimation:outAnimation:completion:)**: 删除指定的Section数组，支持不同的进入和退出动画
> - `sections`: 要删除的Section数组
> - `inAnimation`: 其他Section的进入动画（用于重新布局），默认为nil（无动画）
> - `outAnimation`: 被删除Section的退出动画，默认为nil（无动画）
> - `completion`: 完成回调，默认为nil

> **updateLayout(afterSection:animation:)**: 仅刷新指定Section之后的布局，不改变数据，支持动画效果
> - `afterSection`: 从哪个Section索引之后开始刷新布局（包含该索引）
> - `animation`: 动画效果，默认为nil（无动画）

#### 基础操作方法
> **append(_:)**: 添加单个Section到末尾
> **append(contentsOf:)**: 添加Section数组到末尾
> **insert(_:, at:)**: 在指定位置插入Section
> **replaceSubrange(_:, with:)**: 替换指定范围的Section
> **remove(at:)**: 删除指定位置的Section
> **removeFirst()**: 删除第一个Section
> **removeAll(keepingCapacity:)**: 删除所有Section
> **removeAll(where:)**: 根据条件删除Section

## 使用举例

### 基础操作
```swift
let form = Form()

// 基础操作（无动画）
let section = Section(header: "新Section")
form.append(section)  // 添加Section到末尾
form.insert(section, at: 0)  // 在指定位置插入
form.remove(at: 0)  // 删除指定位置的Section
```

### 动画添加Section

```swift
// 添加单个Section，使用淡入动画
let newSection = Section(header: "新Section") { section in
    section <<< TitleValueItem(title: "项目1", value: "值1")
}
form.addSection(with: newSection, animation: .fade) {
    print("Section添加完成")
}

// 添加多个Section，使用缩放动画
let sections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "项目1", value: "值1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "项目2", value: "值2")
    }
]
form.addSections(with: sections, animation: .scaleXY) {
    print("Sections添加完成")
}

// 在指定位置插入Section，使用左滑动画
let insertSection = Section(header: "插入的Section")
form.insetSection(with: insertSection, at: 1, animation: .leftSlide) {
    print("Section插入完成")
}
```

### 动画替换Section

```swift
// 替换所有Section，使用不同的进入和退出动画
let newSections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "项目1", value: "值1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "项目2", value: "值2")
    }
]
form.replaceSections(
    with: newSections,
    inAnimation: .fade,      // 新Section淡入
    outAnimation: .scaleXY    // 旧Section缩放退出
) {
    print("Section替换完成")
}

// 在指定范围替换Section
form.replaceSections(
    with: newSections,
    at: 0..<2,                // 替换索引0到1的Section
    inAnimation: .rightSlide, // 新Section从右滑入
    outAnimation: .leftSlide  // 旧Section从左滑出
) {
    print("Section范围替换完成")
}

// 使用3D折叠动画替换
form.replaceSections(
    with: newSections,
    inAnimation: .threeDFold,
    outAnimation: .threeDFold
) {
    print("3D折叠动画替换完成")
}
```

### 动画删除Section

```swift
// 删除指定的Section，使用滑动动画
let sectionToDelete = form[0]
form.deleteSections(
    with: [sectionToDelete],
    inAnimation: .fade,      // 其他Section重新布局时的动画
    outAnimation: .rightSlide // 被删除Section的退出动画
) {
    print("Section删除完成")
}

// 删除多个Section，使用缩放退出动画
let sectionsToDelete = [form[0], form[1]]
form.deleteSections(
    with: sectionsToDelete,
    inAnimation: .scaleXY,
    outAnimation: .scaleXY
) {
    print("多个Section删除完成")
}
```

### 仅刷新布局（不改变数据）

```swift
// 刷新指定Section之后的布局，使用淡入动画
form.updateLayout(afterSection: 1, animation: .fade)

// 刷新所有Section的布局，使用缩放动画
form.updateLayout(afterSection: 0, animation: .scaleXY)
```

### 自定义动画时长

```swift
// 创建自定义时长的动画
let customAnimation = ListReloadAnimation.fade
customAnimation.duration = 0.5  // 设置动画时长为0.5秒

form.addSection(with: newSection, animation: customAnimation) {
    print("自定义时长动画完成")
}
```

### 组合动画

```swift
// 组合淡入和缩放动画
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)

form.replaceSections(
    with: newSections,
    inAnimation: combinedAnimation,
    outAnimation: .fade
) {
    print("组合动画完成")
}
```

### 无动画操作

```swift
// 如果列表还未添加到视图层级，动画方法会自动使用无动画方式
// 或者显式传入 .none
form.addSection(with: newSection, animation: .none) {
    print("无动画添加完成")
}
```

### 注意事项

1. **视图层级要求**：动画操作方法只有在 Form 关联的列表视图已添加到视图层级时才会执行动画，否则会自动使用无动画方式
2. **动画性能**：复杂的动画（如3D折叠）会消耗更多资源，建议在数据量较大时使用简单动画
3. **动画时长**：所有动画默认时长为0.3秒，可以通过设置 `animation.duration` 自定义
4. **完成回调**：所有动画操作方法都支持完成回调，在动画执行完成后调用
5. **退出动画**：退出动画会对被删除/替换的Section的所有Item执行，确保Item的cell已创建才能看到退出动画效果
