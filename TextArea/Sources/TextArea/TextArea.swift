import Introspect
import SwiftUI

public struct TextArea: View {
    private var placeholder: String
    @Binding
    private var text: String

    @Weak
    private var view: UITextView?
    @State
    private var delegate: TextStorageDelegate?
    @Environment(\.textAreaScrollDisabled)
    private var scrollDisabled
    @Environment(\.textAreaPadding)
    private var padding
    @Environment(\.textAreaAttributes)
    private var attributes

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.tertiaryLabel))
                    .padding(padding)
            }

            TextEditor(text: $text)
                .frame(idealHeight: textHeight?.rounded(.up))
                .introspectTextView {
                    // collect view instance
                    view = $0

                    // observe text editing via delegate
                    delegate = TextStorageDelegate(
                        onWillProcessEditing: applyTextAreaAttributes,
                        onDidProcessEditing: { _ in refreshTextHeightOnNextRunLoopPass() }
                    )
                    $0.textStorage.delegate = delegate

                    // set misc properties
                    $0.isScrollEnabled = !scrollDisabled
                    $0.backgroundColor = .clear
                    $0.textContainerInset = UIEdgeInsets(
                        top: padding.top,
                        left: padding.leading,
                        bottom: padding.bottom,
                        right: padding.trailing
                    )
                    $0.textContainer.lineFragmentPadding = .zero
                }
                .onSizeChange(perform: refreshTextHeight)
        }
    }

    @State private var textHeight: CGFloat? = nil

    private func refreshTextHeightOnNextRunLoopPass() {
        DispatchQueue.main.async(execute: refreshTextHeight)
    }

    private func refreshTextHeight() {
        guard let view = view else {
            return
        }

        guard scrollDisabled else {
            if textHeight != nil {
                textHeight = nil
            }
            return
        }

        let currentTextHeight = self.textHeight
        let proposedTextHeight = view.idealTextHeight()

        guard proposedTextHeight != currentTextHeight else {
            return
        }

        textHeight = proposedTextHeight
    }

    private func applyTextAreaAttributes(to storage: NSTextStorage) {
        guard !attributes.isEmpty else {
            return
        }
        let range = NSRange(location: 0, length: storage.length)
        let attributedString = NSMutableAttributedString(
            attributedString: storage.attributedSubstring(from: range)
        )
        attributedString.addAttributes(attributes, range: range)
        storage.setAttributedString(attributedString)
    }
}

extension UITextView {
    fileprivate func idealTextHeight() -> CGFloat {
        let newSize = self.sizeThatFits(CGSize(width: self.frame.size.width, height: .greatestFiniteMagnitude))
        let newHeight = newSize.height
        return newHeight
    }
}

struct TextArea_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextArea("Placeholder", text: .constant(""))
            TextArea("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
