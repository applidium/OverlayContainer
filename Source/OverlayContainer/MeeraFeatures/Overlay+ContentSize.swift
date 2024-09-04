//
//  File.swift
//  
//
//  Created by Евгений Гульков on 04.09.2024.
//

import UIKit

extension OverlayContainerViewController {
	public func setContentMaxHeight(_ value: CGFloat?, animated: Bool) {
		contentMaxHeightConstraint?.constant = value ?? UIScreen.main.bounds.height + 100
		contentMaxHeightConstraint?.isActive = true
		
		if animated {
			baseAnimation {
				self.overlayContainerView.layoutIfNeeded()
			}
		}
	}
	
	public func changeSideInsets(
		left: CGFloat,
		right: CGFloat,
		animated: Bool
	) {
		leftInsetConstraint?.constant = -left
		rightInsetConstraint?.constant = right
		leftInsetConstraint?.isActive = true
		rightInsetConstraint?.isActive = true
		
		dashView.frame.origin.x = -left
		
		if animated {
			baseAnimation { [weak self] in
				self?.overlayTranslationView.layoutIfNeeded()
			}
		}
	}
	
	public func setContentHeight(
		height: CGFloat,
		animated: Bool
	) {
		overlayContainerViewStyleConstraint?.constant = height
		overlayContainerViewStyleConstraint?.isActive = true

		if animated {
			baseAnimation { [weak self] in
				self?.overlayTranslationView.layoutIfNeeded()
			}
		}
	}
	
	public func setTopInset(_ value: CGFloat, animated: Bool) {
		topInsetValue = value
		navControllerTopConstraint?.constant = value
		navControllerTopConstraint?.isActive = true
		
		if animated {
			baseAnimation {
				self.dashView.frame.size.height = value + 1
				self.overlayTranslationView.layoutIfNeeded()
			}
		} else {
			dashView.frame.size.height = value + 1
		}
		
		updateOverlayContainerConstraints()
	}
}
