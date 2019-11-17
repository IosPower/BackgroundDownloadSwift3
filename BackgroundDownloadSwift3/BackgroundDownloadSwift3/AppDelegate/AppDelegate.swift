//
//  AppDelegate.swift
//  BackgroundDownloadSwift3
//
//  Created by piyush sinroja on 17/04/17.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var isGrantedNotificationAccess:Bool = false
    let requestIdentifier = "SampleRequest"
    var window: UIWindow?
    var strTitle = NSString()

    var backgroundSessionCompletionHandler: (() -> Void)?
    let completionHandler = [String: ()-> Void]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupRechablity()
        if(UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    self.isGrantedNotificationAccess = granted
            })
        } else {
           
        }
        
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
    
    // MARK: - Background Method
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK: - setupRechablity
    func setupRechablity() {
        Constant.reachability = Reachability.init()
        
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: Constant.reachability)
        
        NotificationCenter.default.addObserver(self,selector: #selector(AppDelegate.reachabilityChanged), name: ReachabilityChangedNotification, object: Constant.reachability)
        
        do { try Constant.reachability!.startNotifier()
        } catch { print("cant access") }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                Constant.isOnWiFi = true
            } else {
                print("Reachable via Cellular")
                Constant.isOnWiFi = false
            }
            Constant.isReachable = true
        } else {
            print("Not reachable")
            Constant.isReachable = false
            Constant.isOnWiFi = false
        }
    }

    func localNotification() {
        if #available(iOS 10.0, *) {
            if isGrantedNotificationAccess {
                let content = UNMutableNotificationContent()
                print(strTitle)
                content.title = strTitle as String //"Local Notification Swift3"
                content.subtitle = "Video Details"
                content.body = "Download Complete"
                content.sound = UNNotificationSound.default
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval:0.5, repeats: false)
                
                //Set the request for the notification from the above
                let request = UNNotificationRequest(
                    identifier: requestIdentifier,
                    content: content,
                    trigger: trigger
                )
                UNUserNotificationCenter.current().delegate = self
                //Add the notification to the currnet notification center
                var center = UNUserNotificationCenter.current()
                center = customButton(center: center)
                center.add(request) { (error) in
                    print(error ?? "")
                }
                
                print("should have been added")
            }
        } else {
           
            let localNotification = UILocalNotification()
            localNotification.alertBody = "Download Complete!"
            localNotification.alertAction = "Background Transfer Download!"
            //On sound
            localNotification.soundName = UILocalNotificationDefaultSoundName
            //increase the badge number of application plus 1
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            UIApplication.shared.presentLocalNotificationNow(localNotification)
            let notification = UILocalNotification()
            let oneMinuteFromNow = Date().addingTimeInterval(5)
            notification.fireDate = oneMinuteFromNow
            notification.alertBody = "24 hours passed since last visit :("
            //[[UIApplication sharedApplication] scheduleLocalNotification:notification];
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
    
    @available(iOS 10.0, *)
    func customButton(center:UNUserNotificationCenter)-> UNUserNotificationCenter {
        // Swift
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "UYLDeleteAction",
                                                title: "Delete", options: [.destructive])
        // Swift
        let category = UNNotificationCategory(identifier: "UYLReminderCategory",
                                              actions: [snoozeAction,deleteAction],
                                              intentIdentifiers: [], options: [])
        // Swift
        center.setNotificationCategories([category])
        return center
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        if response.notification.request.identifier == requestIdentifier {
            print("Tapped in notification")
            print(response)
        }
        print(response.notification.request.content.badge ?? "")
        completionHandler()
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        if notification.request.identifier == requestIdentifier {
            completionHandler( [.alert,.sound,.badge])
        }
    }
}

