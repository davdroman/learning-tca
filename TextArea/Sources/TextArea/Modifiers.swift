import SwiftUI

// MARK: textAreaScrollDisabled

extension View {
    public func textAreaScrollDisabled(_ disabled: Bool) -> some View {
        environment(\.textAreaScrollDisabled, disabled)
    }
}

extension EnvironmentValues {
    var textAreaScrollDisabled: Bool {
        get { self[TextAreaScrollDisabledKey.self] }
        set { self[TextAreaScrollDisabledKey.self] = newValue }
    }

    private struct TextAreaScrollDisabledKey: EnvironmentKey {
        static let defaultValue: Bool = false
    }
}

// MARK: textAreaAttributes

extension View {
    public func textAreaParagraphSpacing(_ paragraphSpacing: CGFloat) -> some View {
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

extension EnvironmentValues {
    var textAreaAttributes: [NSAttributedString.Key: Any] {
        get { self[TextAreaAttributesKey.self] }
        set { self[TextAreaAttributesKey.self] = newValue }
    }

    private struct TextAreaAttributesKey: EnvironmentKey {
        static let defaultValue: [NSAttributedString.Key: Any] = [:]
    }
}

// MARK: onSizeChange (internal)

extension View {
    @ViewBuilder
    func onSizeChange(perform action: @escaping () -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { _ in action() }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
