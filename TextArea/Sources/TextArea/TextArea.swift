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
            }

            TextEditor(text: $text)
                .frame(idealHeight: textHeight?.rounded(.up))
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
                    $0.isScrollEnabled = !scrollDisabled
                    $0.backgroundColor = .clear
                    $0.textContainerInset = .zero
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
    var textAreaScrollDisabled: Bool {
        get { self[TextAreaScrollDisabledKey.self] }
        set { self[TextAreaScrollDisabledKey.self] = newValue }
    }
}

private struct TextAreaScrollDisabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var textAreaAttributes: [NSAttributedString.Key: Any] {
        get { self[TextAreaAttributesKey.self] }
        set { self[TextAreaAttributesKey.self] = newValue }
    }
}

private struct TextAreaAttributesKey: EnvironmentKey {
    static let defaultValue: [NSAttributedString.Key: Any] = [:]
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
