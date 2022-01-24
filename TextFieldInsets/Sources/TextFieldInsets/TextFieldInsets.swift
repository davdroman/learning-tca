import Introspect
import SwiftUI

extension View {
    @ViewBuilder
    public func textFieldInsets(_ insets: EdgeInsets) -> some View {
        self.modifier(TextFieldInsetsModifier(insets: insets))
    }
}

private struct TextFieldInsetsModifier: ViewModifier {
    @Weak
    private var view: FocusableTextInput?

    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .introspectTextField { view = $0 }
            .introspectTextView { view = $0 }
            .padding(insets)
            .contentShape(Rectangle())
            .onTapGesture {
                guard
                    let view = view,
                    !view.isFirstResponder
                else {
                    return
                }
                let newPosition = view.endOfDocument
                view.becomeFirstResponder()
                view.selectedTextRange = view.textRange(from: newPosition, to: newPosition)
            }
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

struct TextFieldInsets_Previews: PreviewProvider {
    static var previews: some View {
        TextField("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
            .textFieldInsets(.init(top: 32, leading: 32, bottom: 32, trailing: 32))
            .background(Color.red)
            .previewLayout(.sizeThatFits)
    }
}
