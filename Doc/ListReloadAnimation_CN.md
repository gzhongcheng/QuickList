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

#### 2. 缩放动画 (scaleX / scaleY / scaleXY)
- **描述**: 元素以缩放的方式进入和退出，支持单独控制 X 轴或 Y 轴缩放
- **类型**:
  - `scaleX`: 仅在 X 轴方向缩放
  - `scaleY`: 仅在 Y 轴方向缩放
  - `scaleXY`: 在 X 轴和 Y 轴方向同时缩放（默认）
- **进入效果**: 从0倍缩放渐变到1倍缩放
- **退出效果**: 从1倍缩放渐变到0.01倍缩放
- **适用场景**: 适合需要突出显示新内容的场景

```swift
// X 轴缩放
section.updateLayout(animation: .scaleX)

// Y 轴缩放
section.updateLayout(animation: .scaleY)

// X 轴和 Y 轴同时缩放
section.updateLayout(animation: .scaleXY)
```

#### 3. 3D折叠动画 (threeDFold)
- **描述**: 元素以3D旋转折叠的方式进入和退出，提供立体的视觉效果
- **进入效果**: 从折叠状态（3D旋转90度）展开到正常状态
- **退出效果**: 从正常状态折叠（3D旋转90度）并淡出
- **特点**:
  - 支持垂直和水平滚动方向
  - 根据索引位置（奇偶数）自动改变旋转方向
  - 添加遮罩效果增强立体感
  - 支持设置折叠时跳过的item（仅针对单Section有效）
- **适用场景**: 适合需要突出视觉效果的场景，如展开/折叠列表、删除操作等

```swift
// 基本使用
section.updateLayout(animation: .threeDFold)

// 设置折叠时跳过的item（仅单Section有效）
if let threeDFoldAnimation = ListReloadAnimation.threeDFold as? ThreeDFoldListReloadAnimation {
    threeDFoldAnimation.setSkipItems(items: itemsToSkip, at: section)
    section.updateLayout(animation: threeDFoldAnimation)
}
```

#### 4. 左滑动画 (leftSlide)
- **描述**: 元素从左侧滑入，向左侧滑出
- **进入效果**: 从左侧边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到左侧边界外
- **适用场景**: 适合列表项从左侧添加或删除的场景

```swift
section.updateLayout(animation: .leftSlide)
```

#### 5. 右滑动画 (rightSlide)
- **描述**: 元素从右侧滑入，向右侧滑出
- **进入效果**: 从右侧边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到右侧边界外
- **适用场景**: 适合列表项从右侧添加或删除的场景

```swift
section.updateLayout(animation: .rightSlide)
```

#### 6. 上滑动画 (topSlide)
- **描述**: 元素从上方滑入，向上方滑出
- **进入效果**: 从上方边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到上方边界外
- **适用场景**: 适合列表项从上方添加或删除的场景

```swift
section.updateLayout(animation: .topSlide)
```

#### 7. 下滑动画 (bottomSlide)
- **描述**: 元素从下方滑入，向下方滑出
- **进入效果**: 从下方边界外滑入到正常位置
- **退出效果**: 从正常位置滑出到下方边界外
- **适用场景**: 适合列表项从下方添加或删除的场景

```swift
section.updateLayout(animation: .bottomSlide)
```

#### 8. 位置变换动画 (transform)
- **描述**: 元素从旧位置移动到新位置
- **进入效果**: 从旧的位置属性渐变到新的位置属性
- **退出效果**: 使用渐隐动画
- **适用场景**: 适合列表项位置发生变化时的场景，如排序、重新排列等

```swift
section.updateLayout(animation: .transform)
```

### 动画组合

QuickList 支持将多个动画组合在一起，创造出更丰富的动画效果。支持组合的动画类型包括：
- `fade` (淡入淡出)
- `scaleX` / `scaleY` / `scaleXY` (缩放)
- `transform` (位置变换)

#### 组合动画的工作原理

组合动画通过 `ConcatenateListReloadAnimation` 实现，它将多个实现了 `ConcatenateAnimationType` 协议的动画串联在一起：

