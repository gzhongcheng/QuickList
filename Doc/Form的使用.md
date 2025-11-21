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

All animation operation methods support `ListReloadAnimation` type animation parameters. Available animation types include:
- `.none`: No animation
- `.fade`: Fade in and fade out animation
- `.scaleX`: X-axis scale animation
- `.scaleY`: Y-axis scale animation
- `.scaleXY`: Scale animation on both X-axis and Y-axis
- `.threeDFold`: 3D fold animation
- `.leftSlide`: Slide from left animation
- `.rightSlide`: Slide from right animation
- `.topSlide`: Slide from top animation
- `.bottomSlide`: Slide from bottom animation
- `.transform`: Move from old position to new position animation

> **addSections(with:animation:completion:)**: Add Section array to end with animation support
> - `sections`: Section array
> - `animation`: Enter animation, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **addSection(with:animation:completion:)**: Add single Section to end with animation support
> - `section`: Section to add
> - `animation`: Enter animation, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **insetSection(with:at:animation:completion:)**: Insert Section at specified position with animation support
> - `section`: Section to insert
> - `at`: Insert position index
> - `animation`: Enter animation, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **replaceSections(with:inAnimation:outAnimation:completion:)**: Replace all Sections with different enter and exit animations
> - `sections`: New Section array
> - `inAnimation`: Enter animation for new Sections, defaults to nil (no animation)
> - `outAnimation`: Exit animation for old Sections, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **replaceSections(with:at:inAnimation:outAnimation:completion:)**: Replace Section array at specified range with different enter and exit animations
> - `sections`: New Section array
> - `at`: Range to replace (Range<Int>)
> - `inAnimation`: Enter animation for new Sections, defaults to nil (no animation)
> - `outAnimation`: Exit animation for old Sections, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **deleteSections(with:inAnimation:outAnimation:completion:)**: Delete specified Section array with different enter and exit animations
> - `sections`: Section array to delete
> - `inAnimation`: Enter animation for other Sections (for relayout), defaults to nil (no animation)
> - `outAnimation`: Exit animation for deleted Sections, defaults to nil (no animation)
> - `completion`: Completion callback, defaults to nil

> **updateLayout(afterSection:animation:)**: Only refresh layout after specified Section, does not change data, supports animation
> - `afterSection`: Section index to start refreshing layout from (inclusive)
> - `animation`: Animation effect, defaults to nil (no animation)

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

### Basic Operations
```swift
let form = Form()

// Basic operations (no animation)
let section = Section(header: "New Section")
form.append(section)  // Add Section to end
form.insert(section, at: 0)  // Insert at specified position
form.remove(at: 0)  // Remove Section at specified position
```

### Animate Adding Sections

```swift
// Add single Section with fade animation
let newSection = Section(header: "New Section") { section in
    section <<< TitleValueItem(title: "Item 1", value: "Value 1")
}
form.addSection(with: newSection, animation: .fade) {
    print("Section added")
}

// Add multiple Sections with scale animation
let sections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "Item 1", value: "Value 1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "Item 2", value: "Value 2")
    }
]
form.addSections(with: sections, animation: .scaleXY) {
    print("Sections added")
}

// Insert Section at specified position with left slide animation
let insertSection = Section(header: "Inserted Section")
form.insetSection(with: insertSection, at: 1, animation: .leftSlide) {
    print("Section inserted")
}
```

### Animate Replacing Sections

```swift
// Replace all Sections with different enter and exit animations
let newSections = [
    Section(header: "Section 1") { section in
        section <<< TitleValueItem(title: "Item 1", value: "Value 1")
    },
    Section(header: "Section 2") { section in
        section <<< TitleValueItem(title: "Item 2", value: "Value 2")
    }
]
form.replaceSections(
    with: newSections,
    inAnimation: .fade,      // New Sections fade in
    outAnimation: .scaleXY    // Old Sections scale out
) {
    print("Section replacement completed")
}

// Replace Sections at specified range
form.replaceSections(
    with: newSections,
    at: 0..<2,                // Replace Sections at index 0 to 1
    inAnimation: .rightSlide, // New Sections slide in from right
    outAnimation: .leftSlide  // Old Sections slide out to left
) {
    print("Section range replacement completed")
}

// Replace with 3D fold animation
form.replaceSections(
    with: newSections,
    inAnimation: .threeDFold,
    outAnimation: .threeDFold
) {
    print("3D fold animation replacement completed")
}
```

### Animate Deleting Sections

```swift
// Delete specified Section with slide animation
let sectionToDelete = form[0]
form.deleteSections(
    with: [sectionToDelete],
    inAnimation: .fade,      // Animation for other Sections during relayout
    outAnimation: .rightSlide // Exit animation for deleted Section
) {
    print("Section deletion completed")
}

// Delete multiple Sections with scale exit animation
let sectionsToDelete = [form[0], form[1]]
form.deleteSections(
    with: sectionsToDelete,
    inAnimation: .scaleXY,
    outAnimation: .scaleXY
) {
    print("Multiple Sections deletion completed")
}
```

### Refresh Layout Only (No Data Change)

```swift
// Refresh layout after specified Section with fade animation
form.updateLayout(afterSection: 1, animation: .fade)

// Refresh all Sections layout with scale animation
form.updateLayout(afterSection: 0, animation: .scaleXY)
```

### Custom Animation Duration

```swift
// Create animation with custom duration
let customAnimation = ListReloadAnimation.fade
customAnimation.duration = 0.5  // Set animation duration to 0.5 seconds

form.addSection(with: newSection, animation: customAnimation) {
    print("Custom duration animation completed")
}
```

### Combined Animations

```swift
// Combine fade and scale animations
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)

form.replaceSections(
    with: newSections,
    inAnimation: combinedAnimation,
    outAnimation: .fade
) {
    print("Combined animation completed")
}
```

### No Animation Operations

```swift
// If list view is not yet added to view hierarchy, animation methods will automatically use no animation
// Or explicitly pass .none
form.addSection(with: newSection, animation: .none) {
    print("No animation add completed")
}
```

### Notes

1. **View Hierarchy Requirement**: Animation operation methods will only execute animations when the Form's associated list view has been added to the view hierarchy, otherwise will automatically use no animation
2. **Animation Performance**: Complex animations (such as 3D fold) consume more resources, recommend using simple animations for large data updates
3. **Animation Duration**: All animations default to 0.3 seconds, can be customized by setting `animation.duration`
4. **Completion Callback**: All animation operation methods support completion callback, called after animation execution completes
5. **Exit Animation**: Exit animation will be executed on all Items of deleted/replaced Sections, ensure Item's cell has been created to see exit animation effect