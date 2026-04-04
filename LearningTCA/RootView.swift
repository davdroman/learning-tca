import ComposableArchitecture2
import Sharing
import SwiftUI

@Feature
struct Root {
	struct State {
		var todos: [Todo]
		@Shared(.inMemory("focus")) var focus: TodoRow.Focus? = nil
		@StoreTaskID var todoSorting

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
		case addButtonTapped
		case todoRow(Todo.ID, TodoRow.Action)
	}

	@Dependency(\.uuid) var uuid
	@Dependency(\.continuousClock) var clock

	var body: some Feature {
		Update { state, action in
			switch action {
			case .addButtonTapped:
				let newTodo = Todo(id: uuid(), description: "")
				state.todos.insert(newTodo, at: 0)
				state.$focus.withLock { $0 = .init(id: newTodo.id, field: .description) }

			case .todoRow(_, .checkboxTapped):
				store.addTask(id: state.todoSorting) {
					try await clock.sleep(for: .seconds(1))
					_ = try withAnimation(.default) {
						try store.modify { state in
							state.todos = state.todos.sorted { !$0.isComplete && $1.isComplete }
						}
					}
				}

			case .todoRow(_, .setFocus):
				break
			}
		}
		.forEach(\.todoRows, action: \.todoRow) {
			TodoRow()
		}
	}
}

struct RootView: View {
	let store: StoreOf<Root>

	var body: some View {
		NavigationView {
			List(
				store.scope(state: \.todoRows, action: \.todoRow),
				rowContent: TodoRowView.init
			)
			.listStyle(.plain)
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle("Todos")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						withAnimation {
							_ = store.send(.addButtonTapped)
						}
					}
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var store = Store(
		initialState: Root.State(
			todos: [
				Todo(id: UUID(), description: "Milk"),
				Todo(id: UUID(), description: "Eggs"),
				Todo(id: UUID(), description: "Hand soap", isComplete: true),
			]
		)
	) {
		Root()
	}

	RootView(store: store)
}
