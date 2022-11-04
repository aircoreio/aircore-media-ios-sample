//
//  RemoteStreamsView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import SwiftUI

struct RemoteStreamView: View {
  @ObservedObject var remoteStream: RemoteStreamViewModel

  var body: some View {
    HStack {
      if let remoteAudioMuted = remoteStream.remoteAudioMuted, let localAudioMuted = remoteStream.localAudioMuted {
        Button(action: {
          remoteStream.toggleAudioMuted()
        }, label: {
          if localAudioMuted {
            Image(systemName: "speaker.slash")
          } else {
            Image(systemName: remoteAudioMuted ? "speaker.slash.fill" : "speaker.fill")
          }
        }).imageScale(.large)
        Spacer()
      }
      Text(remoteStream.userID)
      Text(remoteStream.connectionState)
    }
    .padding(5)
    // Voice activity will display a green border around this view
    .border(.green, width: remoteStream.voiceActivity == true ? 1 : 0)
  }
}

struct RemoteStreamsView: View {
  @ObservedObject var remoteStreams: RemoteStreamsViewModel

  var body: some View {
    if remoteStreams.remoteStreams.isEmpty {
      Text("No remote streams")
        .foregroundColor(.secondary)
    }
    ForEach(Array(remoteStreams.remoteStreams), id: \.self) { remoteStream in
      RemoteStreamView(remoteStream: RemoteStreamViewModel(remoteStream: remoteStream))
    }
  }
}
