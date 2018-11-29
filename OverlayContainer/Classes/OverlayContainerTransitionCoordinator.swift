//
//  OverlayAnimationCoordinator.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 14/11/2018.
//

import Foundation

public protocol OverlayContainerTransitionCoordinatorContext {
    var targetNotchIndex: Int { get }
    var targetNotchHeight: CGFloat { get }
    var overlayTranslationHeight: CGFloat { get }
}

public protocol OverlayContainerTransitionCoordinator {
    func animate(alongsideTransition animation: @escaping (OverlayContainerTransitionCoordinatorContext) -> Void,
                 completion: @escaping (OverlayContainerTransitionCoordinatorContext) -> Void) 
}
