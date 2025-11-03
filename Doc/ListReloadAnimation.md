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

#### 2. Scale Animation (scaleX / scaleY / scaleXY)
- **Description**: Elements enter and exit with scaling, supports independent control of X-axis or Y-axis scaling
- **Types**:
  - `scaleX`: Scale only on X-axis
  - `scaleY`: Scale only on Y-axis
  - `scaleXY`: Scale on both X-axis and Y-axis (default)
- **Enter Effect**: Scale from 0x to 1x
- **Exit Effect**: Scale from 1x to 0.01x
- **Use Case**: Suitable for scenarios that need to highlight new content

```swift
// X-axis scaling
section.updateLayout(animation: .scaleX)

// Y-axis scaling
section.updateLayout(animation: .scaleY)

// Both X-axis and Y-axis scaling
section.updateLayout(animation: .scaleXY)
```

#### 3. 3D Fold Animation (threeDFold)
- **Description**: Elements enter and exit with 3D rotation folding, providing a three-dimensional visual effect
- **Enter Effect**: Unfold from folded state (3D rotation 90 degrees) to normal state
- **Exit Effect**: Fold from normal state (3D rotation 90 degrees) and fade out
- **Features**:
  - Supports both vertical and horizontal scroll directions
  - Automatically changes rotation direction based on index position (odd/even)
  - Adds mask effect to enhance three-dimensional appearance
  - Supports setting items to skip during folding (only effective for single section)
- **Use Case**: Suitable for scenarios that need prominent visual effects, such as expand/collapse lists, delete operations, etc.

```swift
// Basic usage
section.updateLayout(animation: .threeDFold)

// Set items to skip during folding (only effective for single section)
if let threeDFoldAnimation = ListReloadAnimation.threeDFold as? ThreeDFoldListReloadAnimation {
    threeDFoldAnimation.setSkipItems(items: itemsToSkip, at: section)
    section.updateLayout(animation: threeDFoldAnimation)
}
```

#### 4. Left Slide Animation (leftSlide)
- **Description**: Elements slide in from the left and slide out to the left
- **Enter Effect**: Slide in from outside the left boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the left boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the left

```swift
section.updateLayout(animation: .leftSlide)
```

#### 5. Right Slide Animation (rightSlide)
- **Description**: Elements slide in from the right and slide out to the right
- **Enter Effect**: Slide in from outside the right boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the right boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the right

```swift
section.updateLayout(animation: .rightSlide)
```

#### 6. Top Slide Animation (topSlide)
- **Description**: Elements slide in from the top and slide out to the top
- **Enter Effect**: Slide in from outside the top boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the top boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the top

```swift
section.updateLayout(animation: .topSlide)
```

#### 7. Bottom Slide Animation (bottomSlide)
- **Description**: Elements slide in from the bottom and slide out to the bottom
- **Enter Effect**: Slide in from outside the bottom boundary to normal position
- **Exit Effect**: Slide out from normal position to outside the bottom boundary
- **Use Case**: Suitable for scenarios where list items are added or removed from the bottom

```swift
section.updateLayout(animation: .bottomSlide)
```

#### 8. Transform Animation (transform)
- **Description**: Elements move from old position to new position
- **Enter Effect**: Transition from old position attributes to new position attributes
- **Exit Effect**: Uses fade animation
- **Use Case**: Suitable for scenarios where list item positions change, such as sorting or reordering

```swift
section.updateLayout(animation: .transform)
```

### Animation Combination

QuickList supports combining multiple animations together to create richer animation effects. Supported animation types for combination include:
- `fade` (fade in/out)
- `scaleX` / `scaleY` / `scaleXY` (scale)
- `transform` (position transform)

#### How Combined Animations Work

Combined animations are implemented through `ConcatenateListReloadAnimation`, which chains multiple animations that conform to the `ConcatenateAnimationType` protocol:

1. **Before Enter Animation** (`beforeIn`): All animations' `beforeIn` methods execute sequentially to set initial states
2. **During Enter Animation** (`afterIn`): All animations' `afterIn` methods execute within the same UIView animation block to create composite effects
3. **Exit Animation** (`outSnapshotAnimation`): All exit effects are applied sequentially to the snapshot

#### Usage Methods

