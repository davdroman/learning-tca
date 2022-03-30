import Introspect
import SwiftUI

extension View {
    @ViewBuilder
    public func textFieldPadding(_ insets: EdgeInsets) -> some View {
        transformUITextFieldPadding {
            $0.top = insets.top
            $0.left = insets.leading
            $0.bottom = insets.bottom
            $0.right = insets.trailing
        }
    }

    @ViewBuilder
    public func textFieldPadding(_ length: CGFloat) -> some View {
        transformUITextFieldPadding {
            $0.top = length
            $0.left = length
            $0.bottom = length
            $0.right = length
        }
    }

    private func transformUITextFieldPadding(_ transform: @escaping (inout UIEdgeInsets) -> Void) -> some View {
        self.introspectTextField {
            var insets = $0.textRectInsets ?? UIEdgeInsets()
            transform(&insets)
            $0.textRectInsets = insets
        }
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
