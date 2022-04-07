import SwiftUI

public protocol Input: View {}

extension View {
    @ViewBuilder
    public func input<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.modifier(InputModifier(content))
    }

    @ViewBuilder
    public func input<Content: Input>(_ content: Content) -> some View {
        input { content }
    }
}

extension EnvironmentValues {
    public var inputEndEditing: () -> Void {
        get { self[InputEndEditingKey.self] }
    }
}
