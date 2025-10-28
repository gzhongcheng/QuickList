## List Reload Animation

QuickList provides various list reload animation effects for smooth visual transitions when list data is updated.

### Animation Types

#### 1. Fade Animation (fade)
- **Description**: Elements enter and exit with opacity changes
- **Enter Effect**: Fade from completely transparent to completely opaque
- **Exit Effect**: Fade from completely opaque to completely transparent
- **Use Case**: Suitable for most scenarios, provides smooth visual transitions

```swift
section.updateLayout(animation: .fade)
```

#### 2. Scale Animation (scale)
- **Description**: Elements enter and exit with scaling
- **Enter Effect**: Scale from 0x to 1x
- **Exit Effect**: Scale from 1x to 0.01x
- **Use Case**: Suitable for scenarios that need to highlight new content

```swift
section.updateLayout(animation: .scale)
```

#### 3. Left Slide Animation (leftSlide)
- **Description**: Elements slide in from the left and slide out to the left
- **Enter Effect**: Slide in from outside the left boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the left boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the left

```swift
section.updateLayout(animation: .leftSlide)
```

#### 4. Right Slide Animation (rightSlide)
- **Description**: Elements slide in from the right and slide out to the right
- **Enter Effect**: Slide in from outside the right boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the right boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the right

```swift
section.updateLayout(animation: .rightSlide)
```

#### 5. Top Slide Animation (topSlide)
- **Description**: Elements slide in from the top and slide out to the top
- **Enter Effect**: Slide in from outside the top boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the top boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the top

```swift
section.updateLayout(animation: .topSlide)
```

#### 6. Bottom Slide Animation (bottomSlide)
- **Description**: Elements slide in from the bottom and slide out to the bottom
- **Enter Effect**: Slide in from outside the bottom boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the bottom boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the bottom

```swift
section.updateLayout(animation: .bottomSlide)
```

#### 7. Transform Animation (transform)
- **Description**: Elements move from old position to new position
- **Enter Effect**: Transition from old position attributes to new position attributes
- **Exit Effect**: Uses fade animation
- **Use Case**: Suitable for scenarios where list item positions change, such as sorting or reordering

```swift
section.updateLayout(animation: .transform)
```

### Animation Configuration

#### Animation Duration
All animations support custom duration, default is 0.3 seconds:

```swift
let animation = ListReloadAnimation.fade
animation.duration = 0.5  // Set to 0.5 seconds
section.updateLayout(animation: animation)
```

#### Combined Usage
You can set both enter and exit animations:

```swift
section.updateLayout(
    inAnimation: .fade,      // Enter animation
    outAnimation: .scale     // Exit animation
)
```

### Usage Examples

#### Basic Usage
```swift
// Update layout with fade animation
section.updateLayout(animation: .fade)

// Update layout with scale animation
section.updateLayout(animation: .scale)

// Update layout with left slide animation
section.updateLayout(animation: .leftSlide)
```

#### Custom Animation Duration
```swift
let customAnimation = ListReloadAnimation.fade
customAnimation.duration = 0.6
section.updateLayout(animation: customAnimation)
```

#### Combined Animations
```swift
section.updateLayout(
    inAnimation: .fade,      // New elements fade in
    outAnimation: .scale     // Old elements scale out
)
```

### Notes

1. **Performance Considerations**: Complex animations may affect performance, recommend using simple animations for large data updates
2. **User Experience**: Animation duration should not be too long, recommend keeping it between 0.2-0.5 seconds
3. **Compatibility**: All animations are based on UIView's animation system with good compatibility
4. **Customization**: Custom animation effects can be created by inheriting from `ListReloadAnimation` class

### Custom Animations

If you need to create custom animations, you can inherit from the `ListReloadAnimation` class:

```swift
class CustomListReloadAnimation: ListReloadAnimation {
    override func animateIn(view: UIView, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        // Custom enter animation logic
        view.alpha = 0
        view.transform = CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: duration) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    override func animateOut(view: UIView) {
        // Custom exit animation logic
        addOutSnapshotAndDoAnimation(view: view) { snapshot in
            snapshot.alpha = 0
            snapshot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
}
```
