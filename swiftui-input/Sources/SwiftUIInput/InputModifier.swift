import Introspect
import SwiftUI

struct InputModifier<Input: View>: ViewModifier {
    private typealias TextInputView = (UIView & TextInput)

    @State
    private var hosting: UIHostingController<AnyView>?
    private var input: Input

    init(@ViewBuilder _ input: () -> Input) {
        self.input = input()
    }

    func body(content: Content) -> some View {
        content
            .introspectTextField(customize: setInputView)
            .introspectTextView(customize: setInputView)
    }

    private func setInputView(for field: TextInputView) {
        guard
            hosting == nil,
            let parent = field.parentViewController
        else {
            return
        }

        let input = input.environment(\._inputEndEditing) {
            field.endEditing(true)
        }
        let hosting = UIHostingController_FB9641883(rootView: AnyView(input))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(hosting)
        field.inputView = hosting.view
        hosting.didMove(toParent: parent)
        self.hosting = hosting
    }
}

@objc private protocol TextInput: UITextInput {
    var inputView: UIView? { get set }
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
    var _inputEndEditing: () -> Void {
        get { self[InputEndEditingKey.self] }
        set { self[InputEndEditingKey.self] = newValue }
    }

    struct InputEndEditingKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
}
