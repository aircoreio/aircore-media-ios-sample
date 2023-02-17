//
//  RemoteVideosView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 1/23/23.
//

import SwiftUI

struct RemoteVideosView: View {
  @ObservedObject var remoteStreamsViewModel: RemoteStreamsViewModel

  var body: some View {
    GeometryReader { geometry in
      if remoteStreamsViewModel.remoteStreams.isEmpty {
        VStack {
          Spacer()
          HStack {
            Spacer()
            Text("No remote streams")
              .foregroundColor(.secondary)
            Spacer()
          }
          Spacer()
        }
      }
      ScrollView(.horizontal) {
        HStack {
          ForEach(remoteStreamsViewModel.remoteStreams, id: \.remoteStream) { remoteStreamViewModel in
            RemoteVideoView(remoteStreamViewModel: remoteStreamViewModel)
              .frame(width: geometry.size.height)
          }
        }
      }
    }
  }
}

struct RemoteVideoView: View {
  @ObservedObject var remoteStreamViewModel: RemoteStreamViewModel

  var body: some View {
    Group {
      if remoteStreamViewModel.localVideoMuted || remoteStreamViewModel.remoteVideoMuted {
        ZStack {
          Color.gray
          VStack {
            Text(remoteStreamViewModel.userID)
            if remoteStreamViewModel.localVideoMuted {
              Image(systemName: "video.slash")
                .foregroundColor(.white)
                .imageScale(.large)
            } else if remoteStreamViewModel.remoteVideoMuted {
              Image(systemName: "video.slash.fill")
                .foregroundColor(.white)
                .imageScale(.large)
            }
          }
        }
      } else {
        VideoRenderView(view: remoteStreamViewModel.videoView)
          .onAppear {
            remoteStreamViewModel.remoteStreamVideoAppeared()
          }
          .onDisappear {
            remoteStreamViewModel.remoteStreamVideoDisappeared()
          }
      }
    }
      .cornerRadius(5)
  }
}

