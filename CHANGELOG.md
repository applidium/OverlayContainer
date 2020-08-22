## 3.5.1 (22 August 2020)

### Fixed

- Issue [71](https://github.com/applidium/OverlayContainer/issues/71)
- Issue [72](https://github.com/applidium/OverlayContainer/issues/72)

## 3.5.0 (07 August 2020)

### Added

- `OverlayContainerPresentationController`: An abstract class that can be used to manage the transition animations and the presentation of overlay containers onscreen.
- `OverlayContainerSheetPresentationController`: An `OverlayContainerPresentationController` subclass that adds a dimming layer over the background content and a drag-to-dismiss & tap-to-dismiss gestures.

### Updated

- The overlay container view autorizing mask is now [.flexibleHeight, .flexibleWidth]

## 3.5.0-beta.1 (10 April 2020)

### Added

- `OverlayContainerPresentationController`: An abstract class that can be used to manage the transition animations and the presentation of overlay containers onscreen.
- `OverlayContainerSheetPresentationController`: An `OverlayContainerPresentationController` subclass that adds a dimming layer over the background content and a drag-to-dismiss & tap-to-dismiss gestures.

## 3.4.1 (6 April 2020)

- Avoid view loading when setting delegate

## 3.4.0 (30 March 2020)

- Add `availableSpace` property
- Fix #49: Lay out the view before animating the view

## 3.3.1 (23 March 2020)

- Mark delegate as weak

## 3.3.0 (09 March 2020)

- `OverlayContainer` class is now open
- `PassThroughView` class is now open

## 3.2.1 (10 January 2020)

- The status bar style derives from the overlay controller

## 3.2.0 (28 October 2019)

- Swift Package Manager support

## 3.1.0 (28 August 2019)

- Support Swift 4.2 & 5
- Merge PR #34
- Use cocoapods 1.7 podspec format

## 3.0.0-a (15 June 2019)

- All the translations are now deferred to the next layout pass. The translations can now be scheduled right after the initialization of the container. 
Furthermore the layout will not break if the container move the overlay or invalidate its notch heights in response to a size change.
- `SpringOverlayTranslationAnimationController` almost nullifies its damping value when the container has a rigid style to avoid the panel 
to be lifted above the bottom of the screen when an animated transition occurs.
- New overlay style `expandableHeight`
- New delegate tracking API: `willTranslateOverlay`, `didMoveOverlay`, `willMoveOverlay`, `willEndDraggingOverlay`, `willStartDraggingOverlay`
- `invalidateNotchHeight` uses the target notch policy to determine where to go by default

## 2.0.2 (3 May 2019)

- Use Cocoapods 1.6.1

## 2.0.0 (11 April 2019)

- Add `canReachNotchAt` to disable or enable notches on the fly
- OverlayContainer now uses the last view controller of its viewControllers as the overlay view controller. It stacks the other view controllers on top of each other, if any, and adds them underneath the overlay view controller.
- Handle a new edge case: the overlay container has only one notch

## 1.3.0 (04 April 2019)

- Add completion block to `moveOverlay`

## 1.2.0 (27 March 2019)

- Hide `UIViewController+Children` methods

## 1.1.2 (27 March 2019)

- Fix Xcode 10.2 compilation (Nimble & Quick update)
- Hide Carthage test dependancies

## 1.1.1 (27 February 2019)

- Fix the cleaning of the translation drivers when a new driving scroll view is set.

## 1.1.0 (25 February 2019)

- Add ability to invalidate the current height of the overlay notches

## 1.0.4 (30 January 2019)

- Add Carthage support

## 1.0.3 (14 January 2019)

- Fix ability to change response within SpringAnimation 

## 1.0.2 (21 December 2018)

- Fix scrolling edge cases
- Add unit tests

## 1.0.1 (21 December 2018)

- Remove initial velocity consideration in `SpringOverlayTranslationAnimationController` (Issue #3)

## 1.0.0 (5 December 2018)

First release
