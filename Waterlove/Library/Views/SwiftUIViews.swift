//
//  SwiftUIViews.swift
//  Waterlove
//
//  Created by Oleksiy Petlyuk on 01.02.2022.
//

import SwiftUI

enum SwiftUIViews {
  struct CircularProgressBar: View {
    let progress: UInt8
    var lineWidth: CGFloat = 20
    var foregroundColor: Color = .blue

    var body: some View {
      ZStack {
        Circle()
          .stroke(lineWidth: lineWidth)
          .opacity(0.3)
          .foregroundColor(foregroundColor)

        Circle()
          .trim(from: 0.0, to: min(CGFloat(progress) / 100, 1))
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
          .foregroundColor(foregroundColor)
          .rotationEffect(Angle(degrees: 270))
          .animation(.easeInOut, value: progress)
      }
      .padding()
    }
  }
}

struct SwiftUIViews_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIViews.CircularProgressBar(progress: 75)

    SwiftUIViews.CircularProgressBar(progress: 75, foregroundColor: .green)
  }
}
