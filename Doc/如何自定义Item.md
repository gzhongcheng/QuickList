# 如何自定义Item

每个Item都由两个部分组成：

> **Cell**：界面布局，供Collectionview展示的Cell，单元格固定的界面展示控件在Cell中定义并添加并做好布局约束
>
> **Item**：单元格数据对象，用于存储单元格的各种状态，由于Cell的复用机制，对同一cell的各种界面样式修改可以记录在属性中并在`customUpdateCell()`方法中完成修改。

为方便Item的使用，定义了**ItemType**协议，包含了默认的初始化方法（带初始化完成回调），以及各种事件回调，回调的参数则会自动设置为对应的Item的类型，减少类型转换的麻烦。

> **需要注意的是，只有用`final`修饰符修饰的Item类型才能使用ItemType协议自动实现协议中的init方法。**

### 1、定义Cell：

**Cell**: 继承 **ItemCell**，在`setup()`中完成布局方法：

以下是代码模版：

```swift
// MARK: - <#CellName#>
// <#Cell Description#>
class <#CellName#>: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        // **注意：一定要将子控件添加到contentView上，否则可能会出现点击事件失效等情况**
      	// <# add UI to contentView #>
    }
  
  	// <# some UI #>
}
```



### 2、定义Item

框架中提供了手动计算尺寸的`ItemOf<T>`和自动布局计算尺寸的`AutolayoutItemOf<T>`两种Item的基类，可按需进行选择（如果是固定尺寸的，建议直接用手动计算的基类，减少性能消耗）

#### 2.1、使用`ItemOf<T>`

**Item**：继承 **ItemOf< Cell >**，Cell代表了Item对应的Cell类型

可在`customUpdateCell()`方法中调整cell的布局、设置对应Cell的界面展示数据

重写`identifier`返回复用的identifier（可以用不同的id来让cell不复用）

以下是代码模版：

```swift
// MARK: - <#RowName#>
// <#Row Description#>
final class <#RowName#>: ItemOf<<#CellName#>>, ItemType {
    
    
    // 更新cell的布局
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? <#CellName#> else {
            return
        }
        
    }
    
    override var identifier: String {
        return <#Cell identifier#>
    }
    
    
    /// 计算尺寸
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: any FormViewProtocol, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
      	/// 可以按不同布局方式返回不同尺寸，也可以直接返回一个固定的尺寸
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

#### 2.2、使用`AutolayoutItemOf<T>`

**Item**：继承 **AutolayoutItemOf< Cell >**，Cell代表了Item对应的Cell类型

在`updateCellData(:)`方法中调整cell的布局、设置对应Cell的界面展示数据

重写`identifier`返回复用的identifier（可以用不同的id来让cell不复用）

以下是代码模版：

```swift
// MARK: - <#RowName#>
// <#Row Description#>
final class <#RowName#>: AutolayoutItemOf<<#CellName#>>, ItemType {
    
    
    // 更新cell的布局
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? <#CellName#> else {
            return
        }
        updateCellData(cell)
    }
    
    /// 自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸，所以上面的updateCell方法直接转调这个方法
    override func updateCellData(_ cell: <#CellName#>) {
        
    }
    
    override var identifier: String {
        return <#Cell identifier#>
    }
}
```