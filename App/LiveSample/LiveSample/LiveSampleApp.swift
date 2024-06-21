//
//  LiveSampleApp.swift
//  LiveSample
//
//  Created by 鈴木登也 on 2024/02/04.
//

import SwiftUI
import ComposableArchitecture
import Root
import RootStore
import Routing
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct LiveSampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var loginChecker = LoginChecker()
    @StateObject var accountTypeChecker = AccountTypeChecker()
    
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: Root.State()) {
                        Root()
                    }
            )
            .environmentObject(loginChecker)
            .environmentObject(accountTypeChecker)
        }
    }
}
