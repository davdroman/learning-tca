import SwiftUI

extension View {
    public func paragraphSpacing(_ paragraphSpacing: CGFloat) -> some View {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = paragraphSpacing
        return textAreaAttributes([.paragraphStyle: paragraphStyle])
    }

    public func textAreaAttributes(_ attributes: [NSAttributedString.Key: Any]) -> some View {
        self.transformEnvironment(\.textAreaAttributes) { current in
            current.merge(attributes, uniquingKeysWith: { old, new in new })
        }
    }
}
