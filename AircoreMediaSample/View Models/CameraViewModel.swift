//
//  CameraViewModel.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 2/1/23.
//

import Foundation
import AircoreMedia

public class CameraViewModel: ObservableObject {
  let camera = Camera()
  lazy var preview = Camera.Preview(camera: camera)

  // The view that is used to render video from the Camera.Preview
  let cameraView = UIView()

  public func cameraAppeared() {
    // Start the camera and begin rendering video.
    preview.start { [weak self] error in
      if let error = error {
        print("Error starting preview: \(error.localizedDescription)")
        return
      }
      self?.preview.setRenderTarget(self?.cameraView)
    }
  }

  public func cameraDisappeared() {
    // Stop the camera and stop rendering video.
    preview.setRenderTarget(nil)
    preview.stop()
  }
}
