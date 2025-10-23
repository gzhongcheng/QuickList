# SegmentPage Usage

SegmentPage is a segmented page controller implemented based on the QuickList framework. It can be embedded in Lists, supports horizontal or vertical page switching, and provides rich menu configuration options and scroll management functionality.

## Core Components

### QuickSegmentSection
As the core container of SegmentPage, it inherits from Section and is responsible for managing menus and page content.

#### Common Properties

> **shouldScrollToTopWhenSelectedTab**: Whether to scroll to top when selecting tab, defaults to true
> **pageScrollEnable**: Whether pages can be switched by scrolling, defaults to false
> **pageViewControllers**: List of page controllers
> **pageContainerHeight**: Page controller container height (defaults to nil, meaning equal to the remaining area after subtracting menu height from parent view)

### QuickSegmentPageViewDelegate
Protocol that page controllers need to implement to provide page content.

> **pageTabItem**: Tab Item corresponding to the page
> **listScrollView()**: Return the page's scroll view

### QuickSegmentScrollManager
Scroll manager responsible for handling complex scroll interaction logic.

> **bouncesType**: Bounce effect type, supports `.root` (main list) and `.page` (sub list)
> **rootScrollView**: Main list reference
> **rootDirection**: Main list scroll direction

## Menu Configuration

### QuickSegmentHorizontalMenuConfig
Horizontal menu configuration, suitable for menus at the top.

> **menuHeight**: Menu height, default 44
> **menuItemSpace**: Menu item spacing, default 30
> **menuListInsets**: Menu list margins, default UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
> **menuBackground**: Menu background view
> **menuBackgroundDecoration**: Menu background decoration view
> **menuSelectedItemDecoration**: Menu selected item decoration view

### QuickSegmentVerticalMenuConfig
Vertical menu configuration, suitable for menus on the left.

> **menuWidthType**: Menu width type, supports `.fixed(width:)` (fixed width) and `.auto(maxWidth:)` (auto width)
> **menuItemLineSpace**: Menu item line spacing, default 10
> **menuListInsets**: Menu list margins, default UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
> **menuBackground**: Menu background view
> **menuBackgroundDecoration**: Menu background decoration view
> **menuSelectedItemDecoration**: Menu selected item decoration view

## Usage

### 1. Create Page Controllers

First, create page controllers that implement the `QuickSegmentPageViewDelegate` protocol:

```swift
class MyPageViewController: UIViewController, QuickSegmentPageViewDelegate {
    // Tab Item corresponding to the page
    lazy var pageTabItem: Item = {
        let item = TitleValueItem("Page Title")
        return item
    }()
    
    // Return the page's scroll view
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return myScrollView // Return your scroll view
    }
    
    // Your page content
    let myScrollView = QuickListView()
}
```

### 2. Create Scroll Manager

```swift
// Create scroll manager
let scrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .root // or .page
)
```

### 3. Create SegmentPage Section

#### Horizontal Menu (Menu at Top)

```swift
// Create menu configuration
let menuConfig = QuickSegmentHorizontalMenuConfig(
    menuHeight: 44,
    menuItemSpace: 30,
    menuListInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
)

// Create page controller array
let pageViewControllers = [
    MyPageViewController1(),
    MyPageViewController2(),
    MyPageViewController3()
]

// Create SegmentPage Section
let segmentSection = QuickSegmentSection(
    menuConfig: menuConfig,
    pageViewControllers: pageViewControllers,
    pageContainerHeight: nil, // Use default height
    pageScrollEnable: true,
    scrollManager: scrollManager
) { section in
    // Optional initialization configuration
    section.shouldScrollToTopWhenSelectedTab = true
}
```

#### Vertical Menu (Menu on Left)

```swift
// Create vertical menu configuration
let menuConfig = QuickSegmentVerticalMenuConfig(
    menuWidthType: .fixed(width: 200),
    menuItemLineSpace: 10,
    menuListInsets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
)

// Create SegmentPage Section
let segmentSection = QuickSegmentSection(
    menuConfig: menuConfig,
    pageViewControllers: pageViewControllers,
    pageContainerHeight: nil,
    pageScrollEnable: true,
    scrollManager: scrollManager
)
```

### 4. Add to Form

```swift
// Add to Form
form +++ segmentSection

// Or use operators
form +++! segmentSection // Add and update interface
```

## Advanced Configuration

### Custom Menu Styles

```swift
// Create custom background
let menuBackground = UIView()
menuBackground.backgroundColor = UIColor.systemBlue

// Create selected decoration view
let selectedDecoration = UIView()
selectedDecoration.backgroundColor = UIColor.white
selectedDecoration.layer.cornerRadius = 4

let menuConfig = QuickSegmentHorizontalMenuConfig(
    menuHeight: 50,
    menuItemSpace: 20,
    menuListInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
    menuBackground: menuBackground,
    menuSelectedItemDecoration: selectedDecoration
)
```

### Scroll Manager Configuration

```swift
// Create scroll managers with different bounce effects
let rootScrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .root // Main list has bounce effect
)

let pageScrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .page // Sub list has bounce effect
)
```

## Notes

1. **Page Controller Lifecycle**: SegmentPage automatically manages page controller lifecycle, including `addChild`, `removeFromParent` operations.

2. **Scroll View Requirements**: Page controller's scroll view needs to implement the `QuickSegmentPageScrollViewType` protocol.

3. **Memory Management**: Page controllers are automatically added to parent controllers, be careful to avoid circular references.

4. **Layout Constraints**: SegmentPage automatically handles page view layout constraints to ensure page content displays correctly.

5. **Scroll Interaction**: Scroll manager handles complex scroll interaction logic to ensure smooth scrolling experience.

## Usage Example

```swift
class ViewController: UIViewController {
    @IBOutlet weak var listView: QuickListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create scroll manager
        let scrollManager = QuickSegmentScrollManager.create(
            rootScrollView: listView,
            bouncesType: .root
        )
        
        // Create page controllers
        let pageViewControllers = [
            createPageViewController(title: "Home", color: .systemBlue),
            createPageViewController(title: "Discover", color: .systemGreen),
            createPageViewController(title: "Profile", color: .systemOrange)
        ]
        
        // Create menu configuration
        let menuConfig = QuickSegmentHorizontalMenuConfig(
            menuHeight: 44,
            menuItemSpace: 30
        )
        
        // Create SegmentPage Section
        let segmentSection = QuickSegmentSection(
            menuConfig: menuConfig,
            pageViewControllers: pageViewControllers,
            pageScrollEnable: true,
            scrollManager: scrollManager
        )
        
        // Add to Form
        listView.form +++ segmentSection
    }
    
    private func createPageViewController(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        
        vc.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return vc
    }
}
```

Through the above configuration, you can create a fully functional segmented page controller in QuickList, supporting menu switching, page scrolling, custom styles, and other rich features.