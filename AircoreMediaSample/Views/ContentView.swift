//
//  ContentView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/9/22.
//

import Combine
import SwiftUI

struct ContentView: View {
  @ObservedObject var channel = ChannelViewModel()
  @ObservedObject var localStream = LocalStreamViewModel()
  @ObservedObject private var remoteStreams = RemoteStreamsViewModel()

  init() {
    localStream.channel = channel
    remoteStreams.channel = channel
  }

  var body: some View {
    VStack {
      Form {
        Section(content: {
          ChannelConfigView(channel: channel)
        }, header: {
          Text("Channel Config")
        })

        Section(content: {
          ChannelInfoView(channel: channel)
        }, header: {
          Text("Channel Info")
        })

        Section(content: {
          LocalStreamView(localStream: localStream)
        }, header: {
          Text("Local stream")
        })

        Section(content: {
          RemoteStreamsView(remoteStreams: remoteStreams)
        }, header: {
          Text("Remote streams")
        })
      }
    }
      .navigationTitle("AircoreMedia Sample")
  }
}
