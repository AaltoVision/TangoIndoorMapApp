//
//  AppDelegate.swift
//  TangoIndoorMapApp
//
//  Created by Park Seyoung on 14/11/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import UIKit
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let mapDataSharedInstance: MapData = MapData.sharedInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let console = ConsoleDestination()  // log to Xcode Console
        log.addDestination(console)
        
//        var keys: NSDictionary?
//        
//        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
//            keys = NSDictionary(contentsOfFile: path)
//        }
//        if let dict = keys {
//            let applicationId = dict["parseApplicationId"] as? String
//            let clientKey = dict["parseClientKey"] as? String
//            
//            // Initialize Parse.
//                
//            .setApplicationId(applicationId!, clientKey: clientKey!)
//        }
        
        /// Load main view
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        // Set Background Color of window
        window?.backgroundColor = UIColor.white
        
        // Allocate memory for an instance of the 'MainViewController' class
        let mainViewController = MapViewController()
        
        // Set the root view controller of the app's window
        window!.rootViewController = mainViewController
        
        // Make the window visible
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

