//
//  ColorsView.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 1/6/22.
//

import SwiftUI

struct ColorsView: View {

    @State var colors: [Color]

    var body: some View {
        List {
            ForEach(colors, id: \.self) { color in
                VStack(alignment: .trailing) {
                    let rgb = color.rgbValues
                    HStack {
                        Text(Int(rgb.red * 255), format: .number)
                            .foregroundColor(.red)

                        Text(Int(rgb.green * 255), format: .number)
                            .foregroundColor(.green)

                        Text(Int(rgb.blue * 255), format: .number)
                            .foregroundColor(.blue)
                    }

                    Rectangle()
                        .frame(height: 50)
                        .foregroundColor(color)
                }
            }
        }
    }
}

extension Color {

    var rgbValues: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return (red: 0, green: 0, blue: 0) }
        return (red, green, blue)
    }
}
