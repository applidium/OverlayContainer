//
//  MasterViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 29/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import MapKit
import UIKit

class MasterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let map = MKMapView()
        view.addSubview(map)
        map.pinToSuperview()
    }
}
