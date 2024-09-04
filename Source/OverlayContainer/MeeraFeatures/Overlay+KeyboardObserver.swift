import UIKit

extension OverlayContainerViewController {
    internal func setupKeyboardObserver() {
        kbObserver.observe { [weak self] event in
            guard 
                let self = self,
                let keyboardPolicy = configuration.overlayKeyboardPolicy()
            else {
                return
            }

            switch event.type {
            case .willShow:
                guard !self.isBeingDismissed else {
                    return
                }

                switch keyboardPolicy {
                case .switchToLongForm:
                    self.moveOverlay(toNotchAt: configuration.maximumNotchIndex, animated: true)
                    self.keyboardHeight = -(event.keyboardFrameEnd.height)
                case let .switchToLongFormWithPinndedView(additionOffset):
                    self.moveOverlay(toNotchAt: configuration.maximumNotchIndex, animated: true)
                    self.keyboardHeight = -(event.keyboardFrameEnd.height + additionOffset)
                    self.finalBottomContraintValue = self.keyboardHeight
                case .ignore:
                    break
                }
            case .willHide:
                if case .switchToLongFormWithPinndedView = keyboardPolicy {
                    self.keyboardHeight = 0
                    self.finalBottomContraintValue = self.keyboardHeight
                    self.updatePinnedViewConstraints(nil)
                }
            case .didHide, .didShow, .willChangeFrame, .didChangeFrame:
                break
            }
        }
    }

    internal func hideKeyboardIfNeeded(forNotch index: Int) {
        guard let keyboardPolicy = configuration.overlayKeyboardPolicy() else {
            return
        }

        let shouldHide = configuration.heightForNotch(at: index) < -keyboardHeight
        switch keyboardPolicy {
        case .switchToLongForm,
            .switchToLongFormWithPinndedView:
            if shouldHide { view.endEditing(true) }
        case .ignore:
            break
        }
    }
}
