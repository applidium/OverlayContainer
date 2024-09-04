//
//  File.swift
//  
//
//  Created by Евгений Гульков on 04.09.2024.
//

import UIKit

public final class ExternalOverlayScrollViewDelegate {
	weak var delegate: OverlayScrollViewDelegate?
	
	public init() {}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		delegate?.overlayScrollViewDidScroll(scrollView)
	}

	public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
								   withVelocity velocity: CGPoint,
								   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		delegate?.overlayScrollView(
			scrollView,
			willEndDraggingwithVelocity: velocity.multiply(by: -1000),
			targetContentOffset: targetContentOffset
		)
	}

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		delegate?.overlayScrollViewWillBeginDragging(scrollView)
	}
}
