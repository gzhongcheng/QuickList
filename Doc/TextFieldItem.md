# TextFieldItem

Cell with textfield, can display title and input field, with customizable title, input field styles and other properties

![](./TextFieldItem.jpg)

## Properties

### Outermost Box

> **aspectHeight**: Fixed height
>
> **boxInsets**: Margins from box to cell
>
> **boxPadding**: Margins from content to box
>
> **boxBackgroundColor**: Box background color
>
> **boxBorderWidth**: Box border width
>
> **boxHighlightBorderWidth**: Box border width when editing
>
> **boxBorderColor**: Box border color
>
> **boxHighlightBorderColor**: Box border color when editing
>
> **boxCornerRadius**: Box border corner radius

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
> **inputFont**: Font
>
> **inputTextColor**: Color
>
> **inputAlignment**: Alignment
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

### Input Field Event Callbacks

> **onTextShouldChange()**: Whether input is allowed
>
> **onTextDidChanged()**: Input field value changed
>
> **onTextFieldDidBeginEditing()**: Begin editing
>
> **onTextFieldDidEndEditing()**: End editing
>
> **onTextFieldShouldReturn()**: Whether return is allowed
>
> **onTextFieldShouldClear()**: Whether clear is allowed

## Usage Example

***Not recommended*** to add TextFieldItem to horizontally scrolling CollectionView

```
Section("TextFieldItem(input field)") { section in
    section.lineSpace = 0
    section.column = 1
}
    <<< TextFieldItem("Input field:") { row in
        row.placeHolder = "Hint information"
        row.placeHolderColor = .red
        row.aspectRatio = CGSize(width: 375, height: 50)
    }
    <<< TextFieldItem("Input field with border:") { row in
        row.boxInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        row.alignmentOfTextField = .left
        row.placeHolder = "Hint information"
        row.boxBorderWidth = 1.0
        row.boxBorderColor = .green
        row.boxHighlightBorderColor = .blue
        row.forgroundColor = .white
        row.boxCornerRadius = 5
        row.aspectRatio = CGSize(width: 375, height: 50)
    }
    <<< TextFieldItem("Regex limited input:") { row in
        row.placeHolder = "Limit input to two decimal places"
        row.inputPredicateFormat = PredicateFormat.decimal2.rawValue
    }
    <<< TextFieldItem("Callback limited input:") { row in
        row.placeHolder = "Can only input 'a' (even delete is not allowed)"
        row.onTextShouldChange({ (row, textField, range, string) -> Bool in
            return string == "a"
        })
    }
    <<< TextFieldItem("Limit input length") { row in
        row.placeHolder = "Maximum 10 characters"
        row.limitWords = 10
    }
    <<< TextFieldItem("Various textField callbacks") { row in
        row.onTextDidChanged { (r, textField) in
            print("Input value changed:\(textField.text ?? "")")
        }
        row.onTextFieldShouldReturn { (r, t) -> Bool in
            /// Whether return is allowed
            r.cell?.endEditing(true)
            return true
        }
        row.onTextFieldShouldClearBlock { (r, t) -> Bool in
            /// Whether clear is allowed
            return true
        }
        row.onTextFieldDidEndEditing { (r, t) in
            print("Editing completed")
        }
        row.onTextFieldDidBeginEditing { (r, t) in
            print("Begin editing")
        }
    }
```
