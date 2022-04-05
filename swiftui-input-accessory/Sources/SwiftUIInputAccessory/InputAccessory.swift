import Introspect
import SwiftUI

//public protocol InputAccessory {
//    func items(_ endEditing: UIAction) -> [UIBarButtonItem]
//}
//
//public struct DefaultInputAccessory: InputAccessory {
//    public func items(_ endEditing: UIAction) -> [UIBarButtonItem] {
//        [
//            UIBarButtonItem.flexibleSpace(),
//            UIBarButtonItem(systemItem: .done, primaryAction: endEditing),
//        ]
//    }
//}
//
//extension InputAccessory where Self == DefaultInputAccessory {
//    public static var `default`: DefaultInputAccessory { .init() }
//}

extension View {
    @ViewBuilder
    public func inputAccessory<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.modifier(InputAccessoryModifier(content))
    }
}

struct InputAccessoryModifier<InputAccessory: View>: ViewModifier {
    private typealias TextInputView = (UIView & TextInput)

    @State
    private var hosting: UIHostingController<AnyView>?
    private var inputAccessory: InputAccessory

    init(@ViewBuilder _ inputAccessory: () -> InputAccessory) {
        self.inputAccessory = inputAccessory()
    }

    func body(content: Content) -> some View {
        content
            .introspectTextField(customize: setInputAccessoryView)
            .introspectTextView(customize: setInputAccessoryView)
    }

    private func setInputAccessoryView(for field: TextInputView) {
        guard
            hosting == nil,
            let parent = field.parentViewController
        else {
            return
        }

        let inputAccessory = inputAccessory.environment(\._inputAccessoryEndEditing) {
            field.resignFirstResponder()
        }
        let hosting = InputAccessoryHostingController(rootView: AnyView(inputAccessory))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(hosting)
        field.inputAccessoryView = hosting.view
        hosting.didMove(toParent: parent)
        self.hosting = hosting
    }
}

final class InputAccessoryHostingController: UIHostingController<AnyView> {
    override func viewWillAppear(_ animated: Bool) {
        fixViewLayout()
        super.viewWillAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        fixViewLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewWillDisappear(_ animated: Bool) {
        fixViewLayout()
        super.viewWillDisappear(animated)
    }

    private func fixViewLayout() {
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
    public var inputAccessoryEndEditing: () -> Void {
        get { self[InputAccessoryEndEditingKey.self] }
    }

    var _inputAccessoryEndEditing: () -> Void {
        get { self[InputAccessoryEndEditingKey.self] }
        set { self[InputAccessoryEndEditingKey.self] = newValue }
    }

    private struct InputAccessoryEndEditingKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
}

extension UIView {
    var parentViewController: UIViewController? {
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
