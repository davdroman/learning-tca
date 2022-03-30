import Introspect
import SwiftUI

extension View {
    @ViewBuilder
    public func textFieldPadding(_ insets: EdgeInsets) -> some View {
        Group {
            if self.isTextFieldPaddingModifierApplied {
                self
            } else {
                self.modifier(TextFieldPaddingModifier())
            }
        }
        .environment(\.textFieldPadding, insets)
    }

    @ViewBuilder
    public func textFieldPadding(_ length: CGFloat) -> some View {
        self.textFieldPadding(
            EdgeInsets(
                top: length,
                leading: length,
                bottom: length,
                trailing: length
            )
        )
    }
}

private extension View {
    // TODO: strengthen this logic somehow... maybe through reflection?
    var isTextFieldPaddingModifierApplied: Bool {
        let modifierTypeName = String(describing: TextFieldPaddingModifier.self)
        let currentTypeName = String(describing: type(of: self))
        return currentTypeName.contains(modifierTypeName)
    }
}

private struct TextFieldPaddingModifier: ViewModifier {
    @Environment(\.textFieldPadding)
    private var padding

    func body(content: Content) -> some View {
        content
            .introspectTextField {
                $0.textRectInsets = UIEdgeInsets(
                    top: padding.top,
                    left: padding.leading,
                    bottom: padding.bottom,
                    right: padding.trailing
                )
            }
    }
}

private extension EnvironmentValues {
    var textFieldPadding: EdgeInsets {
        get { self[TextFieldPaddingKey.self] }
        set { self[TextFieldPaddingKey.self] = newValue }
    }

    struct TextFieldPaddingKey: EnvironmentKey {
        static let defaultValue: EdgeInsets = .init()
    }
}

struct TextFieldPadding_Previews: PreviewProvider {
    static var previews: some View {
        TextField("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
            .background(Color.blue)
            .textFieldPadding(30)
            .background(Color.red)
            .previewLayout(.sizeThatFits)
    }
}
