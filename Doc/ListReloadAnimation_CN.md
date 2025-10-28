## 列表重载动画

QuickList 提供了多种列表重载动画效果，用于在列表数据更新时提供流畅的视觉过渡效果。

### 动画类型

#### 1. 淡入淡出动画 (fade)
- **描述**: 元素以透明度变化的方式进入和退出
- **进入效果**: 从完全透明渐变到完全不透明
- **退出效果**: 从完全不透明渐变到完全透明
- **适用场景**: 适合大多数场景，提供平滑的视觉过渡

```swift
section.updateLayout(animation: .fade)
```

#### 2. 缩放动画 (scale)
- **描述**: 元素以缩放的方式进入和退出
- **进入效果**: 从0倍缩放渐变到1倍缩放
- **退出效果**: 从1倍缩放渐变到0.01倍缩放
- **适用场景**: 适合需要突出显示新内容的场景

```swift
section.updateLayout(animation: .scale)
```

#### 3. 左滑动画 (leftSlide)
- **描述**: 元素从左侧滑入，向左侧滑出
- **进入效果**: 从左侧边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到左侧边界外
- **适用场景**: 适合列表项从左侧添加或删除的场景

```swift
section.updateLayout(animation: .leftSlide)
```

#### 4. 右滑动画 (rightSlide)
- **描述**: 元素从右侧滑入，向右侧滑出
- **进入效果**: 从右侧边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到右侧边界外
- **适用场景**: 适合列表项从右侧添加或删除的场景

```swift
section.updateLayout(animation: .rightSlide)
```

#### 5. 上滑动画 (topSlide)
- **描述**: 元素从上方滑入，向上方滑出
- **进入效果**: 从上方边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到上方边界外
- **适用场景**: 适合列表项从上方添加或删除的场景

```swift
section.updateLayout(animation: .topSlide)
```

#### 6. 下滑动画 (bottomSlide)
- **描述**: 元素从下方滑入，向下方滑出
- **进入效果**: 从下方边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到下方边界外
- **适用场景**: 适合列表项从下方添加或删除的场景

```swift
section.updateLayout(animation: .bottomSlide)
```

#### 7. 位置变换动画 (transform)
- **描述**: 元素从旧位置移动到新位置
- **进入效果**: 从旧的位置属性渐变到新的位置属性
- **退出效果**: 使用渐隐动画
- **适用场景**: 适合列表项位置发生变化时的场景，如排序、重新排列等

```swift
section.updateLayout(animation: .transform)
```

### 动画配置

#### 动画时长
所有动画都支持自定义时长，默认时长为 0.3 秒：

```swift
let animation = ListReloadAnimation.fade
animation.duration = 0.5  // 设置为0.5秒
section.updateLayout(animation: animation)
```

#### 组合使用
可以同时设置进入和退出动画：

```swift
section.updateLayout(
    inAnimation: .fade,      // 进入动画
    outAnimation: .scale     // 退出动画
)
```

### 使用示例

#### 基本使用
```swift
// 使用淡入淡出动画更新布局
section.updateLayout(animation: .fade)

// 使用缩放动画更新布局
section.updateLayout(animation: .scale)

// 使用左滑动画更新布局
section.updateLayout(animation: .leftSlide)
```

#### 自定义动画时长
```swift
let customAnimation = ListReloadAnimation.fade
customAnimation.duration = 0.6
section.updateLayout(animation: customAnimation)
```

#### 组合动画
```swift
section.updateLayout(
    inAnimation: .fade,      // 新元素淡入
    outAnimation: .scale     // 旧元素缩放退出
)
```

### 注意事项

1. **性能考虑**: 复杂的动画可能会影响性能，建议在大量数据更新时使用简单的动画
2. **用户体验**: 动画时长不宜过长，建议保持在 0.2-0.5 秒之间
3. **兼容性**: 所有动画都基于 UIView 的动画系统，兼容性良好
4. **自定义**: 可以通过继承 `ListReloadAnimation` 类来创建自定义动画效果

### 自定义动画

如果需要创建自定义动画，可以继承 `ListReloadAnimation` 类：

```swift
class CustomListReloadAnimation: ListReloadAnimation {
    override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        // 自定义进入动画逻辑
        view.alpha = 0
        view.transform = CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: duration) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    override func animateOut(view: UIView) {
        // 自定义退出动画逻辑
        addOutSnapshotAndDoAnimation(view: view) { snapshot in
            snapshot.alpha = 0
            snapshot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
}
```
