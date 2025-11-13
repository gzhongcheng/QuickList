# SwipeItem

Item that supports left swipe operation, can display operation buttons through left swipe gesture, implementing functions like iOS Mail app's left swipe delete

## Properties (Base class properties not listed)

### Swipe Control

> **canSwipe**: Whether can swipe left, defaults to `true`

### Action Buttons

> **swipedActionButtons**: Buttons displayed when swiping left, array type `[SwipeActionButton]`
>
> Buttons are arranged from right to left in array order, the first button (first element in array) will be displayed on the rightmost side

### Auto Trigger

> **autoTriggerFirstButton**: Whether to automatically trigger the first button's event when continuing to swipe left after all buttons are displayed, defaults to `false`
>
> **autoTriggerFirstButtonThreshold**: Threshold for automatically triggering the first button's event (fixed negative value, unit: px), defaults to `-60`

### Content View

> **swipeContentView**: Content view that follows left swipe, custom content should be added to this view

## SwipeActionButton

Action button displayed when swiping left, supports combination of icon and text display.

### Initialization Method

```swift
public init(
    icon: UIImage? = nil,                    // Icon
    iconTintColor: UIColor = .white,          // Icon color
    title: String? = nil,                    // Text
    titleColor: UIColor = .white,             // Text color
    font: UIFont = .systemFont(ofSize: 14),  // Font
    backgroundColor: UIColor = .red,          // Background color
    width: CGFloat = 80,                      // Button width
    autoCloseSwipe: Bool = true,             // Whether to auto close after clicking
    touchUpInside: (() -> Void)? = nil       // Click event callback
)
```

### Properties

> **width**: Button width
>
> **icon**: Icon image
>
> **iconTintColor**: Icon color
>
> **title**: Button text
>
> **titleColor**: Text color
>
> **font**: Text font
>
> **buttonBackgroundColor**: Button background color
>
> **iconTextSpace**: Spacing between icon and text, defaults to 5
>
> **autoCloseSwipe**: Whether to automatically close swipe operation after clicking button, defaults to `true`
>
> **touchUpInsideAction**: Click event callback

## Usage

### 1. Create Custom Cell

Need to inherit `SwipeItemCell`, and add content that needs to follow left swipe to `swipeContentView`:

```swift
class TestSwipeItemCell: SwipeItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add content to swipeContentView, so it will follow movement when swiping left
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

### 2. Create Custom Item

```swift
final class TestSwipeItem: SwipeAutolayoutItemOf<TestSwipeItemCell>, ItemType {
    
    /**
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
     * This method is needed when autolayout size calculation is required, set data after calculating size
     */
    override func updateCellData(_ cell: TestSwipeItemCell) {
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestSwipedItem"
    }
}
```

### 3. Usage Examples

#### Basic Usage

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Swipe to Delete") { item in
        // Create delete button
        let deleteButton = SwipeActionButton(
            icon: UIImage(systemName: "trash"),
            iconTintColor: .white,
            title: "Delete",
            titleColor: .white,
            backgroundColor: .red,
            width: 80,
            touchUpInside: {
                // Delete operation
                if let section = item.section {
                    section.remove(item: item)
                }
            }
        )
        item.swipedActionButtons = [deleteButton]
    }
```

#### Multiple Action Buttons

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Swipe Multiple Actions") { item in
        // Create multiple buttons, arranged from right to left
        let deleteButton = SwipeActionButton(
            icon: UIImage(systemName: "trash"),
            iconTintColor: .white,
            title: "Delete",
            backgroundColor: .red,
            width: 80,
            touchUpInside: {
                // Delete operation
                if let section = item.section {
                    section.remove(item: item)
                }
            }
        )
        
        let editButton = SwipeActionButton(
            icon: UIImage(systemName: "pencil"),
            iconTintColor: .white,
            title: "Edit",
            backgroundColor: .blue,
            width: 80,
            touchUpInside: {
                // Edit operation
                print("Edit operation")
            }
        )
        
        let shareButton = SwipeActionButton(
            icon: UIImage(systemName: "square.and.arrow.up"),
            iconTintColor: .white,
            title: "Share",
            backgroundColor: .green,
            width: 80,
            touchUpInside: {
                // Share operation
                print("Share operation")
            }
        )
        
        // Buttons arranged from right to left in array order: [Delete, Edit, Share]
        item.swipedActionButtons = [deleteButton, editButton, shareButton]
    }
```

#### Custom Button Style

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Custom Style") { item in
        let customButton = SwipeActionButton(
            icon: UIImage(named: "custom_icon"),
            iconTintColor: .yellow,
            title: "Custom",
            titleColor: .black,
            font: .boldSystemFont(ofSize: 16),
            backgroundColor: .orange,
            width: 100,
            autoCloseSwipe: false,  // Don't auto close after clicking
            touchUpInside: {
                // Custom operation
                print("Custom operation")
                // Manually close
                item.cell?.closeSwipeActions()
            }
        )
        customButton.iconTextSpace = 8  // Custom icon and text spacing
        
        item.swipedActionButtons = [customButton]
        item.autoTriggerFirstButton = true  // Enable auto trigger
        item.autoTriggerFirstButtonThreshold = -80  // Set trigger threshold
    }
```

#### Icon Only Button

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Icon Only") { item in
        let iconButton = SwipeActionButton(
            icon: UIImage(systemName: "heart.fill"),
            iconTintColor: .white,
            backgroundColor: .systemPink,
            width: 60,
            touchUpInside: {
                print("Like")
            }
        )
        item.swipedActionButtons = [iconButton]
    }
```

#### Text Only Button

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Text Only") { item in
        let textButton = SwipeActionButton(
            title: "More",
            titleColor: .white,
            font: .systemFont(ofSize: 14),
            backgroundColor: .gray,
            width: 70,
            touchUpInside: {
                print("More actions")
            }
        )
        item.swipedActionButtons = [textButton]
    }
```

#### Disable Swipe

```swift
Section("Swipe Action List")
    <<< TestSwipeItem("Disable Swipe") { item in
        item.canSwipe = false  // Disable swipe functionality
    }
```

## Gesture Interaction

1. **Swipe Left to Expand**: Swiping left can expand action buttons
2. **Swipe Right to Close**: Swiping right or clicking button will automatically close
3. **Quick Swipe**: Quick left swipe (velocity > 500) will automatically expand, quick right swipe (velocity > 500) will automatically close
4. **Auto Trigger**: When `autoTriggerFirstButton` is `true`, continuing to swipe left beyond threshold after fully expanded will automatically trigger the first button's event
5. **Singleton Control**: Only one Item can be in left swipe expanded state at a time, expanding a new Item will automatically close the previously expanded Item

## Notes

1. **Content View**: Content that needs to follow left swipe movement must be added to `swipeContentView`, not directly to `contentView`
2. **Button Order**: Buttons in `swipedActionButtons` array are arranged from right to left in order, first element is displayed on the rightmost side
3. **Button Width**: The first button (first element in array) width can be adaptive (`greaterThanOrEqualTo`), other buttons use fixed width
4. **Auto Close**: By default, clicking button will automatically close swipe operation, can be controlled through `autoCloseSwipe` property
5. **Scroll Conflict**: Left swipe gesture automatically handles conflict with scroll view, temporarily disables scrolling during left swipe
6. **Gesture Recognition**: Left swipe gesture only triggers on horizontal swipe, vertical swipe will not trigger

