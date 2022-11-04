//
//  ChannelViewModel.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import Foundation
import AircoreMedia
import Combine

// A view model class for exposing Channel properties
public class ChannelViewModel: ObservableObject {
  // The Channel this view model represents
  @Published var channel: Channel?

  // Channel state values exposed to the View
  @Published private(set) var joinState: Channel.JoinState?
  @Published private(set) var terminationCause: Channel.TerminationCause?

  public var channelID: String {
    channel?.channelID ?? "None"
  }

  private var cancellables = Set<AnyCancellable>()

  // Join or leave a channel based on current state
  public func toggleJoinLeaveChannel(_ info: ChannelConnectionInfo) {
    if let channel = channel {
      channel.leave()
    } else {
      createAndJoinChannel(info)
    }
  }

  // Create and join a Channel with the given ChannelConnectionInfo using a PublishableAPIKey
  public func createAndJoinChannel(_ info: ChannelConnectionInfo) {
    // Enter your Publishable API Key here
    // This key is generated for your app on the AircoreMedia developer portal: https://developer.aircore.io/
    // If this key is not updated, you will not be able to join the Channel
    // and it will terminate with the `.publishableAPIKeyInvalid` termination cause.
    let publishableAPIKey = "pub_somePublishableAPI"
    channel = Engine.sharedInstance.createChannel(publishableAPIKey: publishableAPIKey,
                                                  userID: info.userID,
                                                  channelID: info.channelID)

    // Remove any existing subscriptions to previous channel notifications.
    cancellables.removeAll()

    // Set up Notification handlers with Combine using NotificationCenter.Publisher

    // ChannelNotification.joinStateDidChange is posted when the Channel changes state
    // e.g. from .joining to .joined or from .joined to .terminated
    NotificationCenter.default.publisher(for: ChannelNotification.joinStateDidChange, object: channel)
      .compactMap { $0.userInfo?[ChannelNotification.Key.newJoinState] as? Channel.JoinState }
      .sink { [weak self] state in
        guard let self = self else { return }
        self.joinState = state

        if state == .terminated {
          // Once a channel is terminated, we check the termination cause on the channel object itself
          self.terminationCause = self.channel?.terminationCause
          self.channel = nil
        }
      }.store(in: &cancellables)

    terminationCause = channel?.terminationCause
    channel?.join()
  }

  // Leave a Channel
  public func leave() {
    channel?.leave()
    // This will result in ChannelNotification.joinStateDidChange being posted with the `terminated` state.
    // We clean up this ChannelViewModel's state variables in that notification handler
  }
}
