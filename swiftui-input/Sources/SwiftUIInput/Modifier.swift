import Introspect
import SwiftUI

struct Modifier<SwiftUIView: View>: ViewModifier {
    @State
    private var hosting: UIHostingController<AnyView>?
    private let keyPath: ReferenceWritableKeyPath<TextInput, UIView?>
    private let swiftUIView: SwiftUIView

    init(
        _ keyPath: ReferenceWritableKeyPath<TextInput, UIView?>,
        @ViewBuilder _ swiftUIView: () -> SwiftUIView
    ) {
        self.keyPath = keyPath
        self.swiftUIView = swiftUIView()
    }

    func body(content: Content) -> some View {
        content.introspectTextInput(customize: setInputView)
    }

    private func setInputView(for field: TextInputView) {
        guard
            hosting == nil,
            let parent = field.parentViewController
        else {
            return
        }

        let input = swiftUIView.environment(\._inputEndEditing) {
            field.endEditing(true)
        }
        let hosting = UIHostingController_FB9641883(rootView: AnyView(input))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(hosting)
        field[keyPath: keyPath] = hosting.view
        hosting.didMove(toParent: parent)
        self.hosting = hosting
    }
}

@objc protocol TextInput: UITextInput {
    var inputView: UIView? { get set }
    var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextInput {}
extension UITextView: TextInput {}

typealias TextInputView = (UIView & TextInput)

extension View {
    func introspectTextInput(customize: @escaping (TextInputView) -> ()) -> some View {
        introspect(
            selector: { Introspect.findAncestorOrAncestorChild(ofType: TextInputView.self, from: $0) },
            customize: customize
        )
    }
}

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
    public var inputEndEditing: () -> Void {
        get { self[InputEndEditingKey.self] }
    }

    var _inputEndEditing: () -> Void {
        get { self[InputEndEditingKey.self] }
        set { self[InputEndEditingKey.self] = newValue }
    }

    struct InputEndEditingKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
}
