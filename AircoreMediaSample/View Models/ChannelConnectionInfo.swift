//
//  ChannelConnectionInfo.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/11/22.
//

import Foundation

private extension String {
  static let channelIDKey = "channelID"
  static let userIDKey = "userID"
}

public struct ChannelConnectionInfo {
  var channelID: String
  var userID: String

  init() {
    channelID = UserDefaults.standard.string(forKey: .channelIDKey) ?? ""
    userID = UserDefaults.standard.string(forKey: .userIDKey) ?? ""
  }

  public func saveToDefaults() {
    UserDefaults.standard.set(channelID, forKey: .channelIDKey)
    UserDefaults.standard.set(userID, forKey: .userIDKey)
  }
}
