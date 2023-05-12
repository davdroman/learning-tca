import SwiftUI

public protocol Input: View {}

public struct DatePickerInput: Input {
	@Environment(\.inputEndEditing)
	private var endEditing
	@Binding
	private var selection: Date
	
	public init(selection: Binding<Date>) {
		self._selection = selection
	}
	
	public var body: some View {
		ZStack {
			DatePicker("", selection: $selection)
				.datePickerStyle(.wheel)
				.labelsHidden()
		}
		.frame(maxWidth: .infinity)
		.background(Color(.secondarySystemBackground))
	}
}

extension Input where Self == DatePickerInput {
	public static func datePicker(_ selection: Binding<Date>) -> DatePickerInput {
		DatePickerInput(selection: selection)
	}
}

extension View {
	@ViewBuilder
	public func input<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
		self.modifier(Modifier(\.inputView, content))
	}
	
	@ViewBuilder
	public func input<Content: Input>(_ content: Content) -> some View {
		input { content }
	}
}
