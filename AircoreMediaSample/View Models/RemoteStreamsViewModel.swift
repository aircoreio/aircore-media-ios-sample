//
//  RemoteStreamsViewModel.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/16/22.
//

import Foundation
import AircoreMedia
import Combine

private extension RunLoop.SchedulerTimeType.Stride {
  static let fiveSeconds = Self.seconds(5)
}

// A view model class for the set of RemoteStream objects associated with a Channel
public class RemoteStreamsViewModel: ObservableObject {
  // The set of remote streams this view model represents
  @Published var remoteStreams = [RemoteStreamViewModel]()

  private var channelSubscriptions = Set<AnyCancellable>()
  private var channelSink: AnyCancellable?

  var channelViewModel: ChannelViewModel? {
    didSet {
      channelSink = channelViewModel?.$channel.sink { [weak self] channel in
        guard let self = self else { return }

        self.setupNotifications(channel)
        self.remoteStreams.removeAll()

        // Add any existing remote streams
        channel?.remoteStreams.forEach { self.remoteStreams.append(RemoteStreamViewModel(remoteStream: $0)) }
      }
    }
  }

  private func setupNotifications(_ channel: Channel?) {
    // Remove notifications from previously created channels
    channelSubscriptions.removeAll()

    // ChannelNotification.remoteStreamWasAdded is posted when a new RemoteStream is available on the Channel
    NotificationCenter.default.publisher(for: ChannelNotification.remoteStreamWasAdded, object: channel)
      .compactMap { $0.userInfo?[ChannelNotification.Key.remoteStream] as? RemoteStream }
      .sink { [weak self] stream in
        self?.remoteStreams.append(RemoteStreamViewModel(remoteStream: stream))
      }
      .store(in: &channelSubscriptions)

    // ChannelNotification.remoteStreamWasRemoved is posted when a RemoteStream is removed on the Channel.
    // The removed RemoteStream will have a RemoteStream.TerminationCause that explains the reason for removal.
    NotificationCenter.default.publisher(for: ChannelNotification.remoteStreamWasRemoved, object: channel)
      // Update the remote streams after 5 seconds so the termination cause will be shown in UI.
      .compactMap { $0.userInfo?[ChannelNotification.Key.remoteStream] as? RemoteStream }
      .delay(for: .fiveSeconds, scheduler: RunLoop.main)
      .sink { [weak self] stream in
        self?.remoteStreams.removeAll { stream == $0.remoteStream }
      }
      .store(in: &channelSubscriptions)
  }
}

private extension String {
  static let unknownState = "is unknown state"
}

private extension RemoteStream.ConnectionState {
  // Converts a `RemoteStream.ConnectionState` into a string for displaying in the View
  func uiString(_ terminationCause: String? = nil) -> String {
    switch self {
    case .connecting:
      return "is connecting"
    case .connected:
      return "is connected"
    case .terminated:
      return "terminated with cause: \(terminationCause ?? "none")"
    default:
      return .unknownState
    }
  }
}

// A view model class for exposing RemoteStream properties
public class RemoteStreamViewModel: ObservableObject {
  // The remote stream this view model represents
  public let remoteStream: RemoteStream
  private var cancellables = Set<AnyCancellable>()

  // RemoteStream state values exposed to the View
  @Published var remoteAudioMuted = false
  @Published var localAudioMuted = false
  @Published var remoteVideoMuted = false
  @Published var localVideoMuted = false
  @Published var voiceActivity = false
  @Published var connectionState: String = .unknownState

  // The view that is used to render video from the RemoteStream
  public let videoView = UIView()

  public var userID: String {
    remoteStream.userID
  }

  public init(remoteStream: RemoteStream) {
    self.remoteStream = remoteStream

    setupNotifications()

    remoteAudioMuted = remoteStream.remoteAudioMuted
    localAudioMuted = remoteStream.localAudioMuted
    remoteVideoMuted = remoteStream.remoteVideoMuted
    localVideoMuted = remoteStream.localVideoMuted
    voiceActivity = remoteStream.voiceActivity
    connectionState = remoteStream.connectionState.uiString(remoteStream.terminationCause.description)
  }

  private func setupNotifications() {
    // Set up Notification handlers with Combine using NotificationCenter.Publisher

    // RemoteStreamNotification.connectionStateDidChange is posted when the connection state changes,
    // e.g. the state could change from .connecting to .connected or from .connected to .terminated
    NotificationCenter.default.publisher(for: RemoteStreamNotification.connectionStateDidChange, object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.newConnectionState] as? RemoteStream.ConnectionState }
      .sink { [weak self] state in
        guard let self = self else { return }
        self.connectionState = state.uiString(self.remoteStream.terminationCause.description)
      }
      .store(in: &cancellables)

    // RemoteStreamNotification.remoteAudioMuteStateDidChange is posted when
    // the RemoteStream audio is muted or unmuted by its publisher
    NotificationCenter.default.publisher(for: RemoteStreamNotification.remoteAudioMuteStateDidChange,
                                         object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.remoteAudioMuted = muted
      }
      .store(in: &cancellables)

    // RemoteStreamNotification.localAudioMuteStateDidChange is posted when the RemoteStream
    // audio is muted locally, such as when calling remoteStream.muteAudio(_:)
    NotificationCenter.default.publisher(for: RemoteStreamNotification.localAudioMuteStateDidChange,
                                         object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.localAudioMuted = muted
      }
      .store(in: &cancellables)

    // RemoteStreamNotification.remoteVideoMuteStateDidChange is posted when
    // the RemoteStream video is muted or unmuted by its publisher
    NotificationCenter.default.publisher(for: RemoteStreamNotification.remoteVideoMuteStateDidChange,
                                         object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.remoteVideoMuted = muted
      }
      .store(in: &cancellables)

    // RemoteStreamNotification.localVideoMuteStateDidChange is posted when the RemoteStream
    // video is muted locally, such as when calling remoteStream.muteAudio(_:)
    NotificationCenter.default.publisher(for: RemoteStreamNotification.localVideoMuteStateDidChange,
                                         object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.muted] as? Bool }
      .sink { [weak self] muted in
        self?.localVideoMuted = muted
      }
      .store(in: &cancellables)

    // RemoteStreamNotification.voiceActivityStateDidChange is posted
    // when the RemoteStream's voiceActivity property changes
    NotificationCenter.default.publisher(for: RemoteStreamNotification.voiceActivityStateDidChange,
                                         object: remoteStream)
      .compactMap { $0.userInfo?[RemoteStreamNotification.Key.voiceActivity] as? Bool }
      .sink { [weak self] voiceActivity in
        self?.voiceActivity = voiceActivity
      }
      .store(in: &cancellables)
  }

  public func toggleAudioMuted() {
    // Mute or unmute the remoteStream audio locally
    remoteStream.muteAudio(!remoteStream.localAudioMuted)
  }

  public func toggleVideoMuted() {
    // Mute or unmute the remoteStream video locally
    remoteStream.muteVideo(!remoteStream.localVideoMuted)
  }

  public func remoteStreamVideoAppeared() {
    // Begin rendering video from the RemoteStream
    remoteStream.setRenderTarget(to: videoView)
  }

  public func remoteStreamVideoDisappeared() {
    // Stop rendering video from the RemoteStream
    remoteStream.setRenderTarget(to: nil)
  }
}
