//
//  OverlayViewController.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 12/11/2018.
//

import UIKit

public class OverlayContainerViewController: UIViewController {

    public var delegate: OverlayContainerViewControllerDelegate? {
        set {
            configuration.delegate = newValue
            needsOverlayContainerHeightUpdate = true
        }
        get {
            return configuration.delegate
        }
    }

    public var viewControllers: [UIViewController] = [] {
        didSet {
            guard isViewLoaded else { return }
            oldValue.forEach { removeChild($0) }
            loadOverlayViews()
        }
    }

    public var topViewController: UIViewController? {
        return viewControllers.last
    }

    private lazy var overlayPanGesture: OverlayTranslationGestureRecognizer = self.makePanGesture()
    private lazy var overlayContainerView = OverlayContainerView()
    private lazy var overlayTranslationView = OverlayTranslationView()
    private var overlayContainerViewHeightConstraint: NSLayoutConstraint?
    private var translationHeightConstraint: NSLayoutConstraint?

    private lazy var configuration: OverlayContainerViewControllerConfiguration = self.makeConfiguration()

    private var needsOverlayContainerHeightUpdate = true {
        didSet {
            view.setNeedsLayout()
        }
    }

    private var previousSize: CGSize = .zero
    private var translationController: HeightContrainstOverlayTranslationController?
    private var translationDrivers: [OverlayTranslationDriver] = []

    // MARK: - UIViewController

    public override func loadView() {
        view = PassThroughView()
        loadTranslationViews()
        loadOverlayViews()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpPanGesture()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard needsOverlayContainerHeightUpdate else { return }
        needsOverlayContainerHeightUpdate = true
        updateOverlayConstraints(forNew: view.bounds.size)
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateOverlayConstraints(forNew: size)
        }, completion: nil)
    }

    // MARK: - Public

    public func moveOverlay(toNotchAt index: Int, animated: Bool) {
        view.layoutIfNeeded()
        translationController?.moveOverlay(toNotchAt: index, velocity: .zero, animated: animated)
    }

    // MARK: - Private

    private func loadTranslationViews() {
        view.addSubview(overlayTranslationView)
        overlayTranslationView.addSubview(overlayContainerView)
        overlayTranslationView.pinToSuperview(edges: [.bottom, .left, .right])
        overlayContainerView.pinToSuperview(edges: [.left, .top, .right])
        translationHeightConstraint = overlayTranslationView.heightAnchor.constraint(equalToConstant: 0)
        translationHeightConstraint?.isActive = true
        overlayContainerViewHeightConstraint = overlayContainerView.heightAnchor.constraint(equalToConstant: 0)
        overlayContainerViewHeightConstraint?.isActive = true
    }

    private func updateOverlayConstraints(forNew size: CGSize) {
        guard let controller = translationController, previousSize != size else {
            return
        }
        previousSize = size
        configuration.reloadNotchHeights()
        overlayContainerViewHeightConstraint?.constant = configuration.maximumNotchHeight
        controller.moveOverlay(toNotchAt: controller.translationEndNotchIndex, velocity: .zero, animated: false)
    }

    private func loadOverlayViews() {
        viewControllers.forEach { addChild($0, in: overlayContainerView) }
        loadTranslationDrivers()
    }

    private func loadTranslationDrivers() {
        guard let translationHeightConstraint = translationHeightConstraint,
            let overlayController = topViewController else {
            return
        }
        let controller = HeightContrainstOverlayTranslationController(
            translationHeightConstraint: translationHeightConstraint,
            overlayViewController: overlayController,
            configuration: configuration
        )
        controller.delegate = self
        var drivers: [OverlayTranslationDriver] = []
        let panGestureDriver = PanGestureOverlayTranslationDriver(
            translationController: controller,
            panGestureRecognizer: overlayPanGesture
        )
        drivers.append(panGestureDriver)
        if let scrollView = configuration.scrollView(drivingOverlay: overlayController) {
            let driver = ScrollViewOverlayTranslationDriver(
                translationController: controller,
                scrollView: scrollView
            )
            drivers.append(driver)
        }
        translationDrivers = drivers
        translationController = controller
    }

    private func setUpPanGesture() {
        view.addGestureRecognizer(overlayPanGesture)
    }
    private func makeConfiguration() -> OverlayContainerViewControllerConfiguration {
        return OverlayContainerViewControllerConfiguration(overlayContainerViewController: self)
    }

    private func makePanGesture() -> OverlayTranslationGestureRecognizer {
        return OverlayTranslationGestureRecognizer()
    }
}

extension OverlayContainerViewController: OverlayTranslationControllerDelegate {

    // MARK: - HeightContrainstOverlayTranslationControllerDelegate

    func translationController(_ translationController: OverlayTranslationController,
                               didDragOverlayToHeight height: CGFloat) {
        guard let controller = topViewController else { return }
        delegate?.overlayContainerViewController(self, didDragOverlay: controller, toHeight: height)
    }

    func translationController(_ translationController: OverlayTranslationController,
                               willReachNotchAt index: Int,
                               transitionCoordinator: OverlayContainerTransitionCoordinator) {
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
        }, completion: { _ in })
        delegate?.overlayContainerViewController(
            self,
            willEndReachingNotchAt: index,
            transitionCoordinator: transitionCoordinator
        )
    }
}
