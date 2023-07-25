import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct Modifier<SwiftUIView: View>: ViewModifier {
	@State
	private var hosting: UIHostingController<AnyView>?
	private let keyPath: ReferenceWritableKeyPath<TextContainer, UIView?>
	private let swiftUIView: SwiftUIView
	
	init(
		_ keyPath: ReferenceWritableKeyPath<TextContainer, UIView?>,
		@ViewBuilder _ swiftUIView: () -> SwiftUIView
	) {
		self.keyPath = keyPath
		self.swiftUIView = swiftUIView()
	}
	
	func body(content: Content) -> some View {
		content.introspectTextContainerView(customize: setInputView)
	}
	
	private func setInputView(for container: TextContainerView) {
		guard
			container[keyPath: keyPath] == nil,
			let parent = container.viewController
		else {
			return
		}
		
		let input = swiftUIView.environment(\._inputEndEditing) { [weak container] in
			container?.endEditing(true)
		}
		let hosting = UIHostingController_FB9641883(rootView: AnyView(input))
		hosting.view.translatesAutoresizingMaskIntoConstraints = false
		parent.addChild(hosting)
		container[keyPath: keyPath] = hosting.view
		hosting.didMove(toParent: parent)
		self.hosting = hosting
	}
}

@objc protocol TextContainer: UITextInput {
	var inputView: UIView? { get set }
	var inputAccessoryView: UIView? { get set }
}

extension UITextField: TextContainer {}
extension UITextView: TextContainer {}

typealias TextContainerView = UIView & TextContainer

extension View {
	func introspectTextContainerView(customize: @escaping (TextContainerView) -> ()) -> some View {
        self.introspect(.textField, on: .iOS(.v13...), customize: { customize($0) })
            .introspect(.textEditor, on: .iOS(.v14...), customize: { customize($0) })
	}
}

private extension UIView {
	var nexts: some Sequence<UIResponder> {
		sequence(first: self, next: \.next).dropFirst()
	}

	var viewController: UIViewController? {
		nexts.lazy.compactMap({ $0 as? UIViewController }).first(where: { _ in true })
	}
}

extension EnvironmentValues {
	public var inputEndEditing: () -> Void {
		get { self[InputEndEditingKey.self] }
	}
	
	var _inputEndEditing: () -> Void {
		get { self[InputEndEditingKey.self] }
		set { self[InputEndEditingKey.self] = newValue }
	}
	
	struct InputEndEditingKey: EnvironmentKey {
		static let defaultValue: () -> Void = {}
	}
}
