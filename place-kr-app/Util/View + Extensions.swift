//
//  View + Extensions.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/27.
//

import SwiftUI
struct EncapsulateModifier: ViewModifier {
    let mode: Mode
    
    enum Mode {
        case dark
        case light
    }
    
    func body(content: Content) -> some View {
        if mode == .dark {
            content
                .font(.system(size: 11, weight: .bold))
                .padding(.vertical, 4)
                .padding(.horizontal, 9)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 38/255, green: 38/255, blue: 38/255))
                )
                .foregroundColor(.white)
        } else {
            content
                .font(.system(size: 11, weight: .bold))
                .padding(.vertical, 4)
                .padding(.horizontal, 9)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black)
                )
                .foregroundColor(.black)
        }
    }
}

struct LazyView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()          // << everything is created here
    }
}

struct ProgressView: UIViewRepresentable {

    let isAnimating = true
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ProgressView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ProgressView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct RoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    var bgColor: Color
    var textColor: Color
    var isStroked: Bool?
    var isSpanned: Bool?
    var width: CGFloat?
    var height: CGFloat
    let shape = RoundedRectangle(cornerRadius: 4)
    
    var calculatedWidth: CGFloat? {
        if let isSpanned = isSpanned, isSpanned == true {
            return .infinity
        } else {
            if let width = width {
                return width
            } else {
                return nil
            }
        }
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .frame(minWidth: width, maxWidth: calculatedWidth, minHeight: height)
            .background(
                shape.fill(bgColor)
            )
            .overlay(
                shape.stroke(.black.opacity(isStroked ?? false ? 1 : 0), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
            .opacity(!isEnabled ? 0.3 : 1)
    }
}

struct CapsuledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.black)
            .font(.system(size: 14))
            .frame(width: 52, height: 34)
    }
}

struct CircleButtonStyle: ButtonStyle {
    var bgColor: Color = .gray.opacity(0.3)
    var isSmall = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: !isSmall ? 16 : 12))
            .frame(width: !isSmall ? 27 : 17, height: !isSmall ? 27 : 17)
            .background(Circle()
                            .fill(bgColor)
            )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct StarButtonShape: View {
    let radius: CGFloat
    let bgColor: Color
    let fgColor: Color
    
    init(_ radius: CGFloat, fgColor: Color,  bgColor: Color) {
        self.radius = radius
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    
    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .foregroundColor(fgColor)
            .aspectRatio(contentMode: .fit)
            .padding(5)
            .background(
                Circle()
                    .fill(bgColor)
            )
            .frame(width: radius, height: radius)
    }
}

struct ShareButtonShape: View {
    let radius: CGFloat
    let bgColor: Color
    let fgColor: Color
    
    init(_ radius: CGFloat, fgColor: Color,  bgColor: Color) {
        self.radius = radius
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    
    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .foregroundColor(fgColor)
            .aspectRatio(contentMode: .fit)
            .padding(5)
            .background(
                Circle()
                    .fill(bgColor)
            )
            .frame(width: radius, height: radius)
    }
}

extension View {
    func encapsulate(mode: EncapsulateModifier.Mode) -> some View {
        modifier(EncapsulateModifier(mode: mode))
    }
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}
