//
//  AppDelegate.swift
//  FinalProject
//
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

/*
 Icons:
 App Icon: https://thenounproject.com/term/conways-game-of-life/14951/
 Licence: Public Domain (https://creativecommons.org/publicdomain/zero/1.0/)
 
 Tab View Icons: https://icons8.com/web-app/for/all/design
 https://icons8.com/web-app/for/all/registry
 https://icons8.com/web-app/for/all/combo%20chart
 Licence: https://icons8.com/license/
 
 Reload Icon: https://www.iconfinder.com/icons/254190/refresh_reload_rotate_synchronize_icon#size=128
 Licence: https://creativecommons.org/licenses/by/3.0/
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

