import SwiftUI

extension View {
    public func multilineTextFieldAttributes(_ attributes: [NSAttributedString.Key: Any]) -> some View {
        self.transformEnvironment(\.multilineTextFieldAttributes) { current in
            current.merge(attributes, uniquingKeysWith: { old, new in new })
        }
    }
}
