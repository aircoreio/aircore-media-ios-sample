//
//  ContentView.swift
//  AircoreMedia-iOS-Sample
//
//  Created by Adam Bellard on 8/9/22.
//

import Combine
import SwiftUI

extension View {
  func dismissKeyboardOnVerticalDrag() -> some View {
    self
      .gesture(DragGesture().onChanged({ gesture in
        if abs(gesture.translation.height) > abs(gesture.translation.width) {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
      }))
  }
}

struct ContentView: View {
  @ObservedObject var channelViewModel = ChannelViewModel()
  @ObservedObject var localStreamViewModel = LocalStreamViewModel()
  @ObservedObject private var remoteStreamsViewModel = RemoteStreamsViewModel()
  let cameraViewModel = CameraViewModel()

  init() {
    localStreamViewModel.channelViewModel = channelViewModel
    localStreamViewModel.videoSource = cameraViewModel.camera
    remoteStreamsViewModel.channelViewModel = channelViewModel
  }

  var body: some View {
    VStack {
      Form {
        Section(content: {
          ChannelConfigView(channelViewModel: channelViewModel)
        }, header: {
          Text("Channel Config")
        })

        Section(content: {
          ChannelInfoView(channelViewModel: channelViewModel)
        }, header: {
          Text("Channel Info")
        })

        Section(content: {
          LocalStreamView(localStreamViewModel: localStreamViewModel)
        }, header: {
          Text("Local stream")
        })

        Section(content: {
          RemoteStreamsView(remoteStreamsViewModel: remoteStreamsViewModel)
        }, header: {
          Text("Remote streams")
        })
      }
      .overlay(Divider(), alignment: .bottom)
      .dismissKeyboardOnVerticalDrag()

      VideoChatView(localStreamViewModel: localStreamViewModel,
                    remoteStreamsViewModel: remoteStreamsViewModel,
                    cameraViewModel: cameraViewModel)
        .frame(height: 100)
    }
      .navigationTitle("AircoreMedia Sample")
  }
}
