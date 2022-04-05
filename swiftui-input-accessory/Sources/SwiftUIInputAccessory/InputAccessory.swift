import SwiftUI

public protocol InputAccessory: View {}

extension View {
    @ViewBuilder
    public func inputAccessory<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.modifier(InputAccessoryModifier(content))
    }

    @ViewBuilder
    public func inputAccessory<Content: InputAccessory>(_ content: Content) -> some View {
        inputAccessory { content }
    }
}
