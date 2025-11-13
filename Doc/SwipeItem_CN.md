# SwipeItem

支持左滑操作的Item，可以通过左滑手势显示操作按钮，实现类似iOS系统邮件应用的左滑删除等功能

## 属性 (基类中已有属性未列出)

### 左滑控制

> **canSwipe**：是否可以左滑，默认为 `true`

### 操作按钮

> **swipedActionButtons**：左滑时显示的按钮数组，类型为 `[SwipeActionButton]`
>
> 按钮按数组顺序从右到左排列，第一个按钮（数组第一个元素）会显示在最右侧

### 自动触发

> **autoTriggerFirstButton**：全部展示后继续左滑，是否自动触发第一个按钮的事件，默认为 `false`
>
> **autoTriggerFirstButtonThreshold**：自动触发第一个按钮事件的阈值（固定负数，单位为px），默认为 `-60`

### 内容视图

> **swipeContentView**：会跟随左滑的内容视图，需要将自定义内容添加到此视图中

## SwipeActionButton

左滑时显示的操作按钮，支持图标和文字的组合显示。

### 初始化方法

```swift
public init(
    icon: UIImage? = nil,                    // 图标
    iconTintColor: UIColor = .white,          // 图标颜色
    title: String? = nil,                     // 文字
    titleColor: UIColor = .white,              // 文字颜色
    font: UIFont = .systemFont(ofSize: 14),   // 字体
    backgroundColor: UIColor = .red,           // 背景色
    width: CGFloat = 80,                      // 按钮宽度
    autoCloseSwipe: Bool = true,              // 点击后是否自动收起
    touchUpInside: (() -> Void)? = nil        // 点击事件回调
)
```

### 属性

> **width**：按钮宽度
>
> **icon**：图标图片
>
> **iconTintColor**：图标颜色
>
> **title**：按钮文字
>
> **titleColor**：文字颜色
>
> **font**：文字字体
>
> **buttonBackgroundColor**：按钮背景色
>
> **iconTextSpace**：图标和文字的间距，默认为 5
>
> **autoCloseSwipe**：点击按钮后是否自动收起左滑操作，默认为 `true`
>
> **touchUpInsideAction**：点击事件回调

## 使用方法

### 1. 创建自定义Cell

需要继承 `SwipeItemCell`，并将需要跟随左滑的内容添加到 `swipeContentView` 中：

```swift
class TestSwipeItemCell: SwipeItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 将内容添加到 swipeContentView，这样在左滑时会跟随移动
        swipeContentView.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
    
    let testLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
}
```

### 2. 创建自定义Item

```swift
final class TestSwipeItem: SwipeAutolayoutItemOf<TestSwipeItemCell>, ItemType {
    
    /**
     * 更新cell的布局
     * Update cell layout
     */
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? TestSwipeItemCell else {
            return
        }
        updateCellData(cell)
    }
    
    /**
     * 自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸
     */
    override func updateCellData(_ cell: TestSwipeItemCell) {
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestSwipedItem"
    }
}
```

### 3. 使用示例

#### 基本使用

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("左滑删除") { item in
        // 创建删除按钮
        let deleteButton = SwipeActionButton(
            icon: UIImage(systemName: "trash"),
            iconTintColor: .white,
            title: "删除",
            titleColor: .white,
            backgroundColor: .red,
            width: 80,
            touchUpInside: {
                // 删除操作
                if let section = item.section {
                    section.remove(item: item)
                }
            }
        )
        item.swipedActionButtons = [deleteButton]
    }
