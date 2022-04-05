import Introspect
import SwiftUI

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

@objc private protocol TextInput: UITextInput {
    var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextInput {}
extension UITextView: TextInput {}

private extension UIView {
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

extension EnvironmentValues {
    var _inputAccessoryEndEditing: () -> Void {
        get { self[InputAccessoryEndEditingKey.self] }
        set { self[InputAccessoryEndEditingKey.self] = newValue }
    }

    struct InputAccessoryEndEditingKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
}
