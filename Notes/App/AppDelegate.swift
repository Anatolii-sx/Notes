//
//  AppDelegate.swift
//  Notes
//
//  Created by Анатолий Миронов on 02.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let isFirstAppLaunch = UserDefaults.standard.value(forKey: "isFirstAppLaunch") as? Bool, isFirstAppLaunch == true else {
            UserDefaults.standard.set(true, forKey: "isFirstAppLaunch")
            StorageManager.shared.save("Моя первая заметка", completion: nil)
            return true
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        StorageManager.shared.saveContext()
    }
}

