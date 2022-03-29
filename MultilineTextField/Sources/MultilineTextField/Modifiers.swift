import SwiftUI

extension View {
    public func paragraphSpacing(_ paragraphSpacing: CGFloat) -> some View {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = paragraphSpacing
        return multilineTextFieldAttributes([.paragraphStyle: paragraphStyle])
    }

    public func multilineTextFieldAttributes(_ attributes: [NSAttributedString.Key: Any]) -> some View {
        self.transformEnvironment(\.multilineTextFieldAttributes) { current in
            current.merge(attributes, uniquingKeysWith: { old, new in new })
        }
    }
}
