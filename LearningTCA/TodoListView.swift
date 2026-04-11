import ComposableArchitecture2
import Sharing
import SwiftUI
import SwiftUINavigation

@Feature
struct TodoList {
	struct State {
		var todos: [Todo]
		@Shared(.inMemory("focus")) var focus: TodoRow.Focus? = nil
		@Trigger var addNewTodo
		@StoreTaskID var sortingTaskID

		var todoRows: [TodoRow.State] {
			get {
				todos.map {
					TodoRow.State(todo: $0, focus: $focus)
				}
			}
			set {
				todos = newValue.map(\.todo)
			}
		}
	}

	enum Action {
		case todoRow(Todo.ID, TodoRow.Action)
	}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.uuid) var uuid

	var body: some Feature {
		Update { state, action in
			switch action {
			case .todoRow(_, .checkboxTapped):
				store.addTask(id: state.sortingTaskID) {
					try await clock.sleep(for: .seconds(1))
					_ = try withAnimation(.default) {
						try store.modify { state in
							state.todos = state.todos.sorted { !$0.isComplete && $1.isComplete }
						}
					}
				}
			}
		}
		.onTrigger(store.addNewTodo) { state in
			let newTodo = Todo(id: uuid(), description: "")
			state.todos.insert(newTodo, at: 0)
			state.$focus.withLock { $0 = .init(id: newTodo.id, field: .description) }
		}
		.forEach(\.todoRows, action: \.todoRow) {
			TodoRow()
		}
	}
}

struct TodoListView: View {
	let store: StoreOf<TodoList>
	@FocusState var focus: TodoRow.Focus?

	var body: some View {
		List(store.scope(state: \.todoRows, action: \.todoRow)) { rowStore in
			TodoRowView(store: rowStore, focus: $focus)
		}
		.bind(Binding(store.$focus), to: $focus)
	}
}

#Preview {
	@Previewable @State var store = Store(
		initialState: TodoList.State(todos: [
			Todo(id: UUID(), description: "", isComplete: false),
			Todo(id: UUID(), description: "Milk", isComplete: false),
			Todo(id: UUID(), description: "Milk", isComplete: true),
		])
	) {
		TodoList()
	}

	TodoListView(store: store)
}
