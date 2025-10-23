# TextViewItem

Multi-line input cell with textview input field, can display left title and right input field, with customizable title, input field styles, auto-adjusting height

![](TextViewItem.gif)

## Properties

### Height

> **minHeight**: Minimum height
>
> **autoHeight**: Whether auto height, defaults to true

### Outermost Box

> **boxInsets**: Margins from box to cell
>
> **boxPadding**: Margins from content to box
>
> **boxBackgroundColor**: Box background color
>
> **boxBorderWidth**: Box border width
>
> **boxBorderColor**: Box border color
>
> **boxCornerRadius**: Box border corner radius
>
> **boxEditingBorderColor**: Box border color when editing
>
> **boxEditingBorderWidth**: Box border width when editing

### Left Title

> **title**: Row's title will be set as left title display
>
> **titlePosition**: Position, TitlePosition type, includes `.left` (left auto width) and `.width(:)` (specified width) styles
>
> **titleFont**: Font
>
> **titleTextColor**: Color
>
> **titleLines**: Number of lines
>
> **titleAlignment**: Alignment
>
> **attributeTitle**: Rich text title, if set, will replace title to display this

### Input Field

> **inputSpaceToTitle**: Spacing to title
>
> **inputContentPadding**: Margins from input content to input field
>
> **inputFont**: Font
>
> **inputTextColor**: Color
>
> **inputBackgroundColor**: Input field background color
>
> **inputBorderWidth**: Border width
>
> **inputBorderColor**: Border color
>
> **inputEditingBorderColor**: Input field border color when editing
>
> **inputEditingBorderWidth**: Input field border width when editing
>
> **inputCornerRadius**: Border corner radius
>
> **keyboardType**: Keyboard style
>
> **returnKeyType**: Keyboard confirm button style
>
> **placeHolder**: Placeholder text
>
> **placeHolderColor**: Placeholder text color
>
> **inputPredicateFormat**: Input content regex validation expression, PredicateFormat defines several common expressions like pure numbers, decimal places limit, etc., can be referenced
>
> **limitWords**: Input character limit
>
> **showLimit**: Whether to show character limit (bottom right of input field)

### Input Field Event Callbacks

> **onTextDidChanged()**: Input field value changed

## Usage Example

***Not recommended*** to add TextViewItem to horizontally scrolling CollectionView

```
Section("TextViewItem(multi-line input field)") { section in
    section.lineSpace = 0
    section.column = 1
}
<<< TextViewItem("Multi-line text input:\n(auto height)") { row in
    row.placeholder = "Maximum 100"
    row.showLimit = true
    row.limitWords = 100
    row.inputBorderColor = .red
    row.inputBorderWidth = 1
    row.inputCornerRadius = 3
    row.boxBorderColor = .blue
    row.boxBorderWidth = 1
    row.boxCornerRadius = 5
    row.boxPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    row.minHeight = 100
}
<<< TextViewItem("Multi-line text input:\n(auto height)") { row in
    row.placeholder = "No input limit"
    row.showLimit = false
    row.inputBorderColor = .gray
    row.inputBorderWidth = 2
    row.inputCornerRadius = 3
    row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    row.minHeight = 100
}
<<< TextViewItem() { row in
    row.placeholder = "Input field without title, no input character limit"
    row.showLimit = false
    row.inputBorderColor = .gray
    row.inputBorderWidth = 2
    row.inputCornerRadius = 3
    row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    row.minHeight = 50
}
```
