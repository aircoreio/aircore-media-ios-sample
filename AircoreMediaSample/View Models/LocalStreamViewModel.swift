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
  private var channelPublishers = Set<AnyCancellable>()
  var channelViewModel: ChannelViewModel? {
    didSet {
      channelPublishers.removeAll()

      guard let channelViewModel = channelViewModel else { return }

      // Respond to a new channel being created or destroyed.
      channelViewModel.$channel
        .sink { [weak self] channel in
          if channel == nil {
            self?.audioMuted = true
            self?.videoMuted = true
            self?.voiceActivity = false
          } else if channel?.localStream == nil {
            self?.cancellables.removeAll()
            self?.localStream = nil
            self?.setPropertiesFromLocalStream()
          }
        }
        .store(in: &channelPublishers)

      // Respond to a change in the channel's joinState
      channelViewModel.$joinState
        .sink { [weak self] state in
          // You can only create and join a LocalStream once the channel has been joined
          self?.channelJoined = state == .joined || state == .rejoining
        }
        .store(in: &channelPublishers)
    }
  }

  var videoSource: Camera?

  // Controls whether the LocalStream will publish video
  // If set to true, the `initialVideoMuteState` will be true on start and the `videoSource` will be set to nil
  // If false, `videoSource` will be set to a `Camera` instance
  @Published var audioOnly = false {
    didSet {
      // Setting the LocalStream's videoSource to nil automatically mutes video
      localStream?.videoSource = audioOnly ? nil : videoSource
    }
  }

  @Published var localStream: LocalStream?

  // LocalStream state values exposed to the View
  @Published private(set) var audioMuted: Bool = true
  @Published private(set) var videoMuted: Bool = true
  @Published private(set) var voiceActivity: Bool = false
  @Published private(set) var connectionState: String?
  @Published private(set) var terminationCause: String?
  @Published private(set) var channelJoined: Bool = false
  @Published private(set) var hasLocalStream: Bool = false

  public func toggleAudioMuted() {
    guard let localStream = localStream else { return }

    // Mute or unmute audio for the localStream
    localStream.muteAudio(!localStream.audioMuted)
  }

  public func toggleVideoMuted() {
    guard let localStream = localStream else { return }

    // Mute or unmute video for the localStream
    localStream.muteVideo(!localStream.videoMuted)
  }

  public func toggleStartStop() {
    // Stop or start the local stream depending on current state
    if localStream != nil {
      localStream?.stop()
      audioMuted = true
      videoMuted = true
      voiceActivity = false
    } else {
      // LocalStream can only be created once a Channel has been joined
      guard channelJoined else { return }

      let params = LocalStreamParams()
      params.initialAudioMute = false
      // `intialVideoMute` defaults to true, so set this to false only if you want
      // to create the stream with video enabled
      params.initialVideoMute = !audioOnly
      params.videoSource = audioOnly ? nil : videoSource
      localStream = channelViewModel?.channel?.createLocalStream(params: params)
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
      .filter { [weak self] in
        // guard to make sure we're acting only on the current localStream's notifications
        $0.object as? LocalStream == self?.localStream
      }
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.newConnectionState] as? LocalStream.ConnectionState }
      .sink { [weak self] state in
        self?.connectionState = state.description

        if state == .terminated {
          self?.terminationCause = self?.localStream?.terminationCause.description
          self?.localStream = nil
          self?.hasLocalStream = false
        }
      }.store(in: &cancellables)

    // LocalStreamNotification.audioMuteStateDidChange is posted when the LocalStream's audio mute state changes,
    // usually after calling muteAudio(_:)
    NotificationCenter.default.publisher(for: LocalStreamNotification.audioMuteStateDidChange, object: localStream)
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.audioMuted = muted
      }.store(in: &cancellables)

    // LocalStreamNotification.videoMuteStateDidChange is posted when the LocalStream's video mute state changes,
    // usually after calling muteVideo(_:)
    NotificationCenter.default.publisher(for: LocalStreamNotification.videoMuteStateDidChange, object: localStream)
      .compactMap { $0.userInfo?[LocalStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.videoMuted = muted
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
    audioMuted = localStream?.audioMuted ?? true
    videoMuted = localStream?.videoMuted ?? true
    voiceActivity = localStream?.voiceActivity ?? false
    connectionState = localStream?.connectionState.description
    terminationCause = localStream?.terminationCause.description
    hasLocalStream = localStream != nil
  }
}
