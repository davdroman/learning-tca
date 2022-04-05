import SwiftUI

public protocol InputAccessory: View {}

public struct DefaultInputAccessory: InputAccessory {
    @Environment(\.inputAccessoryEndEditing)
    private var endEditing

    public var body: some View {
        ZStack {
            Button("Done", action: endEditing).padding()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 44)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

extension InputAccessory where Self == DefaultInputAccessory {
    public static var `default`: DefaultInputAccessory { .init() }
}

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

extension EnvironmentValues {
    public var inputAccessoryEndEditing: () -> Void {
        get { self[InputAccessoryEndEditingKey.self] }
    }
}
