//
//  OverlayTranslationView.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 14/11/2018.
//

import UIKit

class OverlayTranslationView: PassThroughView {
    override var alignmentRectInsets: UIEdgeInsets {
        .init(top: 20, left: 0, bottom: 0, right: 0)
    }
}