1. **进入动画前** (`beforeIn`): 所有动画的 `beforeIn` 方法会依次执行，用于设置初始状态
2. **进入动画中** (`afterIn`): 所有动画的 `afterIn` 方法会在同一个 UIView 动画块中执行，创建复合效果
3. **退出动画** (`outSnapshotAnimation`): 所有动画的退出效果会依次应用到截图上

#### 使用方法

##### 方法1: 使用 concatenate 方法链式组合

```swift
// 组合淡入淡出和缩放动画
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: combinedAnimation)

// 组合多个动画
let multiAnimation = ListReloadAnimation.transform
    .concatenate(with: ListReloadAnimation.scaleXY)
    .concatenate(with: ListReloadAnimation.fade)
section.updateLayout(animation: multiAnimation)
```

##### 方法2: 使用 ConcatenateListReloadAnimation 初始化

```swift
// 直接创建组合动画
let combinedAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.fade,
    ListReloadAnimation.scaleXY
])
section.updateLayout(animation: combinedAnimation)

// 组合位置变换和缩放动画
let transformScaleAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.transform,
    ListReloadAnimation.scaleX
])
section.updateLayout(animation: transformScaleAnimation)
```

##### 方法3: 动态添加动画

```swift
let combinedAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.fade
])
// 动态添加更多动画
combinedAnimation.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: combinedAnimation)
```

#### 组合动画示例

##### 示例1: 淡入+缩放组合

```swift
// 元素先设置缩放为0，然后同时进行淡入和缩放展开
let fadeScaleAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: fadeScaleAnimation)
```

##### 示例2: 位置变换+缩放组合

```swift
// 元素从旧位置移动到新位置，同时进行缩放展开
let transformScaleAnimation = ListReloadAnimation.transform.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: transformScaleAnimation)
```

##### 示例3: 自定义时长

```swift
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
combinedAnimation.duration = 0.5  // 设置组合动画的时长
section.updateLayout(animation: combinedAnimation)
```

#### 注意事项

1. **支持的类型**: 只有实现了 `ConcatenateAnimationType` 协议的动画才能进行组合，目前支持 `fade`、`scaleX/Y/XY` 和 `transform`
2. **执行顺序**: `beforeIn` 按顺序执行，`afterIn` 在同一个动画块中执行（会同时生效），`outSnapshotAnimation` 按顺序应用到截图
3. **性能考虑**: 组合多个动画会增加计算量，建议合理控制组合数量
4. **兼容性**: 可以与单独使用动画的方式混合使用

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
    outAnimation: .scaleXY  // 退出动画
)
```

### 使用示例

#### 基本使用
```swift
// 使用淡入淡出动画更新布局
section.updateLayout(animation: .fade)

// 使用缩放动画更新布局
section.updateLayout(animation: .scaleXY)

// 使用3D折叠动画更新布局
section.updateLayout(animation: .threeDFold)

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
    outAnimation: .scaleXY   // 旧元素缩放退出
)
```

### 注意事项

1. **性能考虑**: 复杂的动画可能会影响性能，建议在大量数据更新时使用简单的动画。3D折叠动画使用CATransform3D和遮罩层，相比基础动画消耗更多资源，建议在适当场景使用
2. **用户体验**: 动画时长不宜过长，建议保持在 0.2-0.5 秒之间
3. **兼容性**: 所有动画都基于 UIView 和 Core Animation 的动画系统，兼容性良好
4. **自定义**: 可以通过继承 `ListReloadAnimation` 类来创建自定义动画效果
5. **3D折叠动画**: 
   - 需要正确设置 `setSkipItems` 方法以支持折叠时跳过特定item的功能（仅单Section有效）
   - 动画会根据列表的滚动方向（垂直/水平）自动调整折叠方向
   - 奇偶索引的item会呈现不同的旋转方向，以增强视觉效果

### 自定义动画

如果需要创建自定义动画，可以继承 `ListReloadAnimation` 类：

```swift
class CustomListReloadAnimation: ListReloadAnimation {
    override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        // 自定义进入动画逻辑
        view.alpha = 0
        view.transform = CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: duration) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    override func animateOut(view: UIView, to item: Item?, at section: Section) {
        // 自定义退出动画逻辑
        addOutSnapshotAndDoAnimation(view: view, at: section) { snapshot in
            snapshot.alpha = 0
            snapshot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
}
```
