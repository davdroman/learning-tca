import Introspect
import SwiftUI

//public protocol KeyboardToolbar {
//    func items(_ endEditing: UIAction) -> [UIBarButtonItem]
//}
//
//public struct DefaultKeyboardToolbar: KeyboardToolbar {
//    public func items(_ endEditing: UIAction) -> [UIBarButtonItem] {
//        [
//            UIBarButtonItem.flexibleSpace(),
//            UIBarButtonItem(systemItem: .done, primaryAction: endEditing),
//        ]
//    }
//}
//
//extension KeyboardToolbar where Self == DefaultKeyboardToolbar {
//    public static var `default`: DefaultKeyboardToolbar { .init() }
//}

extension View {
    @ViewBuilder
    public func keyboardToolbar<Toolbar: View>(@ViewBuilder _ toolbar: () -> Toolbar) -> some View {
        self.modifier(KeyboardToolbarModifier(toolbar))
    }
}

struct KeyboardToolbarModifier<Toolbar: View>: ViewModifier {
    private typealias TextInputView = (UIView & TextInput)

    @State
    private var hosting: UIHostingController<AnyView>?
    private var toolbar: Toolbar

    init(@ViewBuilder _ toolbar: () -> Toolbar) {
        self.toolbar = toolbar()
    }

    func body(content: Content) -> some View {
        content
            .introspectTextField(customize: setToolbar)
            .introspectTextView(customize: setToolbar)
    }

    private func setToolbar(for field: TextInputView) {
        guard
            hosting == nil,
            let parent = field.parentViewController
        else {
            return
        }

        let toolbar = toolbar.environment(\._keyboardToolbarEndEditing) {
            field.resignFirstResponder()
        }
        let hosting = KeyboardToolbarHostingController(rootView: AnyView(toolbar))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(hosting)
        field.inputAccessoryView = hosting.view
        hosting.didMove(toParent: parent)
        self.hosting = hosting
    }
}

final class KeyboardToolbarHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        fixKeyboardToolbarSize()
        super.viewWillAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        fixKeyboardToolbarSize()
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewWillDisappear(_ animated: Bool) {
        fixKeyboardToolbarSize()
        super.viewWillDisappear(animated)
    }

    private func fixKeyboardToolbarSize() {
        removeAllViewConstraints()
        forceViewRelayout()
    }

    private func removeAllViewConstraints() {
        view.removeConstraints(view.constraints)
    }

    private func forceViewRelayout() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

@objc private protocol TextInput: UITextInput {
    var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextInput {}
extension UITextView: TextInput {}

extension EnvironmentValues {
    public var keyboardToolbarEndEditing: () -> Void {
        get { self[KeyboardToolbarEndEditingKey.self] }
    }

    var _keyboardToolbarEndEditing: () -> Void {
        get { self[KeyboardToolbarEndEditingKey.self] }
        set { self[KeyboardToolbarEndEditingKey.self] = newValue }
    }

    private struct KeyboardToolbarEndEditingKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

private extension UIToolbar {
    static func keyboardToolbar(items: [UIBarButtonItem]) -> UIToolbar {
        let bar = UIToolbar()
        bar.items = items
        bar.sizeToFit()
        return bar
    }
}
