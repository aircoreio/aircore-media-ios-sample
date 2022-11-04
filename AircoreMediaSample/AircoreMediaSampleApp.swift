//
//  AircoreMediaSampleApp.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/9/22.
//

import Foundation
import SwiftUI

import AircoreMedia

@main
struct AircoreMediaSampleApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    // Set user agent and log dir path before any other Engine functionality is used
    Engine.sharedInstance.setUserAgent("my-sample-app")

    let logDirName = "AircoreMedia_Logs" // Name of directory we want to Aircore log files
    // Create path
    let logsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent(logDirName, isDirectory: true)
      .path

    // Verify path creation was successful
    guard let logDirPath = logsDirPath else {
      assertionFailure("Could not create string for logsDirPath")
      return true
    }

    // Create the directory based on the path
    do {
      try FileManager.default.createDirectory(atPath: logDirPath, withIntermediateDirectories: true)
    } catch {
      assertionFailure("Could not create directory at \(logDirPath)")
    }

    // Verify the directory has write permissions
    assert(FileManager.default.isWritableFile(atPath: logDirPath))
    // Set the path to the directory on the engine
    Engine.sharedInstance.setLogDirPath(logDirPath)
    return true
  }
}
