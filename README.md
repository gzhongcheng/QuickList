# QuickList

使用Swift编写的快速创建CollectionView的框架

## 要求

- Xcode 16.0+
- Swift 5+

### 示例程序

你可以clone这个项目，然后运行Example来查看QuickList的大部分特性。

## 安装

QuickList 支持 [CocoaPods](https://cocoapods.org). 安装

QuickList项目分成三个subspec：
> **Base**：包含基础的QuickList控件、预定好的Layouts、Form、Section、Item，以及运算符
>
> **Items**：包含已经预定义好的部分Item
>
> **WebImage**：包含已经预定义好的ImageItem及网络图片相关加载缓存逻辑扩展，此模块依赖于`Kingfisher`和`KingfisherWebP`，因此单独拆分放置

添加下面代码到项目的 Podfile 文件中:

```ruby
pod 'QuickList', :path => '../', :subspecs => ['Base', 'Items', 'WebImage']
```

> 为方便快速创建Item，在项目的xctemplate文件夹下，已经创建了一些模板文件，可将它们复制到 `/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates/Source` 文件夹下，这样就可以在创建文件时直接选择对应的Item类型来创建
> 另外，在本项目的根目录下，可以找到`CodeSnippets.zip`压缩包，里面是一些预定好的代码段，可将它解压到 `~/Library/Developer/Xcode/UserData/CodeSnippets/` 文件夹下，然后在Xcode的`Code Snippets`中就可以查看并使用了。

## 运算符相关

框架中定义了一些运算符，用于快速操作Form和Section，具体如下：

| 运算符 | 描述                                                   | 左侧对象          | 右侧对象                                                     |
| ------ | ------------------------------------------------------ | ----------------- | ------------------------------------------------------------ |
| `+++`    | 添加Section或Item（添加Item时会自动添加一个Section） | `Form`            | `Section`或`Item`                                         |
| `+++!`   | 添加Section或Item，并更新界面                   | `Form`          | `Section`或`Item`                                                  |
| `<<<`    | 添加Item                                            | `Section`         | `Item`                                                    |
| `<<<!`   | 添加Item或[Item]，并更新界面                        |  `Section`       | `Item`或`[Item]`                                      |
| +=     | 添加右侧对象数组中的所有元素                           | `Form`或`Section` | `[Section]`或`[Item]`                                     |
| `>>>`   | 替换右侧对象数组中的所有元素到指定位置 | `Form`或`Section` | `>>>` 有两种使用方式：<br />1、使用 `>>> [Section]`或`[Item]`，将目标数组的元素直接替换原有的`Form`或`Section`中的所有元素<br />2、使用 `>>> (n ..< m, [Section]或[Item])`，将替换目标数组到指定范围（如，n ..< m 表示 n到m-1的所有元素） |
| `>>>!` | 替换右侧对象数组中的所有元素到指定位置，并更新界面   | `Form`或`Section` | 使用方式同 `>>>`                                             |
| `---` | 移除所有元素，并更新界面 | `Form`或`Section` | 无 |

## 创建列表

### 创建CollectionView

使用`QuickListView`创建列表，如：

```swift
import QuickList

let listView = QuickListView()

listView.form +++ Section("Section")
```
QuickListView继承于UICollectionView，并增加了以下属性和方法：

> **form**：列表绑定的Form对象，用于处理数据集
> **scrollDirection**：滚动方向,默认为竖直方向滚动
> **listSizeChangedBlock**：列表总尺寸变化回调，适用于需要根据展示内容的实际尺寸来调整布局的情况
> **reload()**：设置需要reload
> **selectItem(item:)**：设置选中指定的item（如果item的scrollToSelected为true，会自动滚动到item的位置）


## 布局设置
框架中目前已有定义好的Layout如下：

|     名称      |                             说明                             |                       效果图                        |
| :-----------: | :----------------------------------------------------------: | :-------------------------------------------------: |
|   QuickListFlowLayout   | 瀑布流布局 |   ![](./Doc/ImageItem.gif) |
|   QuickYogaLayout   | 垂直于滚动方向排布的Item流，支持自动换行，适用于tag之类的展示的布局 |       ![](./Doc/QuickYogaLayout.png)           |
|   RowEqualHeightLayout   | 按整行的所有元素的最大高度做为该行的item的高度的布局 |        ![](./Doc/RowEqualHeightLayout.png)       |

使用时，可对整个Form设置layout：
```
form.layout = QuickListFlowLayout()
```
也可对单个Section设置layout：
```
Section("自定义layout") { section in
    section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
}
```
内容自定义布局的优先级 section.layout -> form.layout -> QuickListFlowLayout（默认）

## 使用说明

[Form](./Doc/Form的使用.md)

[Section](./Doc/Section的使用.md)

[Item](./Doc/Item的使用.md)

---
## 功能计划
#### 内联单元格（InlineItem）
将两个item相互关联，让一个做为另一个的内联单元格，点击主单元格时可以展开/收起内联单元格
（待开发）

#### item拖动
支持item的拖动动画交互功能
（待开发）

#### 左(右)滑展开按钮
支持类似tableView的侧滑展开按钮列表功能
（待开发）

#### SegmentPage
使用QuickList为基础创建的可以嵌入List中的pageController
[使用文档](.Doc/SegmentPage的使用.md)

#### Picker
使用QuickList为基础创建的PickerView
（待开发）

#### 支持SwiftUI
（待开发）

---

## 作者

Guo ZhongCheng, gzhongcheng@qq.com

## License

QuickList is available under the MIT license. See the LICENSE file for more info.
