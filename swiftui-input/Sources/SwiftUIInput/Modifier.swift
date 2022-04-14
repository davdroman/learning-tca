import Introspect
import SwiftUI

struct Modifier<SwiftUIView: View>: ViewModifier {
    @State
    private var hosting: UIHostingController<AnyView>?
    private let keyPath: ReferenceWritableKeyPath<TextContainer, UIView?>
    private let swiftUIView: SwiftUIView

    init(
        _ keyPath: ReferenceWritableKeyPath<TextContainer, UIView?>,
        @ViewBuilder _ swiftUIView: () -> SwiftUIView
    ) {
        self.keyPath = keyPath
        self.swiftUIView = swiftUIView()
    }

    func body(content: Content) -> some View {
        content.introspectTextContainerView(customize: setInputView)
    }

    private func setInputView(for container: TextContainerView) {
        guard
            container[keyPath: keyPath] == nil,
            let parent = container.parentViewController
        else {
            return
        }

        let input = swiftUIView.environment(\._inputEndEditing) { [weak container] in
            container?.endEditing(true)
        }
        let hosting = UIHostingController_FB9641883(rootView: AnyView(input))
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(hosting)
        container[keyPath: keyPath] = hosting.view
        hosting.didMove(toParent: parent)
        self.hosting = hosting
    }
}

@objc protocol TextContainer: UITextInput {
    var inputView: UIView? { get set }
    var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextContainer {}
extension UITextView: TextContainer {}

typealias TextContainerView = UIView & TextContainer

extension View {
    func introspectTextContainerView(customize: @escaping (TextContainerView) -> ()) -> some View {
        introspect(
            selector: { Introspect.findAncestorOrAncestorChild(ofType: TextContainerView.self, from: $0) },
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
