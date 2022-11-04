//
//  LocalStreamView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/10/22.
//

import SwiftUI

struct LocalStreamView: View {
  @ObservedObject var localStream: LocalStreamViewModel

  var body: some View {
    Button(action: {
      localStream.toggleStartStop()
    }, label: {
      if localStream.localStream == nil {
        HStack {
          Image(systemName: "mic.fill.badge.plus")
          Text("Start local stream")
        }
      } else {
        HStack {
          Image(systemName: "x.circle")
            .foregroundColor(.red)
          Text("Stop local stream")
        }
      }
    })

    Button(action: {
      localStream.toggleAudioMuted()
    }, label: {
      HStack {
        let audioMuted = localStream.audioMuted ?? false
        Image(systemName: audioMuted ? "mic.fill" : "mic.slash.fill")
          .foregroundColor((localStream.voiceActivity == true) ? .green : .accentColor)
        Text("\(audioMuted ? "Unmute" : "Mute") Local Stream")
      }
    }).disabled(localStream.audioMuted == nil)

    HStack {
      Text("Connection state")
      Spacer()
      Text(localStream.connectionState ?? "N/A")
        .foregroundColor(.secondary)
    }

    HStack {
      Text("Termination cause")
      Spacer()
      Text(localStream.terminationCause ?? "N/A")
        .foregroundColor(.secondary)
    }
  }
}
