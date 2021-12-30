import Introspect
import SwiftUI

public struct MultilineTextField: View {
    private var placeholder: String
    @Binding
    private var text: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: .constant(""))
                .hidden()
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextFieldMinimumHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )

            Text(text)
                .hidden()
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.tertiaryLabel))
            }

            TextEditor(text: $text)
                .frame(height: max(textFieldMinimumHeight, textHeight))
                .introspectTextView {
                    $0.isScrollEnabled = false
                    $0.backgroundColor = .clear
                    $0.textContainerInset = .zero
                    $0.textContainer.lineFragmentPadding = .zero
                }
        }
        .onPreferenceChange(TextFieldMinimumHeightKey.self) {
            textFieldMinimumHeight = $0
        }
        .onPreferenceChange(TextHeightKey.self) {
            textHeight = $0
        }
    }

    @State private var textFieldMinimumHeight: CGFloat = 0
    @State private var textHeight: CGFloat = 0
}

private struct TextFieldMinimumHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

private struct TextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
