import ComposableArchitecture
import TextFieldPadding
import SwiftUI
import SwiftUIInput

struct Todo: Equatable, Identifiable {
	var id: UUID
	var description: String
	var dueDate: Date?
	var isComplete = false
}

@Reducer
struct TodoRow {
	@ObservableState
	struct State: Equatable, Identifiable {
		enum FocusedField: Equatable {
			case description
			case dueDate
		}
		
		var id: Todo.ID { todo.id }
		var todo: Todo
		var focus: FocusedField?

		init(todo: Todo, focus: FocusedField? = nil) {
			self.todo = todo
			self.focus = focus
		}

		var showDueDate: Bool {
			todo.dueDate != nil || focus != nil
		}
	}
	
	enum Action {
		case setFocus(State.FocusedField?)
		case textFieldDidChange(String)
		case dueDateDidChange(Date)
		case checkboxTapped
	}
	
	@Dependency(\.date.now) var now
	
	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .setFocus(let newFocus):
				if state.todo.dueDate == nil, newFocus == .dueDate {
					state.todo.dueDate = now
				}
				state.focus = newFocus
				return .none
			case .textFieldDidChange(let text):
				state.todo.description = text
				return .none
			case .dueDateDidChange(let date):
				state.todo.dueDate = date
				return .none
			case .checkboxTapped:
				state.todo.isComplete.toggle()
				return .none
			}
		}
	}
}

struct TodoRowView: View {
	@Bindable var store: StoreOf<TodoRow>

	@FocusState private var focus: TodoRow.State.FocusedField?
	
	var body: some View {
		HStack {
			Button(action: { store.send(.checkboxTapped, animation: .default) }) {
				Image(systemName: store.todo.isComplete ? "checkmark.square" : "square")
			}
			.buttonStyle(.plain)

			VStack(alignment: .leading, spacing: 0) {
				TextField(
					"Untitled todo",
					text: $store.todo.description.sending(\.textFieldDidChange),
					axis: .vertical
				)
				.focused($focus, equals: .description)
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
					.focused($focus, equals: .dueDate)
					.textFieldPadding(.top, 4)
					.textFieldPadding(.horizontal, 2)
					.input(.datePicker($store.todo.dueDate.nowIfNil.sending(\.dueDateDidChange)))
					.inputAccessory(.default)
				}
			}
			.disabled(store.todo.isComplete)
			.font(.custom("whatever it takes", size: 23))
			.offset(y: 2) // slight offset to counter the font's natural y offset
		}
		.opacity(store.todo.isComplete ? 0.5 : 1)
		.bind($store.focus.sending(\.setFocus), to: $focus)
	}
}

extension Optional where Wrapped == Date {
	var nowIfNil: Date {
		self ?? .now
	}
}

struct TodoRowView_Previews: PreviewProvider {
	static var previews: some View {
		let states = [
			TodoRow.State(
				todo: Todo(id: UUID(), description: "", isComplete: false)
			),
			TodoRow.State(
				todo: Todo(id: UUID(), description: "Milk", isComplete: false)
			),
			TodoRow.State(
				todo: Todo(id: UUID(), description: "Milk", isComplete: true)
			),
		]
		ForEach(states) { state in
			TodoRowView(
				store: Store(initialState: state) {
					TodoRow()
				}
			)
		}
		.padding()
		.background(Color(.systemBackground))
		.environment(\.colorScheme, .dark)
		.previewLayout(.sizeThatFits)
	}
}
