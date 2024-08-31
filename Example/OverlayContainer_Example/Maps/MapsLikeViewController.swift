//
//  MapsLikeViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 30/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import OverlayContainer
import UIKit

class MapsLikeViewController: UIViewController {

	enum OverlayNotch: Int, CaseIterable {
		case minimum, medium, maximum
	}

	@IBOutlet var overlayContainerView: UIView!
	@IBOutlet var backgroundView: UIView!

	@IBOutlet private var widthConstraint: NSLayoutConstraint!
	@IBOutlet private var trailingConstraint: NSLayoutConstraint!


	weak var underlyingNC: UINavigationController?
	weak var overlay: OverlayContainerViewController?

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		let overlayController = OverlayContainerViewController()
		overlay = overlayController
		let searchController = SearchViewController(showsCloseAction: false)
		searchController.delegate = self
		let nc = UINavigationController(rootViewController: searchController)
		underlyingNC = nc
		overlayController.delegate = self
		overlayController.viewControllers = [nc]
		addChild(overlayController, in: overlayContainerView)
		addChild(MapsViewController(), in: backgroundView)

		searchController.onTapHandler = { [weak overlayController] in
			overlayController?.moveOverlay(toNotchAt: Bool.random() ? 1 : 2, animated: true)
		}
	}

	override func viewWillLayoutSubviews() {
		setUpConstraints(for: view.bounds.size)
		super.viewWillLayoutSubviews()
	}

	// MARK: - Private

	private func setUpConstraints(for size: CGSize) {
		if size.width > size.height {
			trailingConstraint.isActive = false
			widthConstraint.isActive = true
		} else {
			trailingConstraint.isActive = true
			widthConstraint.isActive = false
		}
	}

	private func notchHeight(for notch: OverlayNotch, availableSpace: CGFloat) -> CGFloat {
		switch notch {
		case .maximum:
			return availableSpace * 3 / 4
		case .medium:
			return availableSpace * 2 / 4
		case .minimum:
			return availableSpace * 1 / 4
		}
	}
}

extension MapsLikeViewController: OverlayContainerViewControllerDelegate {

	// MARK: - OverlayContainerViewControllerDelegate

	func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
		return OverlayNotch.allCases.count
	}


	func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
																			heightForNotchAt index: Int,
																			availableSpace: CGFloat) -> CGFloat {
		let notch = OverlayNotch.allCases[index]
		return notchHeight(for: notch, availableSpace: availableSpace)
	}

	func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
																			scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {

		return (self.underlyingNC?.viewControllers.first as? SearchViewController)?.tableView
	}

	func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
																			shouldStartDraggingOverlay overlayViewController: UIViewController,
																			at point: CGPoint,
																			in coordinateSpace: UICoordinateSpace) -> Bool {
		guard let header = (overlayViewController as? SearchViewController)?.header else {
			return false
		}
		let convertedPoint = coordinateSpace.convert(point, to: header)
		return header.bounds.contains(convertedPoint)
	}
}

extension MapsLikeViewController: SearchViewControllerDelegate {
	func searchViewControllerDidSelectARow(_ searchViewController: SearchViewController) {
		let vc = ColoredViewController()
		underlyingNC?.pushViewController(vc, animated: true)
		underlyingNC?.navigationBar.isHidden = false
		overlay?.moveOverlay(toNotchAt: 2, animated: true)
	}
	
	func searchViewControllerDidSelectCloseAction(_ searchViewController: SearchViewController) {
		//
	}
}
