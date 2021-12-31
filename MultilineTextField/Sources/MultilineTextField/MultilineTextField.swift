import Introspect
import SwiftUI

public struct MultilineTextField: View {
    private var placeholder: String
    @Binding
    private var text: String
    private var minHeight: CGFloat

    public init(_ placeholder: String, text: Binding<String>, minHeight: CGFloat? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight ?? 0
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: .constant(""))
                .hidden()
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextFieldMinHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )

            Text(text)
                .fixedSize(horizontal: false, vertical: true)
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
                .frame(height: max(minHeight, textFieldMinHeight, textHeight).rounded(.up))
                .introspectTextView {
                    $0.isScrollEnabled = false
                    $0.backgroundColor = .clear
                    $0.textContainerInset = .zero
                    $0.textContainer.lineFragmentPadding = .zero
                }
        }
        .onPreferenceChange(TextFieldMinHeightKey.self) {
            textFieldMinHeight = $0
        }
        .onPreferenceChange(TextHeightKey.self) {
            textHeight = $0
        }
    }

    @State private var textFieldMinHeight: CGFloat = 0
    @State private var textHeight: CGFloat = 0
}

private struct TextFieldMinHeightKey: PreferenceKey {
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

struct MultilineTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultilineTextField("Placeholder", text: .constant(""))
            MultilineTextField("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
