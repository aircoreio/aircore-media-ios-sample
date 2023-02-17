//
//  VideoChatView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 1/20/23.
//

import SwiftUI

struct VideoChatView: View {
  @ObservedObject var localStreamViewModel: LocalStreamViewModel
  @ObservedObject var remoteStreamsViewModel: RemoteStreamsViewModel
  var cameraViewModel: CameraViewModel

  var body: some View {
    GeometryReader { geometry in
      HStack {
        if !localStreamViewModel.audioOnly {
          CameraView(localStreamViewModel: localStreamViewModel, cameraViewModel: cameraViewModel)
            .frame(width: geometry.size.height)
            .cornerRadius(5)
        }

        RemoteVideosView(remoteStreamsViewModel: remoteStreamsViewModel)
      }
      .padding([.leading, .trailing], 5.0)
    }
  }
}
