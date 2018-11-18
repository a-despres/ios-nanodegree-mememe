//
//  AppDelegate.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/3/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes = [Meme]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let reef = UIColor(red: 7/255, green: 153/255, blue: 146/255, alpha: 1)
        let grey = UIColor(red: 220/255, green: 221/255, blue: 225/255, alpha: 1)
        let white = UIColor.white
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = reef
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .regular)]
        navigationBarAppearance.tintColor = white

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = white
        tabBarAppearance.tintColor = reef
        tabBarAppearance.unselectedItemTintColor = grey
        
        let toolbarAppearance = UIToolbar.appearance()
        toolbarAppearance.barTintColor = UIColor.white
        toolbarAppearance.tintColor = reef
        return true
    }
}
