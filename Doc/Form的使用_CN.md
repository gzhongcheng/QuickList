## Form的使用

Form作为Section的集合容器，实现了Collection相关集合协议，支持通过下标获取Section元素，支持通过append、insert、replace和remove方式对Section进行操作。

####  通用属性

> **header**：列表的Header
> **footer**：列表的Footer
> **singleSelection**：是否单选
> **selectedItemDecorationPosition**：选中item装饰view与item的图层关系，默认为below
> **selectedItemDecoration**：列表通用的选中item的装饰view，通常展示在选中item图层之下，尺寸为item大小，设置后，列表将强制变成单选状态
> **selectedItemDecorationMoveDuration**：选中item装饰view的移动动画时长，默认为0.25s
>
> **backgroundDecoration**：列表整体的背景装饰view，展示在列表最底层，尺寸为列表大小，且内部会将它的交互禁用

#### 布局相关

> **needCenterIfNotFull**：内容未填满列表时是否需要在控件范围内居中展示
> **contentInset**：内容边距
> **layout**：列表整体的自定义布局方式，未设置时默认使用`QuickListFlowLayout`布局

#### 常用方法
> **section(for tag:)**: 获取tag对应的Section
> **firstItem(for tag:)**: 获取tag对应的第一个item
