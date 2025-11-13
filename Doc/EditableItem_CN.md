# EditableItem

支持编辑功能的Item，可以通过编辑模式显示操作按钮（删除或移动），实现列表项的删除和移动功能

## 属性 (基类中已有属性未列出)

### 编辑类型

> **editType**：编辑类型，枚举类型 `EditableItemEditType`
>
> - `.delete`：删除模式，点击编辑按钮触发删除操作
> - `.move(_ moveAnimation: EditableItemMoveAnimation)`：移动模式，支持拖拽移动Item位置
>   - `.exchange`：直接交换模式，拖拽时直接与目标位置交换
>   - `.indicator(arrowColor:arrowSize:lineColor:lineWidth:)`：指示器模式，显示目标位置指示条，拖拽到目标位置后交换

### 编辑状态

> **isEditing**：编辑状态，控制是否显示编辑操作按钮
>
> **isDragging**：是否正在拖拽（移动模式下使用）

### 编辑图标

> **editIcon**：编辑按钮的图标图片
>
> **editIconColor**：编辑图标颜色，默认为黑色
>
> **editIconSize**：编辑图标大小，默认为 20x20

### 编辑容器

> **editContainerWidth**：编辑容器展开时的宽度，默认为 40

### 内容压缩方式

> **editContentCompression**：编辑时内容的压缩方式，枚举类型 `EditableItemEditContentCompression`
>
> - `.noCompression`：不压缩容器，整体左移（默认）
> - `.compression`：压缩容器，内容区域缩小

### 代理

> **delegate**：编辑操作代理，需要实现 `EditableItemDelegate` 协议来处理删除和移动操作

## EditableItemDelegate

编辑操作代理协议，需要实现以下方法来处理编辑操作：

```swift
public protocol EditableItemDelegate: AnyObject {
    /// 删除操作回调
    func onDeleteAction(item: EditableItemType)
    
    /// 是否可以交换位置（当move的动画类型为exchange时调用）
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool
    
    /// 是否可以移动到某个Item前（当move的动画类型为indicator时调用）
    func canMove(item: EditableItemType, before: Item) -> Bool
    
    /// 是否可以移动到某个Item后（当move的动画类型为indicator时调用）
    func canMove(item: EditableItemType, after: Item) -> Bool
}
```

## 使用方法

### 1. 创建自定义Cell

需要继承 `EditableItemCell`，并将需要跟随编辑状态改变尺寸的内容添加到 `editContentView` 中：

```swift
class TestEditDeleteItemCell: EditableItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 将内容添加到 editContentView，这样在编辑时会自动调整尺寸
        editContentView.addSubview(testLabel)
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

#### 删除模式

```swift
final class TestEditDeleteItem: AutolayoutEditableItemOf<TestEditDeleteItemCell>, ItemType {
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        editType = .delete
        editIcon = UIImage(named: "icon_delete")
        editIconColor = .red
        editIconSize = CGSize(width: 24, height: 24)
        editContainerWidth = 60
    }
    
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? TestEditDeleteItemCell else {
            return
        }
        updateCellData(cell)
    }
    
    override func updateCellData(_ cell: TestEditDeleteItemCell) {
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestEditDeleteItem"
    }
}
```

#### 移动模式

```swift
final class TestEditMoveItem: EditableItemOf<TestEditMoveItemCell>, ItemType {
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        // 使用指示器模式
        editType = .move(.indicator(
            arrowColor: .systemRed,
            arrowSize: CGSize(width: 8, height: 8),
            lineColor: .systemBlue,
            lineWidth: 3
        ))
        // 或使用直接交换模式
        // editType = .move(.exchange)
        editIcon = UIImage(named: "icon_move")
        editIconColor = .black
        editIconSize = CGSize(width: 16, height: 16)
    }
    
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? TestEditMoveItemCell else {
            return
        }
        updateCellData(cell)
    }
    
    func updateCellData(_ cell: TestEditMoveItemCell) {
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestEditMoveItem"
    }
}
```

### 3. 使用示例

```swift
// 实现代理
class ViewController: UIViewController, EditableItemDelegate {
    
    func onDeleteAction(item: EditableItemType) {
        // 处理删除操作
        if let section = item.section {
            section.remove(item: item)
        }
    }
    
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool {
        // 判断是否可以交换位置
        return true
    }
    
    func canMove(item: EditableItemType, before: Item) -> Bool {
        // 判断是否可以移动到目标Item前
        return true
    }
    
    func canMove(item: EditableItemType, after: Item) -> Bool {
        // 判断是否可以移动到目标Item后
        return true
    }
}

// 创建Section和Item
Section("可编辑列表")
    <<< TestEditDeleteItem("删除项1") { item in
        item.delegate = self
        item.editContentCompression = .compression
    }
    <<< TestEditDeleteItem("删除项2") { item in
        item.delegate = self
        item.editContentCompression = .noCompression
    }
    <<< TestEditMoveItem("移动项1") { item in
        item.delegate = self
    }
    <<< TestEditMoveItem("移动项2") { item in
        item.delegate = self
    }

// 进入/退出编辑模式
// 进入编辑模式
form.firstItem(for: "删除项1")?.beginEditing(animation: true)

// 退出编辑模式
form.allItems.forEach { item in
    if let editableItem = item as? EditableItemType {
        editableItem.endEditing(animation: true)
    }
}
```

## 注意事项

1. **内容视图**：需要跟随编辑状态改变尺寸的内容必须添加到 `editContentView` 中，而不是直接添加到 `contentView`
2. **编辑模式控制**：通过 `beginEditing(animation:)` 和 `endEditing(animation:)` 方法控制编辑模式的开启和关闭
3. **代理设置**：必须设置 `delegate` 才能响应删除和移动操作
4. **移动模式**：移动模式下，拖拽手势会自动处理，代理方法会在合适的时机被调用
5. **内容压缩**：根据UI需求选择合适的压缩方式，`.noCompression` 适合内容较多的情况，`.compression` 适合需要保持整体布局的情况

