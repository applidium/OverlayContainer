//
//  RubberBandOverlayTranslationFunction.swift
//  OverlayContainer
//
//  Created by Gaétan Zanella on 29/11/2018.
//

import Foundation

public class RubberBandOverlayTranslationFunction: OverlayTranslationFunction {

    public var factor: CGFloat = 0.5
    public var bouncesAtMaximumHeight = true
    public var bouncesAtMinimumHeight = true

    // MARK: - OverlayTranslationFunction

    public func overlayTranslationHeight(using context: OverlayTranslationParameters) -> CGFloat {
        if context.translation > context.maximumHeight && bouncesAtMaximumHeight {
            return logarithmicTranslation(translation: context.translation, limit: context.maximumHeight)
        }
        if context.translation < context.minimumHeight && bouncesAtMinimumHeight {
            let translation = context.minimumHeight + (context.minimumHeight - context.translation)
            let height = logarithmicTranslation(translation: translation, limit: context.minimumHeight)
            return context.minimumHeight - (height - context.minimumHeight)
        }
        return max(context.minimumHeight, min(context.translation, context.maximumHeight))
    }

    // MARK: - Private

    private func logarithmicTranslation(translation: CGFloat, limit: CGFloat) -> CGFloat {
        return limit * (1 + factor * log10(translation / limit))
    }
}
