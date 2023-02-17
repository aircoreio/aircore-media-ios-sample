//
//  CameraView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 1/20/23.
//

import SwiftUI
import AircoreMedia

struct CameraView: View {
  @ObservedObject var localStreamViewModel: LocalStreamViewModel
  var cameraViewModel: CameraViewModel

  var body: some View {
    if localStreamViewModel.hasLocalStream {
      ZStack {
        VideoRenderView(view: cameraViewModel.cameraView)
          .onAppear {
            cameraViewModel.cameraAppeared()
          }
          .onDisappear {
            cameraViewModel.cameraDisappeared()
          }
        ZStack {
          Color(UIColor(white: 0, alpha: 0.5))
          Image(systemName: "video.slash.fill")
            .foregroundColor(.white)
        }
          .opacity(localStreamViewModel.videoMuted ? 1 : 0)
      }
    } else {
      ZStack {
        Color.gray
        Image(systemName: "person.circle")
          .foregroundColor(.white)
          .imageScale(.large)
      }
    }
  }
}
