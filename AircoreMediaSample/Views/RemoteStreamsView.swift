//
//  RemoteStreamsView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import SwiftUI

struct RemoteStreamView: View {
  @ObservedObject var remoteStreamViewModel: RemoteStreamViewModel

  var body: some View {
    HStack {
      Button(action: {
        remoteStreamViewModel.toggleAudioMuted()
      }, label: {
        if remoteStreamViewModel.localAudioMuted {
          Image(systemName: "speaker.slash")
        } else if remoteStreamViewModel.remoteAudioMuted {
          Image(systemName: "speaker.slash.fill")
        } else {
          Image(systemName: "speaker.fill")
        }
      }).imageScale(.large)
        .buttonStyle(.borderless)

      Button(action: {
        remoteStreamViewModel.toggleVideoMuted()
      }, label: {
        if remoteStreamViewModel.localVideoMuted {
          Image(systemName: "video.slash")
        } else if remoteStreamViewModel.remoteVideoMuted {
          Image(systemName: "video.slash.fill")
        } else {
          Image(systemName: "video.fill")
        }
      }).imageScale(.large)
        .buttonStyle(.borderless)

      Spacer()
      Text(remoteStreamViewModel.userID)
      Text(remoteStreamViewModel.connectionState)
    }
    .padding(5)
    // Voice activity will display a green border around this view
    .border(.green, width: remoteStreamViewModel.voiceActivity == true ? 1 : 0)
  }
}

struct RemoteStreamsView: View {
  @ObservedObject var remoteStreamsViewModel: RemoteStreamsViewModel

  var body: some View {
    if remoteStreamsViewModel.remoteStreams.isEmpty {
      Text("No remote streams")
        .foregroundColor(.secondary)
    }
    ForEach(remoteStreamsViewModel.remoteStreams, id: \.remoteStream) { remoteStreamViewModel in
      RemoteStreamView(remoteStreamViewModel: remoteStreamViewModel)
    }
  }
}
