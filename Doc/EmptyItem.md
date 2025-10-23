# EmptyItem

Predefined blank placeholder item

## Properties

> **itemSize**: Fixed size
> **itemHeight**: Fixed height (suitable for vertically scrolling Lists)
> **itemWidth**: Fixed width (suitable for horizontally scrolling Lists)
> **itemRatio**: Fixed ratio

Priority: itemSize > itemHeight/itemWidth > itemRatio > 0

## Usage Example

```
Section("LineItem(separator)") { section in
    section.lineSpace = 0
    section.column = 3
    section.header?.shouldSuspension = true
}
    <<< EmptyItem(size: CGSize(width: 10, height: 100))
    <<< EmptyItem(height: 20, weight: 2)
    <<< EmptyItem(ratio: 0.8)
```

