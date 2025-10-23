# TitleValueItem

Text display cell

Can display title and value, with customizable title, value styles and positions
![](./TitleValueItem.jpg) 

## Properties

### Overall Settings (Base class properties not listed)

> **verticalAlignment**: Vertical arrangement method
>
> **spaceBetweenTitleAndValue**: Spacing between title and value

### Title Style

> **title**: Title content text
> **attributeTitle**: Rich text title, if set, will replace title to display this
> **titlePosition**: Position (auto width/fixed width)
> **titleFont**: Font
> **titleColor**: Font color
> **titleAlignment**: Alignment
> **titleLines**: Number of lines

### Value Style

>**value**: Value content text
>**attributeValue**: Rich text value, if set, will replace value to display this
>**valueFont**: Font
>**valueColor**: Font color
>**valueLines**: Number of lines
>**valueAlignment**: Alignment

## Usage Example

```
Section("TitleValueItem") { section in
    section.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
    section.lineSpace = 10
    section.column = 1
    section.header?.shouldSuspension = true
}
        <<< TitleValueItem("title plus value"){ item in
            item.verticalAlignment = .top
            item.spaceBetweenTitleAndValue = 8
            item.valueAlignment = .left
            item.value = "This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value This is value"
        }
        <<< TitleValueItem("Title Style") { item in
            item.verticalAlignment = .top

            item.titlePosition = .left
            item.titleFont = UIFont.boldSystemFont(ofSize: 15)
            item.titleColor = .darkText
            item.titleAlignment = .center

            item.valueColor = .blue
            item.valueAlignment = .left
            item.value = "Value style, then this is a relatively long string, let's see if it can wrap\nAdd a return to try"
        }
    <<< TitleValueItem("Only a relatively long title, try to see if it can display normally to fill, then see if it can wrap automatically, margins around are set to 0") { item in
        item.verticalAlignment = .top
        item.contentInsets = .zero
    }
    <<< TitleValueItem("This is also a relatively long title, set top and bottom margins to zero, set fixed width",tag: "DEFAULT_LABEL") { item in
        item.value = "When both title and value are long, the title will squeeze the value's space, so need to set maximum width for the title to achieve better display effect"
        item.titlePosition = .width(120)
    }
```
