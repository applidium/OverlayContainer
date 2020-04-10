//
//  AppDelegate.swift
//  OverlayContainer
//
//  Created by gaetanzanella on 11/12/2018.
//  Copyright (c) 2018 gaetanzanella. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ActivityControllerPresentationLikeViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
