import UIKit

public enum KeyboardPolicy {
    case ignore
    case switchToLongForm
    case switchToLongFormWithPinndedView(_ additionOffset: CGFloat)
}
