import UIKit

extension OverlayContainerViewController {
    internal func loadOverlayPinnedView() {
        guard let pinnedViewConfig = configuration.overlayPinnedViewConfig(),
            let _pinnedView = pinnedViewConfig.pinnedView else {
            return
        }

        let pinnedViewContainer = PassThroughView()
        overlayTranslationContainerView.addSubview(pinnedViewContainer)
        pinnedViewContainer.pinToSuperview(with: .zero , edges: [.left, .right, .top])

        pinnedViewBottomConstraint = pinnedViewContainer.bottomAnchor.constraint(
            equalTo: overlayTranslationContainerView.bottomAnchor
        )
        pinnedViewBottomConstraint?.isActive = true

        _pinnedView.backgroundColor = .yellow
        self.pinnedView = pinnedViewContainer

        switch pinnedViewConfig.safeAreaPolicy {
        case .ignore:
            switch pinnedViewConfig.constraintsMode {
            case .set(let insets, let edges, let height, let width):
                pinnedViewContainer.addSubview(_pinnedView)
                _pinnedView.translatesAutoresizingMaskIntoConstraints = false
                _pinnedView.pinToSuperview(with: insets, edges: edges)
                if let height {
                    _pinnedView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
                if let width {
                    _pinnedView.widthAnchor.constraint(equalToConstant: width).isActive = true
                }
            case .getExisting:
                // задержка чтобы получить parent у pinnedView
                DispatchQueue.main.async {
                    self.adjustPinnedIfNeeded(
                        pinnedView: _pinnedView,
                        container: pinnedViewContainer,
                        pinBottomToSafeArea: false
                    )
                }
            }



        case .constrainAndHighlight(let color):
            let safeAreaView = UIView()
            safeAreaView.backgroundColor = color
            pinnedViewContainer.addSubview(safeAreaView)

            safeAreaView.translatesAutoresizingMaskIntoConstraints = false
            safeAreaView.pinToSuperview(edges: [.left, .right, .bottom])

            // задержка чтобы получить значение safe area
            DispatchQueue.main.async {
                safeAreaView.heightAnchor.constraint(equalToConstant: self.view.safeAreaInsets.bottom).isActive = true
            }

            switch pinnedViewConfig.constraintsMode {
            case .set(let insets, let edges, let height, let width):
                pinnedViewContainer.addSubview(_pinnedView)
                _pinnedView.translatesAutoresizingMaskIntoConstraints = false
                _pinnedView.pinToSuperview(with: insets, edges: edges)
                if let height {
                    _pinnedView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
                if let width {
                    _pinnedView.widthAnchor.constraint(equalToConstant: width).isActive = true
                }
                _pinnedView.bottomAnchor.constraint(
                    equalTo: pinnedViewContainer.safeAreaLayoutGuide.bottomAnchor,
                    constant: insets.bottom
                ).isActive = true
            case .getExisting:
                // задержка чтобы получить parent у pinnedView
                DispatchQueue.main.async {
                    self.adjustPinnedIfNeeded(
                        pinnedView: _pinnedView,
                        container: pinnedViewContainer,
                        pinBottomToSafeArea: true
                    )
                }
            }
        }
    }

    internal func updatePinnedViewConstraints(_ context: OverlayContainerTransitionCoordinatorContext?) {
        guard let pinnedViewConfig = configuration.overlayPinnedViewConfig() else {
            return
        }

        guard let context else {
            baseAnimation { [weak self] in
                guard let self else { return }
                self.pinnedViewBottomConstraint?.constant = self.finalBottomContraintValue
                self.pinnedViewBottomConstraint?.isActive = true
                self.pinnedView?.layoutIfNeeded()
            }
            return
        }

        var minHeight = context.minimumHeight()
        if let heightToStartMoveDown = pinnedViewConfig.heightToStartMoveDown {
            minHeight = heightToStartMoveDown
        }
        let diff = context.overlayTranslationHeight - (minHeight + -finalBottomContraintValue)
/*
        debugPrint("\n")
        debugPrint("context.overlayTranslationHeight \(context.overlayTranslationHeight)")
        debugPrint("context.minimumHeight \(minHeight)")
        debugPrint("finalBottomContraintValue) \(finalBottomContraintValue)")
        debugPrint("minHeight + -finalBottomContraintValue \(minHeight + -finalBottomContraintValue)")
        debugPrint("diff \(diff)")
*/
        if diff < 0 {
            pinnedViewBottomConstraint?.constant = finalBottomContraintValue - diff
            pinnedViewBottomConstraint?.isActive = true
        }
    }

    private func adjustPinnedIfNeeded(pinnedView: UIView, container: UIView, pinBottomToSafeArea: Bool) {
        guard let pinnedParent = pinnedView.superview else {
            return
        }

        let pinnedConstraints = pinnedParent.constraints.filter({
            $0.firstItem as? UIView == pinnedView
        })

        var newConstraints: [NSLayoutConstraint] = pinnedConstraints.map({
            let constraint = NSLayoutConstraint(
                item: $0.firstItem as Any,
                attribute: $0.firstAttribute,
                relatedBy: $0.relation,
                toItem: pinBottomToSafeArea && $0.firstAttribute == .bottom
                ? container.safeAreaLayoutGuide
                : container,
                attribute: $0.secondAttribute,
                multiplier: $0.multiplier,
                constant: $0.constant
            )
            if constraint.firstAttribute == .bottom {
                self.pinnedViewBottomConstraint = constraint
                constraint.priority = .defaultHigh
            }
            return constraint
        })

        newConstraints.append(
            .init(
                item: pinnedView,
                attribute: .top,
                relatedBy: .greaterThanOrEqual,
                toItem: container,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ))

        pinnedView.removeFromSuperview()
        container.addSubview(pinnedView)
        NSLayoutConstraint.activate(newConstraints)
    }
}
