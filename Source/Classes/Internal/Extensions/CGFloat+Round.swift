//
//  CGFloat+Round.swift
//  FluxTire
//
//  Created by Gaétan Zanella on 17/10/2018.
//

import Foundation

extension CGFloat {
    func oc_rounded(_ rule: FloatingPointRoundingRule = .down, toDecimals decimals: Int = 2) -> CGFloat {
        let multiplier = CGFloat(10 ^ decimals)
        return (self * multiplier).rounded(.down) / multiplier
    }
}
