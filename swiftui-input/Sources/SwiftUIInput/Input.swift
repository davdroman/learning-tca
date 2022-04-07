import SwiftUI

public protocol Input: View {}

extension View {
    @ViewBuilder
    public func input<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.modifier(Modifier(\.inputView, content))
    }

    @ViewBuilder
    public func input<Content: Input>(_ content: Content) -> some View {
        input { content }
    }
}
