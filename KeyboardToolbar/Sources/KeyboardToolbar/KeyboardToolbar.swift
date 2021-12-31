import Introspect
import SwiftUI

@resultBuilder
public struct UIBarButtonItemBuilder {
    public typealias Element = UIBarButtonItem
    public typealias Array = Swift.Array<Element>

    public static func buildArray(_ arrays: [Array]) -> Array { arrays.reduce([], +) }
    public static func buildBlock(_ arrays: Array...) -> Array { arrays.reduce([], +) }
    public static func buildEither(first array: Array) -> Array { array }
    public static func buildEither(second array: Array) -> Array { array }
    public static func buildExpression(_ element: Element) -> Array { [element] }
    public static func buildLimitedAvailability(_ array: Array) -> Array { array }
    public static func buildOptional(_ array: Array?) -> Array { array ?? [] }
}

extension View {
    @ViewBuilder
    public func keyboardToolbar(@UIBarButtonItemBuilder items: @escaping (UIAction) -> [UIBarButtonItem]) -> some View {
        self.modifier(KeyboardToolbarModifier(items: items))
    }
}

struct KeyboardToolbarModifier: ViewModifier {
    @FocusState
    private var isFocused: Bool
    private let items: (UIAction) -> [UIBarButtonItem]
    private var toolbar: UIToolbar {
        UIToolbar.keyboardToolbar(
            items: items(
                UIAction { _ in
                    isFocused = false
                }
            )
        )
    }

    init(@UIBarButtonItemBuilder items: @escaping (UIAction) -> [UIBarButtonItem]) {
        self.items = items
    }

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .introspectTextField { $0.inputAccessoryView = toolbar }
            .introspectTextView { $0.inputAccessoryView = toolbar }
    }
}

extension UIToolbar {
    static func keyboardToolbar(items: [UIBarButtonItem]) -> UIToolbar {
        let bar = UIToolbar()
        bar.items = items
        bar.sizeToFit()
        return bar
    }
}
