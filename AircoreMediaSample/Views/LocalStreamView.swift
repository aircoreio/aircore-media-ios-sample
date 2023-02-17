//
//  LocalStreamView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import SwiftUI

struct LocalStreamView: View {
  @ObservedObject var localStreamViewModel: LocalStreamViewModel

  var body: some View {
    Button(action: {
      localStreamViewModel.toggleStartStop()
    }, label: {
      if localStreamViewModel.hasLocalStream {
        HStack {
          Image(systemName: "x.circle")
            .foregroundColor(.red)
          Text("Stop local stream")
        }
      } else {
        HStack {
          Image(systemName: "person.badge.plus")
          Text("Start local stream")
        }
      }
    }).disabled(!localStreamViewModel.channelJoined)

    Toggle("Audio Only", isOn: $localStreamViewModel.audioOnly)

    Button(action: {
      localStreamViewModel.toggleAudioMuted()
    }, label: {
      HStack {
        let audioMuted = !localStreamViewModel.hasLocalStream || localStreamViewModel.audioMuted
        Image(systemName: audioMuted ? "mic.fill" : "mic.slash.fill")
          .foregroundColor(localStreamViewModel.voiceActivity ? .green : .accentColor)
        Text("\(audioMuted ? "Unmute" : "Mute") Local Stream Audio")
      }
    }).disabled(!localStreamViewModel.hasLocalStream)

    if !localStreamViewModel.audioOnly {
      Button(action: {
        localStreamViewModel.toggleVideoMuted()
      }, label: {
        HStack {
          let videoMuted = !localStreamViewModel.hasLocalStream || localStreamViewModel.videoMuted
          Image(systemName: videoMuted ? "video.fill" : "video.slash.fill")
          Text("\(videoMuted ? "Unmute" : "Mute") Local Stream Video")
        }
      }).disabled(!localStreamViewModel.hasLocalStream)
    }

    HStack {
      Text("Connection state")
      Spacer()
      Text(localStreamViewModel.connectionState ?? "N/A")
        .foregroundColor(.secondary)
    }

    HStack {
      Text("Termination cause")
      Spacer()
      Text(localStreamViewModel.terminationCause ?? "N/A")
        .foregroundColor(.secondary)
    }
  }
}
