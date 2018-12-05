# OverlayContainer

[![Version](https://img.shields.io/cocoapods/v/OverlayContainer.svg?style=flat)](https://cocoapods.org/pods/OverlayContainer)
[![License](https://img.shields.io/cocoapods/l/OverlayContainer.svg?style=flat)](https://cocoapods.org/pods/OverlayContainer)
[![Platform](https://img.shields.io/cocoapods/p/OverlayContainer.svg?style=flat)](https://cocoapods.org/pods/OverlayContainer)

OverlayContainer is a UI library written in Swift. It makes it easier to develop overlay based interfaces, such as the one presented in the Apple Maps, Stocks or Shortcuts apps.

![scroll](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scroll.gif)

___

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
- [Usage](#usage)
  - [Setup](#mininim-setup)
  - [Overlay style](#overlay-style)
  - [Scroll view support](#scroll-view-support)
  - [Pan gesture support](#pan-gesture-support)
  - [Examples](#examples)
- [Advanced Usage](#advanced-usage)
  - [Backdrop view](#backdrop-usage)
  - [Safe Area](#safe-area)
  - [Custom Translation](#custom-translation)
  - [Custom Translation Animations](#custom-translation-animations)
- [Author](#author)
- [License](#license)

## Features

- [x] Unlimited notches
- [x] Adapts to any custom layouts
- [x] Fluid transitions between scroll & translation : it perfectly mimics the overlay presented in the Shotcuts app
- [x] Includes a rubber band effect
- [x] Animations and target notch policy fully customizable

## Requirements

OverlayContainer is written in Swift 4.2. Compatible with iOS 10.0+.

## Installation

OverlayContainer is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

### Cocoapods

```ruby
pod 'OverlayContainer'
```

## Usage

### Setup

The main component of the library is the `OverlayContainerViewController`. It defines an area where a view controller can be dragged up and down, hidding or revealing the content underneath it. 

Thus, your first step is to create a custom view controller container which combines the `OverlayContainerViewController` and the content you wish to overlay.
It could be as simple as a view controller stacking all its children :

```swift
class StackViewController: UIViewController {

    var viewControllers: [UIViewController] = [] {
        didSet {
            guard isViewLoaded else { return }
            loadChildren()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChildren()
    }

    private func loadChildren() {
        viewControllers.forEach { addChild($0, in: view) }
    }
}
```

A startup sequence might look like this :

```swift
let mapsController = MapsViewController()
let searchController = SearchViewController()

let containerController = OverlayContainerViewController()
containerController.delegate = self
containerController.viewControllers = [searchController]

let stackController = StackViewController()
stackController.viewControllers = [
    mapsController,
    containerController
]
window?.rootViewController = stackController

```

The last step is to define the overlay's notches. By default, the overlay container view controller does not display anything. 
Implement `OverlayContainerViewControllerDelegate` to specify the number of notches wished :


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

The overlay style defines how the overlay view controllers will be constrained in the `OverlayContainerViewController`.

```swift
enum OverlayStyle {
    case flexibleHeight // default
    case rigid
}

let overlayContainer = OverlayContainerViewController(style: .rigid)
```

* flexibleHeight

![flexibleHeight](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/flexibleHeight.gif)

The overlay view controller will not be height-constrained. It will grow and shrink as the user drags it up and down.

It is specifically designed for overlays containing scroll views. **Be careful to always provide a minimum height higher than the intrinsic content of your overlay.**

* rigid

![rigid](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/rigid.gif)

The overlay view controller will be constrained with a height equal to the highest notch. The overlay won't be fully visible until the user drags it up to this notch.

### Scroll view support

The container view controller can coordinate the scrolling of a scroll view with the overlay translation.

![scrollToTranslation](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scrollToTranslation.gif)

Use the associated delegate method :

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
    return (overlayViewController as? DetailViewController)?.tableView
}
```

Or directly set the container property :

```swift
let containerController = OverlayContainerViewController()
containerController.drivingScrollView = myScrollView
```

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

### Examples

* Maps Like: A custom layout which adapts its hierachy on rotations.

![Maps](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/maps.gif)

* Shortcuts: A custom layout which adapts its hierachy on trait collection changes : Moving from a `UISplitViewController` on regular environment to a simple `StackViewController` on compact environment. Visualize it on iPad Pro.

![Shortcuts](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/shortcuts.gif)

## Advanced usage

### Backdrop view

Coordinate the overlay movements to the aspect of a view using the dedicated delegate methods. See the [backdrop view example](https://github.com/applidium/ADOverlayContainer/blob/master/Example/OverlayContainer/BackdropExampleViewController.swift).

![backdrop](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/backdropView.gif)

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didDragOverlay overlayViewController: UIViewController,
                                        toHeight height: CGFloat,
                                        availableSpace: CGFloat) {
        backdropView.alpha = // compute alpha based on height
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        didEndDraggingOverlay overlayViewController: UIViewController,
                                        transitionCoordinator: OverlayContainerTransitionCoordinator) {
        backdropView.alpha = // compute alpha based on the transitionCoordinator
        transitionCoordinator.animate(alongsideTransition: { context in
            self.backdropView.alpha =  // compute the final alpha value on the transitionCoordinator
        }, completion: nil)
    }
```

### Safe Area

Be careful when using safe areas. As described in the [WWDC "UIKit: Apps for Every Size and Shape" video](https://masterer.apple.com/videos/play/wwdc2018-235/?time=328), the safe area insets will not be updated if your views exceeds the screen bounds. This is specially the case when using the `OverlayStyle.flexibleHeight`.

The simpliest way to handle the safe area correctly is to compute your notch heights using the `safeAreaInsets` provided by the container and avoid the `safeAreaLayoutGuide` bottom anchor in your overlay :

```
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
The associated target notch policy `RushingForwardTargetNotchPolicy` will always try to go forward is the user's finger reachs a certain velocity. It might also decide to skip some notches if the user goes too fast.

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

## Author

gaetanzanella, gaetan.zanella@fabernovel.com

## License

OverlayContainer is available under the MIT license. See the LICENSE file for more info.
