//
//  NeumorphicButtonStyle.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import SwiftUI

struct NeumorphicButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .shadow(color: .white, radius: configuration.isPressed ? 7 : 10, x: configuration.isPressed ? -5 : -15, y: configuration.isPressed ? -5 : -15)
                        .shadow(color: .black, radius: configuration.isPressed ? 7 : 10, x: configuration.isPressed ? 5 : 15, y: configuration.isPressed ? 5 : 15)
                        .blendMode(.overlay)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(backgroundColor)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .foregroundColor(.white)
            .animation(.spring(), value: 1)
    }
}

extension ButtonStyle where Self == NeumorphicButtonStyle {
    static var neumorphic: Self {
        return .init(backgroundColor: .blue)
    }
}
