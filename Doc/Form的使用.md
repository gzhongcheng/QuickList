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