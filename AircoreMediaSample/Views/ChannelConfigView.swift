//
//  ChannelControlView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 8/10/22.
//

import SwiftUI

struct ChannelConfigView: View {
  @State private var channelConnectionInfo = ChannelConnectionInfo()
  @ObservedObject var channel: ChannelViewModel

  var body: some View {
    let submitBlock: (Bool) -> Void = { isEditing in
      guard !isEditing else { return }
      channelConnectionInfo.saveToDefaults()
    }

    TextField("Channel ID", text: $channelConnectionInfo.channelID, onEditingChanged: submitBlock)
    TextField("User ID", text: $channelConnectionInfo.userID, onEditingChanged: submitBlock)

    Button(action: {
      channel.toggleJoinLeaveChannel(channelConnectionInfo)
    }, label: {
      if channel.channel != nil {
        HStack {
          Image(systemName: "x.circle")
            .foregroundColor(.red)
          Text("Stop Channel")
        }
      } else {
        HStack {
          Image(systemName: "phone.fill.arrow.up.right")
          Text("Join channel")
        }
      }
    })
  }
}
