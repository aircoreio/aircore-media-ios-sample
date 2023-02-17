//
//  ChannelInfoView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 10/20/22.
//

import SwiftUI

struct ChannelInfoView: View {
  @ObservedObject var channelViewModel: ChannelViewModel

  var body: some View {
    HStack {
      Text("Current channel")
      Spacer()
      Text(channelViewModel.channelID)
        .foregroundColor(.secondary)
    }
    HStack {
      Text("Channel active state")
      Spacer()
      Text(channelViewModel.joinState?.description ?? "N/A")
        .foregroundColor(.secondary)
    }
    HStack {
      Text("Channel termination cause")
      Spacer()
      Text(channelViewModel.terminationCause?.description ?? "N/A")
        .foregroundColor(.secondary)
    }
  }
}
