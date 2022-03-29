import Introspect
import SwiftUI

public struct MultilineTextField: View {
    private var placeholder: String
    @Binding
    private var text: String

    @Weak
    private var view: UITextView?
    @State
    private var delegate: TextStorageDelegate?
    @Environment(\.multilineTextFieldAttributes)
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
            }

            TextEditor(text: $text)
                .frame(idealHeight: textHeight.rounded(.up))
                .introspectTextView {
                    // collect view instance
                    view = $0

                    // observe text editing via delegate
                    delegate = TextStorageDelegate(
                        onWillProcessEditing: applyCustomTextAttributes,
                        onDidProcessEditing: { _ in refreshTextHeightOnNextRunLoopPass() }
                    )
                    $0.textStorage.delegate = delegate

                    // set misc properties
                    $0.isScrollEnabled = false
                    $0.backgroundColor = .clear
                    $0.textContainerInset = .zero
                    $0.textContainer.lineFragmentPadding = .zero
                }
                .onAppear(perform: refreshTextHeightOnNextRunLoopPass)
                .onSizeChange(perform: refreshTextHeightOnNextRunLoopPass)
        }
    }

    @State private var textHeight: CGFloat = 0

    private func refreshTextHeightOnNextRunLoopPass() {
        DispatchQueue.main.async(execute: refreshTextHeight)
    }

    private func refreshTextHeight() {
        guard let view = view else {
            return
        }

        let currentTextHeight = self.textHeight
        let proposedTextHeight = view.idealTextHeight()

        guard proposedTextHeight != currentTextHeight else {
            return
        }

        applyCustomTextAttributes(to: view.textStorage)

        textHeight = proposedTextHeight
    }

    private func applyCustomTextAttributes(to storage: NSTextStorage) {
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

@propertyWrapper
private class Weak<T: AnyObject> {
    var wrappedValue: T? {
        get { weakValue }
        set { weakValue = newValue }
    }

    weak var weakValue: T?

    init(wrappedValue: T?) {
        self.weakValue = wrappedValue
    }
}

private final class TextStorageDelegate: NSObject, NSTextStorageDelegate {
    typealias OnProcessEditing = (NSTextStorage) -> Void

    private let onWillProcessEditing: OnProcessEditing
    private let onDidProcessEditing: OnProcessEditing

    init(
        onWillProcessEditing: @escaping OnProcessEditing,
        onDidProcessEditing: @escaping OnProcessEditing
    ) {
        self.onWillProcessEditing = onWillProcessEditing
        self.onDidProcessEditing = onDidProcessEditing
        super.init()
    }

    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        onWillProcessEditing(textStorage)
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        onDidProcessEditing(textStorage)
    }
}

extension View {
    @ViewBuilder
    func onSizeChange(perform action: @escaping () -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { _ in action() }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension EnvironmentValues {
    var multilineTextFieldAttributes: [NSAttributedString.Key: Any] {
        get { self[MultilineTextFieldAttributesKey.self] }
        set { self[MultilineTextFieldAttributesKey.self] = newValue }
    }
}

private struct MultilineTextFieldAttributesKey: EnvironmentKey {
    static let defaultValue: [NSAttributedString.Key: Any] = [:]
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
