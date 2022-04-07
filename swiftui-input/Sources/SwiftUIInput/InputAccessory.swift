import SwiftUI

public protocol InputAccessory: View {}

public struct DefaultInputAccessory: InputAccessory {
    @Environment(\.inputEndEditing)
    private var endEditing

    public var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Divider()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            Button("Done", action: endEditing)
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 44)
        .background(Color(.secondarySystemBackground))
    }
}

extension InputAccessory where Self == DefaultInputAccessory {
    public static var `default`: DefaultInputAccessory { .init() }
}

extension View {
    @ViewBuilder
    public func inputAccessory<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.modifier(Modifier(\.inputAccessoryView, content))
    }

    @ViewBuilder
    public func inputAccessory<Content: InputAccessory>(_ content: Content) -> some View {
        inputAccessory { content }
    }
}
