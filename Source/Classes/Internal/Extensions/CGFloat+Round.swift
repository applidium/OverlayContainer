//
//  CGFloat+Round.swift
//  FluxTire
//
//  Created by Gaétan Zanella on 17/10/2018.
//

import Foundation

extension CGFloat {
    func oc_rounded(toDecimals decimals: Int = 2) -> CGFloat {
        let multiplier = CGFloat(pow(Double(10), Double(decimals)))
        return (self * multiplier).rounded() / multiplier
    }
}
