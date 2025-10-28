## Section的使用

Section作为Item的集合容器，实现了Collection相关集合协议，支持通过下标获取Item元素，支持通过append、insert、replace和remove方式对Item进行操作。

####  通用属性

> **isFormHeader**：是否作为整个Form的悬停header，仅对首个section生效
> **suspensionDecoration**：整个section悬浮时的装饰view，这个装饰view的展示区域为整个section，包括header和footer的区域，仅悬浮时展示，结束悬浮就会消失
>
> **tag**：标记Section的唯一标识，同一个List中的section的tag一定不能相同（否则可能导致某些方法获取的section不正确）
> **form**：Section所在的Form
> **index**：获取section在form的index位置
> **items**：存储的所有Item的数组

#### 布局相关

> **column**：列数（默认1列）
> **lineSpace**：行间距（默认0）
> **itemSpace**：列间距（默认0）
> **contentInset**：内容边距
> **layout**：section内部的自定义布局对象，优先级高于from的布局

#### UI相关
> **header**：section的header
> **footer**：section的footer
> **decoration**：section的装饰view，装饰view的展示区域为 header之下，footer之上，作为item组背景装饰用

#### 常用方法
> **estimateItemSize(with weight:)**: 获取预估尺寸（根据指定的列数和间距等计算的正方形尺寸），自定义Item的某些特殊需求可以用这个方法获取尺寸(通常不用)
> **setTitleHeader(_ title:)**: 设置系统样式header
> **setTitleFooter(_ title:)**: 设置系统样式footer
> **hideAllItems(withOut:, withAnimation:)**: 隐藏withOut外的所有item（用于折叠展开）
> **showAllItems(withAnimation:)**: 显示所有item（用于折叠展开）
> **reload()**: 重载所有Item
> **updateLayout(animation:, completion:)**: 仅刷新界面布局，支持多种动画效果，详见[列表重载动画](./ListReloadAnimation_CN.md)

#### 动画操作方法
> **insertItem(with:, at:, animation:, completion:)**: 在指定位置插入单个Item，支持动画效果
> **deleteItems(with:, animation:, completion:)**: 删除指定的Item数组，支持动画效果
> **replaceItems(with:, animation:, completion:)**: 替换所有Item，使用相同动画
> **replaceItems(with:, inAnimation:, outAnimation:, otherSectionsInAnimation:, otherSectionsOutAnimation:, completion:)**: 替换所有Item，支持不同的进入和退出动画
> **replaceItems(with:, at:, animation:, completion:)**: 在指定范围替换Item数组

#### 基础操作方法
> **append(_:)**: 添加单个Item到末尾
> **append(contentsOf:)**: 添加Item数组到末尾
> **insert(_:, at:)**: 在指定位置插入Item
> **replaceSubrange(_:, with:)**: 替换指定范围的Item
> **remove(at:)**: 删除指定位置的Item
> **removeFirst()**: 删除第一个Item
> **removeAll(keepingCapacity:)**: 删除所有Item
> **removeAll(where:)**: 根据条件删除Item

## 使用举例
```
Section(header: "自动换行", footer: nil) { section in
    /// 间距设置
    section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    section.lineSpace = 10
    section.itemSpace = 10

    /// 列数设置
    section.column = 3

    // 自定义header或footer
    /// 可以是自定义的UICollectionReusableView类型
    section.footer = SectionHeaderFooterView<UICollectionReusableView> { view,section in
        
    }
    /// 高度计算方法(如果不设置这个height属性，会使用自动布局的实际高度，需做好约束设置，建议固定高度的header/footer直接设置固定高度)
    //section.footer?.height = { section, estimateItemSize, scrollDirection in
    //    return 40
    //}

    // 自定义装饰view
    section.decoration = SectionDecorationView<UICollectionReusableView> { view in
        let imageView = UIImageView(image: UIImage(named: "E-1251692-C01A20FE"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// 设置layout
//    section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
//    section.layout = QuickListFlowLayout()
    section.layout = RowEqualHeightLayout()
    /// 整个section悬浮
    section.isFormHeader = true
    
    /// 使用动画更新布局
    section.updateLayout(animation: .fade)
    
    /// 动画插入Item
    let newItem = TitleValueItem(title: "新项目", value: "新值")
    section.insertItem(with: newItem, at: 0, animation: .fade) {
        print("插入完成")
    }
    
    /// 动画删除Item
    section.deleteItems(with: [newItem], animation: .leftSlide) {
        print("删除完成")
    }
    
    /// 动画替换所有Item
    let newItems = [TitleValueItem(title: "项目1", value: "值1"), TitleValueItem(title: "项目2", value: "值2")]
    section.replaceItems(with: newItems, inAnimation: .fade, outAnimation: .scale) {
        print("替换完成")
    }
}
```
