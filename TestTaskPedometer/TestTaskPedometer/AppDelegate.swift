//
//  AppDelegate.swift
//  TestTaskPedometer
//
//  Created by 1 on 12.10.18.
//  Copyright © 2018 Bogdan Magala. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var defaults = UserDefaults.standard
    
    var VC = PedometerViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let pedometerViewController = window?.rootViewController as? PedometerViewController{
            pedometerViewController.modelController = ModelController()
        }
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let stepsScreen = window?.rootViewController as? PedometerViewController {
            let dataBase = Firestore.firestore()
            let settings = dataBase.settings
            settings.areTimestampsInSnapshotsEnabled = true
            dataBase.settings = settings
            let dataDict = stepsScreen.modelController.model.resDict
            //print(dataDict)
//          let dataDict = defaults.dictionary(forKey: "dateAndStepsDictionary")
            print("\(dataDict) + APPDELEGATE")
            dataBase.collection("stepsCount").document("result").setData(dataDict)
        }
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

