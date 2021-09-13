
<H4 align="center">
  OverlayContainer is a UI library written in Swift. It makes easier to develop overlay based interfaces, such as the one presented in the Apple Maps, Stocks or Shortcuts apps
</H4>

<p align="center">
  <a href="https://developer.apple.com/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"/></a>
  <a href="https://developer.apple.com/swift"><img alt="Swift4" src="https://img.shields.io/badge/language-Swift%204.2-orange.svg"/></a>
  <a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift%205.0-orange.svg"/></a>
  <a href="https://cocoapods.org/pods/OverlayContainer"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/OverlayContainer.svg?style=flat"/></a>
  <a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
  <a href="https://github.com/applidium/OverlayContainer/actions"><img alt="Build Status" src="https://github.com/applidium/OverlayContainer/workflows/CI/badge.svg?branch=master"/></a>
  <a href="https://github.com/applidium/ADOverlayContainer/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/cocoapods/l/OverlayContainer.svg?style=flat"/></a>
</p>

---

> ⚠️ In iOS 15, consider using [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller) before `OverlayContainer`

---

`OverlayContainer` tries to be as lightweight and non-intrusive as possible. The layout and the UI customization are done by you to avoid to corrupt your project. 

It perfectly mimics the overlay presented in the Siri Shotcuts app. See [this article](https://gaetanzanella.github.io//2018/replicate-apple-maps-overlay/) for details.

- [x] Unlimited notches
- [x] Notches modifiable at runtime
- [x] Adaptive to any custom layouts
- [x] Rubber band effect
- [x] Animations and target notch policy fully customizable
- [x] Unit tested

See the provided examples for help or feel free to ask directly.

---

<p align="center">
<img src="https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scroll.gif" width="222">
</p>

---

- [Usage](#usage)
  - [Setup](#setup)
  - [Overlay style](#overlay-style)
  - [Scroll view support](#scroll-view-support)
  - [Pan gesture support](#pan-gesture-support)
  - [Tracking the overlay](#tracking-the-overlay)
  - [Examples](#examples)
- [Advanced Usage](#advanced-usage)
  - [Multiple overlays](#multiple-overlays)
  - [Presenting an overlay container](#presenting-an-overlay-container)
  - [Enabling & disabling notches](#enabling--disabling-notches)
  - [Backdrop view](#backdrop-view)
  - [Safe Area issues](#safe-area-issues)
  - [Custom Translation](#custom-translation)
  - [Custom Translation Animations](#custom-translation-animations)
  - [Reloading the notches](#reloading-the-notches)
- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
  - [Swift Package Manager](#swift-package-manager)
- [SwiftUI](#swiftui)
- [Author](#author)
- [License](#license)

## Usage

### Setup

The main component of the library is the `OverlayContainerViewController`. It defines an area where a view controller, called the overlay view controller, can be dragged up and down, hiding or revealing the content underneath it.

`OverlayContainer` uses the last view controller of its `viewControllers` as the overlay view controller. It stacks the other view controllers on top of each other, if any, and adds them underneath the overlay view controller.

A startup sequence might look like this:

```swift
let mapsController = MapsViewController()
let searchController = SearchViewController()

let containerController = OverlayContainerViewController()
containerController.delegate = self
containerController.viewControllers = [
    mapsController,
    searchController
]

window?.rootViewController = containerController
```

Specifing only one view controller is absolutely valid. For instance, in [MapsLikeViewController](https://github.com/applidium/OverlayContainer/blob/master/Example/OverlayContainer_Example/Maps/MapsLikeViewController.swift) the overlay only covers partially its content.

The overlay container view controller needs at least one notch. Implement `OverlayContainerViewControllerDelegate` to specify the number of notches wished:

```swift
enum OverlayNotch: Int, CaseIterable {
    case minimum, medium, maximum
}

func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
    return OverlayNotch.allCases.count
}

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    switch OverlayNotch.allCases[index] {
        case .maximum:
            return availableSpace * 3 / 4
        case .medium:
            return availableSpace / 2
        case .minimum:
            return availableSpace * 1 / 4
    }
}
```

### Overlay style

The overlay style defines how the overlay view controller will be constrained in the `OverlayContainerViewController`.

```swift
enum OverlayStyle {
    case flexibleHeight
    case rigid
    case expandableHeight // default
}

let overlayContainer = OverlayContainerViewController(style: .rigid)
```

* rigid

![rigid](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/rigid.gif)

The overlay view controller will be constrained with a height equal to the highest notch. The overlay won't be fully visible until the user drags it up to this notch.

* flexibleHeight

![flexible](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/flexible.gif)

The overlay view controller will not be height-constrained. It will grow and shrink as the user drags it up and down.

Note though that while the user is dragging the overlay, the overlay's view may perform some extra layout computations. This is specially true for the table views or the collection views : some cells may be dequeued or removed when its frame changes. Try `.rigid` if you encounter performance issues.

**Be careful to always provide a minimum height higher than the intrinsic content of your overlay.**

* expandableHeight

![expandable](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/expandable.gif)

The overlay view controller will be constrained with a height greater or equal to the highest notch. Its height will be expanded if the overlay goes beyond the highest notch (it could happen if the translation function or the animation controller allow it).

### Scroll view support

The container view controller can coordinate the scrolling of a scroll view with the overlay translation.

![scrollToTranslation](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scrollToTranslation.gif)

Use the dedicated delegate method:

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
    return (overlayViewController as? DetailViewController)?.tableView
}
```

Or directly set the dedicated property:

```swift
let containerController = OverlayContainerViewController()
containerController.drivingScrollView = myScrollView
```

Make sure to set `UIScrollView.alwaysBounceVertical` to `true` so the scroll view will always scroll regardless of its content size.

### Pan gesture support

The container view controller detects pan gestures on its own view.
Use the dedicated delegate method to check that the specified starting pan gesture location corresponds to a grabbable view in your custom overlay.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    shouldStartDraggingOverlay overlayViewController: UIViewController,
                                    at point: CGPoint,
                                    in coordinateSpace: UICoordinateSpace) -> Bool {
    guard let header = (overlayViewController as? DetailViewController)?.header else {
        return false
    }
    let convertedPoint = coordinateSpace.convert(point, to: header)
    return header.bounds.contains(convertedPoint)
}
```

### Tracking the overlay

You can track the overlay motions using the dedicated delegate methods:

- Translation Start

Tells the delegate when the user is about to start dragging the overlay view controller.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    willStartDraggingOverlay overlayViewController: UIViewController)
```

- Translation End

Tells the delegate when the user finishs dragging the overlay view controller with the specified velocity.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    willEndDraggingOverlay overlayViewController: UIViewController,
                                    atVelocity velocity: CGPoint)
```

- Translation In Progress

Tells the delegate when the container is about to move the overlay view controller to the specified notch.

In some cases, the overlay view controller may not successfully reach the specified notch.
If the user cancels the translation for instance. Use `overlayContainerViewController(_:didMove:toNotchAt:)` if you need to be notified each time the translation succeeds.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    willMoveOverlay overlayViewController: UIViewController,
                                    toNotchAt index: Int)
```

Tells the delegate when the container has moved the overlay view controller to the specified notch.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    didMoveOverlay overlayViewController: UIViewController,
                                    toNotchAt index: Int)
```

Tells the delegate whenever the overlay view controller is about to be translated.

The delegate typically implements this method to coordinate changes alongside the overlay view controller's translation.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    willTranslateOverlay overlayViewController: UIViewController,
                                    transitionCoordinator: OverlayContainerTransitionCoordinator)
```

The `transition coordinator` provides information about the translation that is about to start:

```swift
/// A Boolean value that indicates whether the user is current dragging the overlay.
var isDragging: Bool { get }

/// The overlay velocity.
var velocity: CGPoint { get }

/// The current translation height.
var overlayTranslationHeight: CGFloat { get }

/// The notch indexes.
var notchIndexes: Range<Int> { get }

/// The reachable indexes. Some indexes might be disabled by the `canReachNotchAt` delegate method.
var reachableIndexes: [Int] { get }

/// Returns the height of the specified notch.
func height(forNotchAt index: Int) -> CGFloat

/// A Boolean value indicating whether the transition is explicitly animated.
var isAnimated: Bool { get }

/// A Boolean value indicating whether the transition was cancelled.
var isCancelled: Bool { get }

/// The overlay height the container expects to reach.
var targetTranslationHeight: CGFloat { get }
```
and allows you to add animations alongside it:

```swift
transitionCoordinator.animate(alongsideTransition: { context in
    // ...
}, completion: nil)
```

### Examples

To test the examples, open `OverlayContainer.xcworkspace` and run the `OverlayContainer_Example` target.

Choose the layout you wish to display in the `AppDelegate`:

* MapsLikeViewController: A custom layout which adapts its hierachy on rotations.

![Maps](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/maps.gif)

* ShortcutsLikeViewController: A custom layout which adapts its hierachy on trait collection changes: Moving from a `UISplitViewController` on regular environment to a simple `StackViewController` on compact environment. Visualize it on an iPad Pro.

![Shortcuts](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/shortcuts.gif)

## Advanced usage

### Multiple overlays

`OverlayContainer` does not provide a built-in view controller navigation management. It focuses its effort on the overlay translation.

However in the project, there is an example of a basic solution to overlay multiple overlays on top of each other, like in the `Apple Maps` app. It is based on an `UINavigationController` and a custom implementation of its delegate:

```swift
// MARK: - UINavigationControllerDelegate

func navigationController(_ navigationController: UINavigationController,
                          animationControllerFor operation: UINavigationController.Operation,
                          from fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return OverlayNavigationAnimationController(operation: operation)
}

func navigationController(_ navigationController: UINavigationController,
                          didShow viewController: UIViewController,
                          animated: Bool) {
    overlayController.drivingScrollView = (viewController as? SearchViewController)?.tableView
}
```

`OverlayNavigationAnimationController` tweaks the native behavior of the `UINavigationController`: it slides the pushed view controllers up from the bottom of the screen. Feel free to add shadows and modify the animation curve depending on your needs. The only restriction is that you can not push an `UINavigationController` inside another `UINavigationController`.

### Presenting an overlay container

The translation of an overlay view controller can be coupled with the presentation state of its container. Subclass `OverlayContainerPresentationController` to be notified any time an overlay translation occurs in the presented content or use the built-in `OverlayContainerSheetPresentationController` class.

A frequent use case is to reproduce the presentation style of an `UIActivityViewController`. [ActivityControllerPresentationLikeViewController](https://github.com/applidium/OverlayContainer/blob/master/Example/OverlayContainer_Example/Present%20Overlay/ActivityControllerPresentationLikeViewController.swift) provides a basic implementation of it:

```swift
func displayActivityLikeViewController() {
    let container = OverlayContainerViewController()
    container.viewControllers = [MyActivityViewController()]
    container.transitioningDelegate = self
    container.modalPresentationStyle = .custom
    present(container, animated: true, completion: nil)
}

// MARK: - UIViewControllerTransitioningDelegate

func presentationController(forPresented presented: UIViewController,
                            presenting: UIViewController?,
                            source: UIViewController) -> UIPresentationController? {
    return OverlayContainerSheetPresentationController(
        presentedViewController: presented,
        presenting: presenting
    )
}
```

If the user taps the background content or drags the overlay down fastly, the container controller will be automatically dismissed.

### Enabling & disabling notches

`OverlayContainer` provides a easy way to enable & disable notches on the fly. A frequent use case is to show & hide the overlay. [ShowOverlayExampleViewController](https://github.com/applidium/OverlayContainer/blob/master/Example/OverlayContainer_Example/Disable%20Notch/ShowOverlayExampleViewController.swift) provides a basic implementation of it:

```swift
var showsOverlay = false

func showOrHideOverlay() {
    showsOverlay.toggle()
    let targetNotch: Notch = showsOverlay ? .med : .hidden
    overlayContainerController.moveOverlay(toNotchAt: targetNotch.rawValue, animated: true)
}

// MARK: - OverlayContainerViewControllerDelegate

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    switch Notch.allCases[index] {
    case .max:
        return ...
    case .med:
        return ...
    case .hidden:
        return 0
    }
}

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    canReachNotchAt index: Int,
                                    forOverlay overlayViewController: UIViewController) -> Bool {
    switch Notch.allCases[index] {
    case .max:
        return showsOverlay
    case .med:
        return showsOverlay
    case .hidden:
        return !showsOverlay
    }
}
```

Make sure to use the `rigid` overlay style if the content can not be flattened.

### Backdrop view

Coordinate the overlay movements to the aspect of a view using the dedicated delegate methods. See the [backdrop view example](https://github.com/applidium/OverlayContainer/blob/master/Example/OverlayContainer_Example/Backdrop/BackdropExampleViewController.swift).

![backdrop](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/backdropView.gif)

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    willTranslateOverlay overlayViewController: UIViewController,
                                    transitionCoordinator: OverlayContainerTransitionCoordinator) {
    transitionCoordinator.animate(alongsideTransition: { [weak self] context in
        self?.backdropViewController.view.alpha = context.translationProgress()
    }, completion: nil)
}
```

### Safe Area issues

Be careful when using safe areas. As described in the [WWDC "UIKit: Apps for Every Size and Shape" video](https://masterer.apple.com/videos/play/wwdc2018-235/?time=328), the safe area insets will not be updated if your views exceeds the screen bounds. This is specially the case when using the `OverlayStyle.expandableHeight`: when the overlay exceeds the bottom screen limit, its safe area will not be updated.

The simpliest way to handle the safe area correctly is to compute your notch heights using the `safeAreaInsets` of the container and avoid the `safeAreaLayoutGuide` use in your overlay view:

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    let bottomInset = containerViewController.view.safeAreaInsets.bottom
    switch OverlayNotch.allCases[index] {

        // ...

        case .minimum:
            return bottomInset + 100
    }
}
```

If you depend on `UIKit` native components that do not ignore the safe area like a `UINavigationBar`, use the `OverlayStyle.flexibleHeight` style.

### Custom Translation

Adopt `OverlayTranslationFunction` to modify the relation between the user's finger translation and the actual overlay translation.

By default, the overlay container uses a `RubberBandOverlayTranslationFunction` that provides a rubber band effect.

![rubberBand](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/rubberBand.gif)

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction? {
    let function = RubberBandOverlayTranslationFunction()
    function.factor = 0.7
    function.bouncesAtMinimumHeight = false
    return function
}
```

### Custom Translation Animations

Adopt `OverlayTranslationTargetNotchPolicy` & `OverlayAnimatedTransitioning` protocols to define where the overlay should go once the user's touch is released and how to animate the translation.

By default, the overlay container uses a `SpringOverlayTranslationAnimationController` that mimics the behavior of a spring.
The associated target notch policy `RushingForwardTargetNotchPolicy` will always try to go forward if the user's finger reachs a certain velocity. It might also decide to skip some notches if the user goes too fast.

Tweak the provided implementations or implement our own objects to modify the overlay translation behavior.

![animations](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/animations.gif)

```swift

func overlayTargetNotchPolicy(for overlayViewController: UIViewController) -> OverlayTranslationTargetNotchPolicy? {
    let policy = RushingForwardTargetNotchPolicy()
    policy.minimumVelocity = 0
    return policy
}

func animationController(for overlayViewController: UIViewController) -> OverlayAnimatedTransitioning? {
    let controller = SpringOverlayTranslationAnimationController()
    controller.damping = 0.2
    return controller
}
```

### Reloading the notches

You can reload all the data that is used to construct the notches using the dedicated method:

```swift
func invalidateNotchHeights()
```

This method does not reload the notch heights immediately. It only clears the current container's state. Because the number of notches may change, the container will use its target notch policy to determine where to go.
Call `moveOverlay(toNotchAt:animated:)` to override this behavior.

## Requirements

OverlayContainer is written in Swift 5. Compatible with iOS 10.0+.

## Installation

OverlayContainer is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

### Cocoapods

```ruby
pod 'OverlayContainer'
```

### Carthage

Add the following to your Cartfile:

```ruby
github "https://github.com/applidium/OverlayContainer"
```

### Swift Package Manager

OverlayContainer can be installed as a Swift Package with Xcode 11 or higher. To install it, add a package using Xcode or a dependency to your Package.swift file:

```swift
.package(url: "https://github.com/applidium/OverlayContainer.git", from: "3.4.0")
```


## SwiftUI

See [DynamicOverlay](https://github.com/faberNovel/DynamicOverlay)

## Author

[@gaetanzanella](https://twitter.com/gaetanzanella), gaetan.zanella@fabernovel.com

## License

OverlayContainer is available under the MIT license. See the LICENSE file for more info.
