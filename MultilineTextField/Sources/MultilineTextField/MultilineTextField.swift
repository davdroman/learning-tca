import Introspect
import SwiftUI

public struct MultilineTextField: View {
    private var placeholder: String
    @Binding
    private var text: String

    @Weak
    private var view: UITextView?
    @State
    private var delegate: NSTextStorageDelegate?

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

                    // observe text changes via delegate
                    delegate = NSTextStorageDelegateInstance(onEditing: refreshTextHeightOnNextRunLoopPass)
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

        textHeight = proposedTextHeight
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

private final class NSTextStorageDelegateInstance: NSObject, NSTextStorageDelegate {
    typealias OnEditing = () -> Void

    let onEditing: OnEditing

    init(onEditing: @escaping OnEditing) {
        self.onEditing = onEditing
        super.init()
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        onEditing()
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
