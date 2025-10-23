# How to Customize Item

Each Item consists of two parts:

> **Cell**: Interface layout, Cell for CollectionView display. Fixed interface display controls for the cell are defined, added, and layout constraints are set in the Cell
>
> **Item**: Cell data object, used to store various states of the cell. Due to Cell's reuse mechanism, various interface style modifications for the same cell can be recorded in properties and completed in the `customUpdateCell()` method.

For convenience in using Items, the **ItemType** protocol is defined, which includes default initialization methods (with initialization completion callbacks) and various event callbacks. The callback parameters are automatically set to the corresponding Item type, reducing the hassle of type conversion.

> **Note: Only Item types modified with the `final` modifier can use the ItemType protocol to automatically implement the init method in the protocol.**

### 1. Define Cell:

**Cell**: Inherit from **ItemCell**, complete layout methods in `setup()`:

Here's the code template:

```swift
// MARK: - <#CellName#>
// <#Cell Description#>
class <#CellName#>: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        // **Note: Must add sub-controls to contentView, otherwise click events may fail**
      	// <# add UI to contentView #>
    }
  
  	// <# some UI #>
}
```



### 2. Define Item

The framework provides two base classes for Items: `ItemOf<T>` for manual size calculation and `AutolayoutItemOf<T>` for auto layout size calculation. Choose as needed (if it's a fixed size, recommend using the manual calculation base class directly to reduce performance consumption)

#### 2.1. Using `ItemOf<T>`

**Item**: Inherit from **ItemOf< Cell >**, where Cell represents the Cell type corresponding to the Item

Can adjust cell layout and set corresponding Cell interface display data in the `customUpdateCell()` method

Override `identifier` to return the reuse identifier (can use different ids to prevent cell reuse)

Here's the code template:

```swift
// MARK: - <#ItemName#>
// <#Item Description#>
final class <#ItemName#>: ItemOf<<#CellName#>>, ItemType {
    
    
    // Update cell layout
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? <#CellName#> else {
            return
        }
        
    }
    
    override var identifier: String {
        return <#Cell identifier#>
    }
    
    
    /// Calculate size
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
      	/// Can return different sizes based on different layout methods, or directly return a fixed size
        switch layoutType {
        case .vertical:
            return <#CGSize#>
        case .horizontal:
            return <#CGSize#>
        case .free:
            return <#CGSize#>
        }
    }
}
```

#### 2.2. Using `AutolayoutItemOf<T>`

**Item**: Inherit from **AutolayoutItemOf< Cell >**, where Cell represents the Cell type corresponding to the Item

Adjust cell layout and set corresponding Cell interface display data in the `updateCellData(:)` method

Override `identifier` to return the reuse identifier (can use different ids to prevent cell reuse)

Here's the code template:

```swift
// MARK: - <#ItemName#>
// <#Item Description#>
final class <#ItemName#>: AutolayoutItemOf<<#CellName#>>, ItemType {
    
    
    // Update cell layout
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? <#CellName#> else {
            return
        }
        updateCellData(cell)
    }
    
    /// This method is needed for auto layout size calculation, setting data first then calculating size, so the above updateCell method directly calls this method
    override func updateCellData(_ cell: <#CellName#>) {
        
    }
    
    override var identifier: String {
        return <#Cell identifier#>
    }
}
```

You can add the template code for creating Cell and Item to Xcode's [Code Snippets](https://cloud.tencent.com/developer/article/1615615) for quick creation.