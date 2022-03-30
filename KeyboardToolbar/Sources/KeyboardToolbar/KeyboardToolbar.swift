import Introspect
import SwiftUI

public protocol KeyboardToolbar {
    func items(_ endEditing: UIAction) -> [UIBarButtonItem]
}

public struct DefaultKeyboardToolbar: KeyboardToolbar {
    public func items(_ endEditing: UIAction) -> [UIBarButtonItem] {
        [
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(systemItem: .done, primaryAction: endEditing),
        ]
    }
}

extension KeyboardToolbar where Self == DefaultKeyboardToolbar {
    public static var `default`: DefaultKeyboardToolbar { .init() }
}

extension View {
    @ViewBuilder
    public func keyboardToolbar<KT: KeyboardToolbar>(_ toolbar: KT) -> some View {
        self.modifier(KeyboardToolbarModifier(toolbar))
    }

    @ViewBuilder
    public func keyboardToolbar() -> some View {
        self.modifier(KeyboardToolbarModifier(.default))
    }
}

struct KeyboardToolbarModifier<KT: KeyboardToolbar>: ViewModifier {
    private typealias TextInputView = (UIView & TextInput)

    @Weak
    private var view: TextInputView?
    private var toolbar: KT
    private var uiToolbar: UIToolbar {
        UIToolbar.keyboardToolbar(
            items: toolbar.items(
                UIAction { _ in
                    view?.resignFirstResponder()
                }
            )
        )
    }

    init(_ toolbar: KT) {
        self.toolbar = toolbar
    }

    func body(content: Content) -> some View {
        content
            .introspectTextField(customize: collect)
            .introspectTextView(customize: collect)
    }

    private func collect(_ textInputView: TextInputView) {
        textInputView.inputAccessoryView = uiToolbar
        view = textInputView
    }
}

@objc private protocol TextInput: UITextInput {
    var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextInput {}
extension UITextView: TextInput {}

private extension UIToolbar {
    static func keyboardToolbar(items: [UIBarButtonItem]) -> UIToolbar {
        let bar = UIToolbar()
        bar.items = items
        bar.sizeToFit()
        return bar
    }
}
