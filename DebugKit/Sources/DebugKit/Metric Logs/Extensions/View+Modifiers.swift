//
//  View+Modifiers.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

// MARK: - Corner Rounding
extension View {

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

private struct RoundedCorner: Shape {

    // MARK: - Properties
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    // MARK: - Shape
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Sizing
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
