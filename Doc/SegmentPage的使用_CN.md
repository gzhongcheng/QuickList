# SegmentPage的使用

SegmentPage是基于QuickList框架实现的分段页面控制器，可以嵌入到List中，支持水平或垂直方向的页面切换，提供丰富的菜单配置选项和滚动管理功能。

## 核心组件

### QuickSegmentSection
作为SegmentPage的核心容器，继承自Section，负责管理菜单和页面内容。

#### 通用属性

> **shouldScrollToTopWhenSelectedTab**：选择tab时是否置顶，默认为true
> **pageScrollEnable**：页面是否可以滚动切换，默认为false
> **pageViewControllers**：页面控制器列表
> **pageContainerHeight**：页面控制器容器高度(默认为nil，表示和父视图扣去菜单高度后的剩余区域等高)

### QuickSegmentPageViewDelegate
页面控制器需要实现的协议，用于提供页面内容。

> **pageTabItem**：页面对应的Tab Item
> **listScrollView()**：返回页面的滚动视图

### QuickSegmentScrollManager
滚动管理器，负责处理复杂的滚动交互逻辑。

> **bouncesType**：阻尼效果类型，支持`.root`(总列表)和`.page`(子列表)
> **rootScrollView**：总列表引用
> **rootDirection**：总表的滚动方向

## 菜单配置

### QuickSegmentHorizontalMenuConfig
水平菜单配置，适用于菜单在顶部的情况。

> **menuHeight**：菜单高度，默认44
> **menuItemSpace**：菜单项间距，默认30
> **menuListInsets**：菜单列表边距，默认UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
> **menuBackground**：菜单背景视图
> **menuBackgroundDecoration**：菜单背景装饰视图
> **menuSelectedItemDecoration**：菜单选中项装饰视图

### QuickSegmentVerticalMenuConfig
垂直菜单配置，适用于菜单在左侧的情况。

> **menuWidthType**：菜单宽度类型，支持`.fixed(width:)`(固定宽度)和`.auto(maxWidth:)`(自动宽度)
> **menuItemLineSpace**：菜单项行间距，默认10
> **menuListInsets**：菜单列表边距，默认UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
> **menuBackground**：菜单背景视图
> **menuBackgroundDecoration**：菜单背景装饰视图
> **menuSelectedItemDecoration**：菜单选中项装饰视图

## 使用方式

### 1. 创建页面控制器

首先需要创建实现`QuickSegmentPageViewDelegate`协议的页面控制器：

```swift
class MyPageViewController: UIViewController, QuickSegmentPageViewDelegate {
    // 页面对应的Tab Item
    lazy var pageTabItem: Item = {
        let item = TitleValueItem("页面标题")
        return item
    }()
    
    // 返回页面的滚动视图
    func listScrollView() -> QuickSegmentPageScrollViewType? {
        return myScrollView // 返回你的滚动视图
    }
    
    // 你的页面内容
    let myScrollView = QuickListView()
}
```

### 2. 创建滚动管理器

```swift
// 创建滚动管理器
let scrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .root // 或 .page
)
```

### 3. 创建SegmentPage Section

#### 水平菜单（菜单在顶部）

```swift
// 创建菜单配置
let menuConfig = QuickSegmentHorizontalMenuConfig(
    menuHeight: 44,
    menuItemSpace: 30,
    menuListInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
)

// 创建页面控制器数组
let pageViewControllers = [
    MyPageViewController1(),
    MyPageViewController2(),
    MyPageViewController3()
]

// 创建SegmentPage Section
let segmentSection = QuickSegmentSection(
    menuConfig: menuConfig,
    pageViewControllers: pageViewControllers,
    pageContainerHeight: nil, // 使用默认高度
    pageScrollEnable: true,
    scrollManager: scrollManager
) { section in
    // 可选的初始化配置
    section.shouldScrollToTopWhenSelectedTab = true
}
```

#### 垂直菜单（菜单在左侧）

```swift
// 创建垂直菜单配置
let menuConfig = QuickSegmentVerticalMenuConfig(
    menuWidthType: .fixed(width: 200),
    menuItemLineSpace: 10,
    menuListInsets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
)

// 创建SegmentPage Section
let segmentSection = QuickSegmentSection(
    menuConfig: menuConfig,
    pageViewControllers: pageViewControllers,
    pageContainerHeight: nil,
    pageScrollEnable: true,
    scrollManager: scrollManager
)
```

### 4. 添加到Form中

```swift
// 添加到Form
form +++ segmentSection

// 或者使用运算符
form +++! segmentSection // 添加并更新界面
```

## 高级配置

### 自定义菜单样式

```swift
// 创建自定义背景
let menuBackground = UIView()
menuBackground.backgroundColor = UIColor.systemBlue

// 创建选中装饰视图
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

### 滚动管理器配置

```swift
// 创建不同阻尼效果的滚动管理器
let rootScrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .root // 总列表有阻尼效果
)

let pageScrollManager = QuickSegmentScrollManager.create(
    rootScrollView: rootListView,
    bouncesType: .page // 子列表有阻尼效果
)
```

## 注意事项

1. **页面控制器生命周期**：SegmentPage会自动管理页面控制器的生命周期，包括`addChild`、`removeFromParent`等操作。

2. **滚动视图要求**：页面控制器的滚动视图需要实现`QuickSegmentPageScrollViewType`协议。

3. **内存管理**：页面控制器会被自动添加到父控制器中，注意避免循环引用。

4. **布局约束**：SegmentPage会自动处理页面视图的布局约束，确保页面内容正确显示。

5. **滚动交互**：滚动管理器会处理复杂的滚动交互逻辑，确保滚动体验流畅。

## 使用举例

```swift
class ViewController: UIViewController {
    @IBOutlet weak var listView: QuickListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建滚动管理器
        let scrollManager = QuickSegmentScrollManager.create(
            rootScrollView: listView,
            bouncesType: .root
        )
        
        // 创建页面控制器
        let pageViewControllers = [
            createPageViewController(title: "首页", color: .systemBlue),
            createPageViewController(title: "发现", color: .systemGreen),
            createPageViewController(title: "我的", color: .systemOrange)
        ]
        
        // 创建菜单配置
        let menuConfig = QuickSegmentHorizontalMenuConfig(
            menuHeight: 44,
            menuItemSpace: 30
        )
        
        // 创建SegmentPage Section
        let segmentSection = QuickSegmentSection(
            menuConfig: menuConfig,
            pageViewControllers: pageViewControllers,
            pageScrollEnable: true,
            scrollManager: scrollManager
        )
        
        // 添加到Form
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

通过以上配置，你就可以在QuickList中创建一个功能完整的分段页面控制器，支持菜单切换、页面滚动、自定义样式等丰富功能。
