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
