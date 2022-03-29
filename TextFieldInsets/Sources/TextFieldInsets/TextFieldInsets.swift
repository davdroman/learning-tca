import Introspect
import SwiftUI

extension View {
    @ViewBuilder
    public func textFieldInsets(_ insets: EdgeInsets) -> some View {
        self.modifier(TextFieldInsetsModifier(insets: insets))
    }

    @ViewBuilder
    public func textFieldInsets(_ length: CGFloat) -> some View {
        self.textFieldInsets(
            EdgeInsets(
                top: length,
                leading: length,
                bottom: length,
                trailing: length
            )
        )
    }
}

private struct TextFieldInsetsModifier: ViewModifier {
    @Weak
    private var view: (UIView & FocusableTextInput)?

    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .introspectTextField { view = $0 }
            .introspectTextView { view = $0 }
            .padding(insets)
            .background(LocatedTap(in: view) { point in
                guard let view = view else { return }
                let newPosition = view.closestPosition(to: point) ?? view.endOfDocument
                view.becomeFirstResponder()
                view.selectedTextRange = view.textRange(from: newPosition, to: newPosition)
            })
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

@objc private protocol FocusableTextInput: UITextInput {
    @discardableResult
    func becomeFirstResponder() -> Bool
    var isFirstResponder: Bool { get }
}

extension UITextField: FocusableTextInput {}
extension UITextView: FocusableTextInput {}

private struct LocatedTap: UIViewRepresentable {
    var localView: () -> UIView?
    var handler: (CGPoint) -> Void

    init(
        in localView: @escaping @autoclosure () -> UIView?,
        handler: @escaping (CGPoint) -> Void
    ) {
        self.localView = localView
        self.handler = handler
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.tapped)
            )
        )
        return view
    }

    final class Coordinator: NSObject {
        var localView: () -> UIView?
        var handler: (CGPoint) -> Void

        init(
            localView: @escaping () -> UIView?,
            handler: @escaping (CGPoint) -> Void
        ) {
            self.localView = localView
            self.handler = handler
        }

        @objc func tapped(gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: localView() ?? gesture.view)
            self.handler(point)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(localView: localView, handler: handler)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct TextFieldInsets_Previews: PreviewProvider {
    static var previews: some View {
        TextField("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
            .textFieldInsets(32)
            .background(Color.red)
            .previewLayout(.sizeThatFits)
    }
}