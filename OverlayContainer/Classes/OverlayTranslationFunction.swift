//
//  PassThroughView.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 14/11/2018.
//

import UIKit

public protocol OverlayTranslationParameters {
    var minimumHeight: CGFloat { get }
    var maximumHeight: CGFloat { get }
    var translation: CGFloat { get }
}

public protocol OverlayTranslationFunction {
    func overlayTranslationHeight(using context: OverlayTranslationParameters) -> CGFloat
}
