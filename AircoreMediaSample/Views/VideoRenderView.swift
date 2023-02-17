//
//  VideoRenderView.swift
//  AircoreMediaSample
//
//  Created by Adam Bellard on 1/23/23.
//

import SwiftUI

struct VideoRenderView: UIViewRepresentable {
  typealias UIViewType = UIView

  let view: UIView

  func makeUIView(context: Self.Context) -> UIView {
    view
  }

  func updateUIView(_ uiView: UIView, context: Self.Context) {}
}
