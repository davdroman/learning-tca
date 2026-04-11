import ComposableArchitecture2
import TextFieldPadding
import Sharing
import SwiftUI
import SwiftUIInput
import SwiftUINavigation

struct Todo: Equatable, Identifiable {
	var id: UUID
	var description: String
	var dueDate: Date?
	var isComplete = false
}

@Feature
struct TodoRow {
	struct State: Identifiable {
		var id: Todo.ID { todo.id }
		var todo: Todo
		@Shared var focus: Focus?

		init(todo: Todo, focus: Shared<Focus?>) {
			self.todo = todo
			self._focus = focus
		}

		var focusedField: Focus.Field? {
			focus?.id == todo.id ? focus?.field : nil
		}

		var showDueDate: Bool {
			todo.dueDate != nil || focusedField != nil
		}
	}

	struct Focus: Hashable {
		var id: Todo.ID
		var field: Field

		enum Field {
			case description
			case dueDate
		}
	}

	enum Action {
		case checkboxTapped
	}
	
	@Dependency(\.date) var now

	var body: some Feature {
		Update { state, action in
			switch action {
			case .checkboxTapped:
				withAnimation(.default) {
					state.todo.isComplete.toggle()
				}
			}
		}
		.onChange(of: store.focus) { oldValue, state in
			if
				state.todo.dueDate == nil,
				state.focusedField == .dueDate
			{
				state.todo.dueDate = now()
			}
		}
	}
}
struct TodoRowView: View {
	@Bindable var store: StoreOf<TodoRow>
	var focus: FocusState<TodoRow.Focus?>.Binding

	var body: some View {
		HStack {
			Button(action: { store.send(.checkboxTapped) }) {
				Image(systemName: store.todo.isComplete ? "checkmark.square" : "square")
			}
			.buttonStyle(.plain)

			VStack(alignment: .leading, spacing: 0) {
				TextField(
					"Untitled todo",
					text: $store.todo.description,
					axis: .vertical
				)
				.focused(focus, equals: TodoRow.Focus(id: store.todo.id, field: .description))
//				.textAreaScrollDisabled(true)
//				.textAreaPadding(.top, 12)
//				.textAreaPadding(.bottom, viewStore.showDueDate ? 4 : 12)
//				.textAreaPadding(.horizontal, 2)
//				.textAreaParagraphStyle(\.paragraphSpacing, 12)
				.inputAccessory(.default)

				if store.showDueDate {
					TextField(
						"Due date",
						text: .constant(store.todo.dueDate?.formatted(.dateTime) ?? "")
					)
					.foregroundColor(.gray)
					.focused(focus, equals: TodoRow.Focus(id: store.todo.id, field: .dueDate))
					.textFieldPadding(.top, 4)
					.textFieldPadding(.horizontal, 2)
					.input(.datePicker($store.todo.dueDate.defaulting(.now)))
					.inputAccessory(.default)
				}
			}
			.disabled(store.todo.isComplete)
			.font(.custom("whatever it takes", size: 23))
			.offset(y: 2) // slight offset to counter the font's natural y offset
		}
		.opacity(store.todo.isComplete ? 0.5 : 1)
	}
}

extension Binding {
	func defaulting<Wrapped>(
		_ defaultValue: @Sendable @escaping @autoclosure () -> Wrapped
	) -> Binding<Wrapped> where Value == Wrapped?, Value: Sendable {
		Binding<Wrapped>(
			get: { self.wrappedValue ?? defaultValue() },
			set: { self.wrappedValue = $0 }
		)
	}
}

#Preview {
	@Previewable @FocusState var focus: TodoRow.Focus?
	@Previewable @State var stores: [StoreOf<TodoRow>] = {
		@Shared(.inMemory("focus")) var focus: TodoRow.Focus? = nil
		return [
			TodoRow.State(todo: Todo(id: UUID(), description: "", isComplete: false), focus: $focus),
			TodoRow.State(todo: Todo(id: UUID(), description: "Milk", isComplete: false), focus: $focus),
			TodoRow.State(todo: Todo(id: UUID(), description: "Milk", isComplete: true), focus: $focus),
		]
		.map { Store(initialState: $0, feature: TodoRow.init) }
	}()

	ForEach(stores) { store in
		TodoRowView(store: store, focus: $focus)
	}
	.padding()
	.background(Color(.systemBackground))
	.environment(\.colorScheme, .dark)
}
