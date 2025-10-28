## Form Usage

Form serves as a collection container for Sections, implementing Collection-related collection protocols. It supports accessing Section elements through subscripts and performing operations on Sections through append, insert, replace, and remove methods.

#### Common Properties

> **header**: List header
> **footer**: List footer
> **singleSelection**: Whether single selection is enabled
> **selectedItemDecorationPosition**: Layer relationship between selected item decoration view and item, defaults to below
> **selectedItemDecoration**: Common decoration view for selected items in the list, usually displayed below the selected item layer with item size. After setting, the list will be forced into single selection mode
> **selectedItemDecorationMoveDuration**: Animation duration for selected item decoration view movement, defaults to 0.25s
>
> **backgroundDecoration**: Background decoration view for the entire list, displayed at the bottom layer of the list with list size, and its interaction will be disabled internally

#### Layout Related

> **needCenterIfNotFull**: Whether to center display within the control range when content doesn't fill the list
> **contentInset**: Content margins
> **layout**: Custom layout method for the entire list, defaults to `QuickListFlowLayout` when not set

#### Common Methods
> **section(for tag:)**: Get Section corresponding to tag
> **firstItem(for tag:)**: Get the first item corresponding to tag

#### Animation Operation Methods
> **replaceSections(with:, inAnimation:, outAnimation:, completion:)**: Replace all Sections with different enter and exit animations
> **replaceSections(with:, at:, inAnimation:, outAnimation:, completion:)**: Replace Section array at specified range
> **deleteSections(with:, inAnimation:, outAnimation:, completion:)**: Delete specified Section array with animation support

#### Basic Operation Methods
> **append(_:)**: Add single Section to end
> **append(contentsOf:)**: Add Section array to end
> **insert(_:, at:)**: Insert Section at specified position
> **replaceSubrange(_:, with:)**: Replace Sections in specified range
> **remove(at:)**: Remove Section at specified position
> **removeFirst()**: Remove first Sectione
> **removeAll(keepingCapacity:)**: Remove all Sections
> **removeAll(where:)**: Remove Sections based on condition

## Usage Example
```
let form = Form()

// Animate replace all Sections
let newSections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "Item 1", value: "Value 1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "Item 2", value: "Value 2")
    }
]
form.replaceSections(with: newSections, inAnimation: .fade, outAnimation: .scale) {
    print("Section replacement completed")
}

// Animate delete Sections
form.deleteSections(with: [newSections[0]], inAnimation: .leftSlide, outAnimation: .rightSlide) {
    print("Section deletion completed")
}

// Basic operations
let section = Section(header: "New Section")
form.append(section)  // Add Section
form.insert(section, at: 0)  // Insert at specified position
form.remove(at: 0)  // Remove Section at specified position
```