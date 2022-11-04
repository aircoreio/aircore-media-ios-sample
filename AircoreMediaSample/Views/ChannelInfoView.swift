//
//  ChannelInfoView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 10/20/22.
//

import SwiftUI

struct ChannelInfoView: View {
  @ObservedObject var channel: ChannelViewModel

  var body: some View {
    HStack {
      Text("Current channel")
      Spacer()
      Text(channel.channelID)
        .foregroundColor(.secondary)
    }
    HStack {
      Text("Channel active state")
      Spacer()
      Text(channel.joinState?.description ?? "N/A")
        .foregroundColor(.secondary)
    }
    HStack {
      Text("Channel termination cause")
      Spacer()
      Text(channel.terminationCause?.description ?? "N/A")
        .foregroundColor(.secondary)
    }
  }
}