```

#### 多个操作按钮

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("左滑多操作") { item in
        // 创建多个按钮，从右到左排列
        let deleteButton = SwipeActionButton(
            icon: UIImage(systemName: "trash"),
            iconTintColor: .white,
            title: "删除",
            backgroundColor: .red,
            width: 80,
            touchUpInside: {
                // 删除操作
                if let section = item.section {
                    section.remove(item: item)
                }
            }
        )
        
        let editButton = SwipeActionButton(
            icon: UIImage(systemName: "pencil"),
            iconTintColor: .white,
            title: "编辑",
            backgroundColor: .blue,
            width: 80,
            touchUpInside: {
                // 编辑操作
                print("编辑操作")
            }
        )
        
        let shareButton = SwipeActionButton(
            icon: UIImage(systemName: "square.and.arrow.up"),
            iconTintColor: .white,
            title: "分享",
            backgroundColor: .green,
            width: 80,
            touchUpInside: {
                // 分享操作
                print("分享操作")
            }
        )
        
        // 按钮按数组顺序从右到左排列：[删除, 编辑, 分享]
        item.swipedActionButtons = [deleteButton, editButton, shareButton]
    }
```

#### 自定义按钮样式

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("自定义样式") { item in
        let customButton = SwipeActionButton(
            icon: UIImage(named: "custom_icon"),
            iconTintColor: .yellow,
            title: "自定义",
            titleColor: .black,
            font: .boldSystemFont(ofSize: 16),
            backgroundColor: .orange,
            width: 100,
            autoCloseSwipe: false,  // 点击后不自动收起
            touchUpInside: {
                // 自定义操作
                print("自定义操作")
                // 手动收起
                item.cell?.closeSwipeActions()
            }
        )
        customButton.iconTextSpace = 8  // 自定义图标和文字间距
        
        item.swipedActionButtons = [customButton]
        item.autoTriggerFirstButton = true  // 启用自动触发
        item.autoTriggerFirstButtonThreshold = -80  // 设置触发阈值
    }
```

#### 仅图标按钮

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("仅图标") { item in
        let iconButton = SwipeActionButton(
            icon: UIImage(systemName: "heart.fill"),
            iconTintColor: .white,
            backgroundColor: .systemPink,
            width: 60,
            touchUpInside: {
                print("点赞")
            }
        )
        item.swipedActionButtons = [iconButton]
    }
```

#### 仅文字按钮

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("仅文字") { item in
        let textButton = SwipeActionButton(
            title: "更多",
            titleColor: .white,
            font: .systemFont(ofSize: 14),
            backgroundColor: .gray,
            width: 70,
            touchUpInside: {
                print("更多操作")
            }
        )
        item.swipedActionButtons = [textButton]
    }
```

#### 禁用左滑

```swift
Section("左滑操作列表")
    <<< TestSwipeItem("禁用左滑") { item in
        item.canSwipe = false  // 禁用左滑功能
    }
```

## 手势交互说明

1. **左滑展开**：向左滑动可以展开操作按钮
2. **右滑收起**：向右滑动或点击按钮后会自动收起
3. **快速滑动**：快速左滑（速度 > 500）会自动展开，快速右滑（速度 > 500）会自动收起
4. **自动触发**：当 `autoTriggerFirstButton` 为 `true` 时，全部展开后继续左滑超过阈值会自动触发第一个按钮的事件
5. **单例控制**：同一时间只能有一个Item处于左滑展开状态，展开新的Item会自动收起之前展开的Item

## 注意事项

1. **内容视图**：需要跟随左滑移动的内容必须添加到 `swipeContentView` 中，而不是直接添加到 `contentView`
2. **按钮顺序**：`swipedActionButtons` 数组中的按钮按顺序从右到左排列，第一个元素显示在最右侧
3. **按钮宽度**：第一个按钮（数组第一个元素）的宽度可以自适应（`greaterThanOrEqualTo`），其他按钮使用固定宽度
4. **自动收起**：默认情况下，点击按钮后会自动收起左滑操作，可以通过 `autoCloseSwipe` 属性控制
5. **滚动冲突**：左滑手势会自动处理与滚动视图的冲突，在左滑过程中会临时禁用滚动
6. **手势识别**：左滑手势只在水平滑动时触发，垂直滑动不会触发

