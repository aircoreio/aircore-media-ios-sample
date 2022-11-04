//
//  LocalStreamViewModel.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import Foundation
import AircoreMedia
import Combine

public class LocalStreamViewModel: ObservableObject {
  var channel: ChannelViewModel?
  @Published var localStream: LocalStream?

  // LocalStream state values exposed to the View
  @Published private(set) var audioMuted: Bool?
  @Published private(set) var voiceActivity: Bool?
  @Published private(set) var connectionState: String?
  @Published private(set) var terminationCause: String?

  public func toggleAudioMuted() {
    guard let localStream = localStream else { return }

    // Mute or unmute the localStream locally
    localStream.muteAudio(!localStream.audioMuted)
  }

  public func toggleStartStop() {
    // Stop or start the local stream depending on current state
    if localStream != nil {
      localStream?.stop()
      audioMuted = nil
      voiceActivity = nil
    } else {
      localStream = channel?.channel?.createLocalStream()
      setupNotifications()
      setPropertiesFromLocalStream()
      localStream?.start()
    }
  }

  private var cancellables = Set<AnyCancellable>()

  private func setupNotifications() {
    cancellables.removeAll()

    // Set up Notification handlers with Combine using NotificationCenter.Publisher

    // LocalStreamNotification.connectionStateDidChange is posted when the LocalStream's connection state changes
    // e.g. from .connecting to .connected or from .connected to .terminated
    NotificationCenter.default.publisher(for: LocalStreamNotification.connectionStateDidChange, object: localStream)
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.newConnectionState] as? LocalStream.ConnectionState }
      .sink { [weak self] state in
        self?.connectionState = state.description

        if state == .terminated {
          self?.terminationCause = self?.localStream?.terminationCause.description
          self?.localStream = nil
        }
      }.store(in: &cancellables)

    // LocalStreamNotification.audioMuteStateDidChange is posted when the LocalStream's mute state changes,
    // usually after calling muteAudio(_:)
    NotificationCenter.default.publisher(for: LocalStreamNotification.audioMuteStateDidChange, object: localStream)
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.audioMuted = muted
      }.store(in: &cancellables)

    // LocalStreamNotification.voiceActivityStateDidChange is posted
    // when the LocalStream's voiceActivity property changes
    NotificationCenter.default.publisher(for: LocalStreamNotification.voiceActivityStateDidChange, object: localStream)
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.voiceActivity] as? Bool }
      .sink { [weak self] voiceActivity in
        self?.voiceActivity = voiceActivity
      }.store(in: &cancellables)
  }

  private func setPropertiesFromLocalStream() {
    audioMuted = localStream?.audioMuted
    voiceActivity = localStream?.voiceActivity
    connectionState = localStream?.connectionState.description
    terminationCause = localStream?.terminationCause.description
  }
}
