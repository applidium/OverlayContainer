import UIKit

public struct OverlayPinnedViewConfig {
    /// Initializes a configuration for the overlay pinned view.
    /// - Parameters:
    ///   - pinnedView: The view that will be pinned above the controller.
    ///   - constraintsMode: Determines how constraints should be applied. Defaults to copying existing constraints from the parent view.
    ///   - heightToStartMoveDown: The height at which the pinned view starts to move down. If `nil`, minimum notch height will be used.
    ///   - safeAreaPolicy: Defines how the safe area should be handled when pinning the view. Defaults to constraining and highlighting the safe area with a white color.
    public init(
        pinnedView: UIView?,
        constraintsMode: PinnedViewConstraintsMode = .getExisting,
        heightToStartMoveDown: CGFloat? = nil,
        safeAreaPolicy: SafeAreaPolicy = .constrainAndHighlight(.white)
    ) {
        self.pinnedView = pinnedView
        self.constraintsMode = constraintsMode
        self.heightToStartMoveDown = heightToStartMoveDown
        self.safeAreaPolicy = safeAreaPolicy
    }

    /// The view that will be pinned above the controller.
    weak var pinnedView: UIView?

    /// Determines how constraints should be applied: by copying existing constraints from the parent view or by setting new constraints based on provided insets and dimensions.
    var constraintsMode: PinnedViewConstraintsMode

    /// The height at which the pinned view starts to move down. If `nil`, minimum notch height will be used.
    var heightToStartMoveDown: CGFloat?

    /// Defines how the safe area should be handled when pinning the view.
    var safeAreaPolicy: SafeAreaPolicy
}

public enum PinnedViewConstraintsMode {
    /// Constraints are inherited from the parent view. These constraints will be copied to the pinned view and then removed from the parent view.
    case getExisting

    /// Constraints are explicitly set using the provided insets, edges, height, and width parameters.
    /// - Parameters:
    ///   - insets: Insets to apply to the pinned view.
    ///   - edges: The edges of the pinned view to constrain.
    ///   - height: Optional height constraint for the pinned view.
    ///   - width: Optional width constraint for the pinned view.
    case set(insets: UIEdgeInsets = .zero, edges: UIRectEdge = .all, height: CGFloat? = nil, width: CGFloat? = nil)
}
