@_spi(Internals) import SwiftUIIntrospect
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
	public func textFieldPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
		transformUITextFieldPadding { padding in
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
					padding.left = length ?? defaultLength(for: .leading)
				case .trailing:
					padding.right = length ?? defaultLength(for: .trailing)
				}
			}
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
		self.introspect(.textField, on: .iOS(.all)) {
			var insets = $0.textRectInsets ?? UIEdgeInsets()
			transform(&insets)
			$0.textRectInsets = insets
		}
	}
}

extension iOSViewVersion<TextFieldType, UITextField> {
    static let all = Self(for: .init(isCurrent: { true }))
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

struct TextFieldPadding_Previews: PreviewProvider {
	static var previews: some View {
		TextField("Placeholder", text: .constant("Lorem ipsum dolor sit amet"))
			.background(Color.blue)
			.textFieldPadding(.vertical, 15)
			.textFieldPadding(.horizontal, 30)
			.padding(2)
			.background(Color.red)
			.padding()
	}
}
