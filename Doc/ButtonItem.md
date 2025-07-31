# ButtonItem

按钮Item（整个Item为一个按钮），点击可以任意操作（如点击跳转到新的界面）

支持自定义标题样式、右侧箭头样式，同时可添加左侧图标，以及右侧箭头前的自定义View

## 属性 (基类中已有属性未列出)

### 箭头样式

> **arrowType**：箭头样式，枚举类型。
>
> * ButtonItem*包含`不带箭头(.none)和自定义(.custom(image:size:))`两种样式

### 左侧图标

> **iconImage**：左侧图标图片
>
> **iconSize**：左侧图标大小

### 标题

>**fontOfTitle**：字体
>
>**colorOfTitle**：颜色
>
>**alignmentOfTitle**：对齐方式

### 右侧自定义控件（箭头与标题之间靠箭头）

>**rightView**：右侧自定义控件
>
>**rightViewSize**：右侧自定义控件大小

### 间距设置

>**spaceBetweenIconAndTitle**：左侧图标与标题之间的间距
>
>**spaceBetweenTitleAndRightView**：标题与右侧自定义控件之间的间距
>
>**spaceBetweenRightViewAndArrow**：右侧自定义控件与箭头之间的间距

### 点击关联跳转

> **presentationMode**：定义了点击如何后跳转控制器的属性，可以不传

## PresentationMode
PresentationMode是一个定义好的用于快速跳转和获取回调的枚举，定义如下：
```
/**
 定义控制器如何显示

 - Show?:                     使用`show(_:sender:)`方法跳转（自动选择push和present）
 - PresentModally?:           使用Present方式跳转
 - SegueName?:                使用StoryBoard中的Segue identifier跳转
 - SegueClass?:               使用UIStoryboardSegue类跳转
 - popover?:                  使用popoverPresentationController方式展示
 */
public enum PresentationMode<VCType: UIViewController> {
    /// 根据指定的Provider创建控制器，并使用`show(_:sender:)`方法进行跳转
    case show(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /// 根据指定的Provider创建控制器，并使用Present方式跳转
    case presentModally(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /// 使用StoryBoard中的Segue identifier跳转
    case segueName(segueName: String, onDismiss: ((VCType) -> Void)?)

    /// 使用UIStoryboardSegue类执行跳转
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((VCType) -> Void)?)

    /// popoverPresentationController(小窗口)方式展示
    case popover(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)
}
```
使用时，待跳转的VC实现`TypedItemControllerType`协议用以接收调起控制器的item,如：
```
import QuickList

class ItemPresentViewController<Item: TypedCollectionValueItemType>: UIViewController, TypedItemControllerType {
    
    var item: QuickList.Item! {
        didSet {
            guard let item = self.item as? (any TypedCollectionValueItemType) else { return }
            valueLabel.text = item.sendValue as? String
        }
    }
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(valueLabel)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
    }
    
    @objc func backAction() {
        onDismissCallback?(self)
    }
}
```
然后就可以使用ButtonItem的`presentationMode`属性做跳转传值的逻辑了。

## 使用举例

```swift
Section("Section")
<<< ButtonItem("点击跳转(show)") { row in
    item.sendValue = "传值1"
    /// 设置正常颜色
    item.titleColor = .black
    item.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
    /// 设置文本高亮颜色
    item.titleHighlightColor = .white
    /// 自动选择push和present
    item.presentationMode = .show(controllerProvider: .callback(builder: { [weak item] () -> UIViewController in
        let vc = ItemPresentViewController<ButtonItem>()
        vc.modalPresentationStyle = .fullScreen
        vc.item = item
        return vc
    }), onDismiss: { (vc) in
        if vc.navigationController != nil {
            vc.navigationController?.popViewController(animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    })
}
```



