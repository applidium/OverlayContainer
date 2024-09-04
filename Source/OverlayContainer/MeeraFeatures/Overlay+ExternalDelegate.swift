//
//  File.swift
//  
//
//  Created by Евгений Гульков on 04.09.2024.
//

import UIKit

extension OverlayContainerViewController {
	public func setExternalScrollViewDelegate(
		delegate: ExternalOverlayScrollViewDelegate,
		for scrollView: UIScrollView
	) {
		guard delegate !== self.externalScrollViewDelegate else { return }
		guard isViewLoaded else { return }
		self.externalScrollViewDelegate = delegate
		self.drivingScrollView = scrollView
		loadTranslationDrivers()
	}
}