##### Method 1: Chain Combination with concatenate

```swift
// Combine fade and scale animations
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: combinedAnimation)

// Combine multiple animations
let multiAnimation = ListReloadAnimation.transform
    .concatenate(with: ListReloadAnimation.scaleXY)
    .concatenate(with: ListReloadAnimation.fade)
section.updateLayout(animation: multiAnimation)
```

##### Method 2: Initialize with ConcatenateListReloadAnimation

```swift
// Directly create combined animation
let combinedAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.fade,
    ListReloadAnimation.scaleXY
])
section.updateLayout(animation: combinedAnimation)

// Combine position transform and scale animations
let transformScaleAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.transform,
    ListReloadAnimation.scaleX
])
section.updateLayout(animation: transformScaleAnimation)
```

##### Method 3: Dynamically Add Animations

```swift
let combinedAnimation = ConcatenateListReloadAnimation(animations: [
    ListReloadAnimation.fade
])
// Dynamically add more animations
combinedAnimation.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: combinedAnimation)
```

#### Combined Animation Examples

##### Example 1: Fade + Scale Combination

```swift
// Element first scales to 0, then simultaneously fades in and scales up
let fadeScaleAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: fadeScaleAnimation)
```

##### Example 2: Transform + Scale Combination

```swift
// Element moves from old position to new position while scaling up
let transformScaleAnimation = ListReloadAnimation.transform.concatenate(with: ListReloadAnimation.scaleXY)
section.updateLayout(animation: transformScaleAnimation)
```

##### Example 3: Custom Duration

```swift
let combinedAnimation = ListReloadAnimation.fade.concatenate(with: ListReloadAnimation.scaleXY)
combinedAnimation.duration = 0.5  // Set combined animation duration
section.updateLayout(animation: combinedAnimation)
```

#### Notes

1. **Supported Types**: Only animations that implement the `ConcatenateAnimationType` protocol can be combined. Currently supports `fade`, `scaleX/Y/XY`, and `transform`
2. **Execution Order**: `beforeIn` executes sequentially, `afterIn` executes in the same animation block (takes effect simultaneously), `outSnapshotAnimation` applies sequentially to the snapshot
3. **Performance Considerations**: Combining multiple animations increases computational load, recommend controlling combination count reasonably
4. **Compatibility**: Can be mixed with single animation usage

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
    outAnimation: .scaleXY  // Exit animation
)
```

### Usage Examples

#### Basic Usage
```swift
// Update layout with fade animation
section.updateLayout(animation: .fade)

// Update layout with scale animation
section.updateLayout(animation: .scaleXY)

// Update layout with 3D fold animation
section.updateLayout(animation: .threeDFold)

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
    outAnimation: .scaleXY   // Old elements scale out
)
```

### Notes

1. **Performance Considerations**: Complex animations may affect performance, recommend using simple animations for large data updates. 3D fold animation uses CATransform3D and mask layers, consuming more resources than basic animations, recommend using in appropriate scenarios
2. **User Experience**: Animation duration should not be too long, recommend keeping it between 0.2-0.5 seconds
3. **Compatibility**: All animations are based on UIView and Core Animation systems with good compatibility
4. **Customization**: Custom animation effects can be created by inheriting from `ListReloadAnimation` class
5. **3D Fold Animation**: 
   - Need to properly set the `setSkipItems` method to support skipping specific items during folding (only effective for single section)
   - Animation automatically adjusts fold direction based on list scroll direction (vertical/horizontal)
   - Items with odd/even indices will show different rotation directions to enhance visual effects

### Custom Animations

If you need to create custom animations, you can inherit from the `ListReloadAnimation` class:

```swift
class CustomListReloadAnimation: ListReloadAnimation {
    override func animateIn(view: UIView, to item: Item?, at section: Section, lastAttributes: UICollectionViewLayoutAttributes?, targetAttributes: UICollectionViewLayoutAttributes?) {
        // Custom enter animation logic
        view.alpha = 0
        view.transform = CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: duration) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    override func animateOut(view: UIView, to item: Item?, at section: Section) {
        // Custom exit animation logic
        addOutSnapshotAndDoAnimation(view: view, at: section) { snapshot in
            snapshot.alpha = 0
            snapshot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
}
```
