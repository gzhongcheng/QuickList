# EditableItem

Item that supports editing functionality, can display operation buttons (delete or move) through edit mode to implement delete and move functionality for list items

## Properties (Base class properties not listed)

### Edit Type

> **editType**: Edit type, enum type `EditableItemEditType`
>
> - `.delete`: Delete mode, clicking edit button triggers delete operation
> - `.move(_ moveAnimation: EditableItemMoveAnimation)`: Move mode, supports drag to move Item position
>   - `.exchange`: Direct exchange mode, directly exchanges with target position when dragging
>   - `.indicator(arrowColor:arrowSize:lineColor:lineWidth:)`: Indicator mode, shows target position indicator, exchanges after dragging to target position

### Edit State

> **isEditing**: Edit state, controls whether to show edit operation buttons
>
> **isDragging**: Whether is currently dragging (used in move mode)

### Edit Icon

> **editIcon**: Icon image for edit button
>
> **editIconColor**: Edit icon color, defaults to black
>
> **editIconSize**: Edit icon size, defaults to 20x20

### Edit Container

> **editContainerWidth**: Width when edit container is expanded, defaults to 40

### Content Compression

> **editContentCompression**: Content compression method when editing, enum type `EditableItemEditContentCompression`
>
> - `.noCompression`: No compression container, move as a whole to the left (default)
> - `.compression`: Compress container, content area shrinks

### Delegate

> **delegate**: Edit operation delegate, needs to implement `EditableItemDelegate` protocol to handle delete and move operations

## EditableItemDelegate

Edit operation delegate protocol, needs to implement the following methods to handle edit operations:

```swift
public protocol EditableItemDelegate: AnyObject {
    /// Delete operation callback
    func onDeleteAction(item: EditableItemType)
    
    /// Whether can exchange position (called when move animation type is exchange)
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool
    
    /// Whether can move before a certain Item (called when move animation type is indicator)
    func canMove(item: EditableItemType, before: Item) -> Bool
    
    /// Whether can move after a certain Item (called when move animation type is indicator)
    func canMove(item: EditableItemType, after: Item) -> Bool
}
```

## Usage

### 1. Create Custom Cell

Need to inherit `EditableItemCell`, and add content that needs to follow edit state size changes to `editContentView`:

```swift
class TestEditDeleteItemCell: EditableItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add content to editContentView, so it will automatically adjust size when editing
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

### 2. Create Custom Item

#### Delete Mode

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

#### Move Mode

```swift
final class TestEditMoveItem: EditableItemOf<TestEditMoveItemCell>, ItemType {
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        // Use indicator mode
        editType = .move(.indicator(
            arrowColor: .systemRed,
            arrowSize: CGSize(width: 8, height: 8),
            lineColor: .systemBlue,
            lineWidth: 3
        ))
        // Or use direct exchange mode
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

### 3. Usage Example

```swift
// Implement delegate
class ViewController: UIViewController, EditableItemDelegate {
    
    func onDeleteAction(item: EditableItemType) {
        // Handle delete operation
        if let section = item.section {
            section.remove(item: item)
        }
    }
    
    func canExchange(item: EditableItemType, to targetItem: Item) -> Bool {
        // Determine whether can exchange position
        return true
    }
    
    func canMove(item: EditableItemType, before: Item) -> Bool {
        // Determine whether can move before target Item
        return true
    }
    
    func canMove(item: EditableItemType, after: Item) -> Bool {
        // Determine whether can move after target Item
        return true
    }
}

// Create Section and Item
Section("Editable List")
    <<< TestEditDeleteItem("Delete Item 1") { item in
        item.delegate = self
        item.editContentCompression = .compression
    }
    <<< TestEditDeleteItem("Delete Item 2") { item in
        item.delegate = self
        item.editContentCompression = .noCompression
    }
    <<< TestEditMoveItem("Move Item 1") { item in
        item.delegate = self
    }
    <<< TestEditMoveItem("Move Item 2") { item in
        item.delegate = self
    }

// Enter/Exit edit mode
// Enter edit mode
form.firstItem(for: "Delete Item 1")?.beginEditing(animation: true)

// Exit edit mode
form.allItems.forEach { item in
    if let editableItem = item as? EditableItemType {
        editableItem.endEditing(animation: true)
    }
}
```

## Notes

1. **Content View**: Content that needs to follow edit state size changes must be added to `editContentView`, not directly to `contentView`
2. **Edit Mode Control**: Control edit mode on/off through `beginEditing(animation:)` and `endEditing(animation:)` methods
3. **Delegate Setting**: Must set `delegate` to respond to delete and move operations
4. **Move Mode**: In move mode, drag gesture is automatically handled, delegate methods will be called at appropriate times
5. **Content Compression**: Choose appropriate compression method based on UI requirements, `.noCompression` is suitable for content with more content, `.compression` is suitable for maintaining overall layout

