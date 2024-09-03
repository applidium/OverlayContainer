import UIKit

/// Policy that defines how the view interacts with the safe area.
public enum SafeAreaPolicy {
    /// The view ignores the safe area, potentially overlapping it.
    case ignore

    /// The view is constrained to the safe area and the safe area is highlighted with a specified background color.
    /// - Parameter color: The color used to fill the safe area.
    case constrainAndHighlight(UIColor)
}
