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

// MARK: textAreaPadding

extension View {
    public func textAreaPadding(_ insets: EdgeInsets) -> some View {
        environment(\.textAreaPadding, insets)
    }

    public func textAreaPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        transformEnvironment(\.textAreaPadding) { padding in
            // as per https://developer.apple.com/documentation/uikit/uitextview/1618619-textcontainerinset
            func defaultLength(for edge: Edge) -> CGFloat {
                switch edge {
                case .top, .bottom:
                    return 8
                case .leading, .trailing:
                    return 0
                }
            }

            for edge in edges.allEdges {
                switch edge {
                case .top:
                    padding.top = length ?? defaultLength(for: .top)
                case .bottom:
                    padding.bottom = length ?? defaultLength(for: .bottom)
                case .leading:
                    padding.leading = length ?? defaultLength(for: .leading)
                case .trailing:
                    padding.trailing = length ?? defaultLength(for: .trailing)
                }
            }
        }
    }

    public func textAreaPadding(_ length: CGFloat) -> some View {
        environment(\.textAreaPadding, EdgeInsets(top: length, leading: length, bottom: length, trailing: length))
    }
}

private extension Edge.Set {
    var allEdges: Set<Edge> {
        var edges: Set<Edge> = []

        if self.contains(.top) { edges.insert(.top) }
        if self.contains(.bottom) { edges.insert(.bottom) }
        if self.contains(.leading) { edges.insert(.leading) }
        if self.contains(.trailing) { edges.insert(.trailing) }
        if self.contains(.vertical) { edges.formUnion([.top, .bottom]) }
        if self.contains(.horizontal) { edges.formUnion([.leading, .trailing]) }
        if self.contains(.all) { edges.formUnion([.top, .bottom, .leading, .trailing]) }

        return edges
    }
}

extension EnvironmentValues {
    var textAreaPadding: EdgeInsets {
        get { self[TextAreaPaddingKey.self] }
        set { self[TextAreaPaddingKey.self] = newValue }
    }

    private struct TextAreaPaddingKey: EnvironmentKey {
        static let defaultValue: EdgeInsets = .init()
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