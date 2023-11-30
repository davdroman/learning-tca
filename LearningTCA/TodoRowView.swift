import ComposableArchitecture
import SwiftUI

@ObservableState
struct Todo: Equatable, Identifiable {
	var id: UUID
	var description: String
	var dueDate: String = ""

	init(id: UUID, description: String, dueDate: String = "") {
		self.id = id
		self.description = description
		self.dueDate = dueDate
	}
}

@Reducer
struct TodoRow {
	@ObservableState
	struct State: Equatable, Identifiable {
		enum Field: Equatable {
			case description
			case dueDate
		}
		
		var id: Todo.ID { todo.id }
		var todo: Todo
		var focus: Field?

		init(todo: Todo, focus: Field? = nil) {
			self.todo = todo
			self.focus = focus
		}

		var showDueDate: Bool {
			!todo.dueDate.isEmpty || focus != nil
		}
	}
	
	enum Action {
		case setFocus(State.Field?)
		case textFieldDidChange(String)
		case dueDateDidChange(String)
	}
	
	@Dependency(\.date.now) var now
	
	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .setFocus(let newFocus):
				if state.todo.dueDate.isEmpty, newFocus == .dueDate {
					state.todo.dueDate = now.formatted(.dateTime)
				}
				state.focus = newFocus
				return .none
			case .textFieldDidChange(let text):
				state.todo.description = text
				return .none
			case .dueDateDidChange(let date):
				state.todo.dueDate = date
				return .none
			}
		}
	}
}

struct TodoRowView: View {
	@Bindable var store: StoreOf<TodoRow>

//	@FocusState private var focus: TodoRow.State.Field?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			TextField(
				"Untitled todo",
				text: $store.todo.description.sending(\.textFieldDidChange),
				axis: .vertical
			)
//			.focused($focus, equals: .description)

			if store.showDueDate {
				TextField(
					"Due date",
					text: $store.todo.dueDate.sending(\.dueDateDidChange)
				)
//				.focused($focus, equals: .dueDate)
			}
		}
//		.bind($store.focus.sending(\.setFocus), to: $focus)
	}
}
