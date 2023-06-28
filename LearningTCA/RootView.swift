import ComposableArchitecture
import SwiftUI

struct Root: Reducer {
	struct State: Equatable {
		struct TodoFocus: Equatable {
			var id: Todo.ID
			var field: TodoRow.State.FocusedField
		}

		var todos: IdentifiedArrayOf<Todo>
		var focus: TodoFocus?

		func focusedField(for todo: Todo) -> TodoRow.State.FocusedField? {
			todo.id == focus?.id ? focus?.field : nil
		}

		var todoRowStates: IdentifiedArrayOf<TodoRow.State> {
			get {
				IdentifiedArray(
					uniqueElements: todos.map {
						TodoRow.State(todo: $0, focus: focusedField(for: $0))
					}
				)
			}
			set {
				todos = IdentifiedArray(uniqueElements: newValue.map(\.todo))
			}
		}
	}

	enum Action: Equatable {
		case addButtonTapped
		case todo(id: Todo.ID, action: TodoRow.Action)
		case sortCompletedTodos
	}

	@Dependency(\.uuid) var uuid
	@Dependency(\.continuousClock) var clock

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .addButtonTapped:
				let newTodo = Todo(id: uuid(), description: "")
				state.todos.insert(newTodo, at: 0)
				return .run { send in
					try await clock.sleep(for: .zero) // fixes keyboard not showing
					await send(.todo(id: newTodo.id, action: .setFocus(.description)))
				}

			case .todo(let id, .setFocus(let field)):
				if let field = field {
					state.focus = .init(id: id, field: field)
				} else if state.focus?.id == id {
					state.focus = nil
				}
				return .none

			case .todo(id: _, action: .checkboxTapped):
				struct CancelID: Hashable {}
				return .run { send in
					try await clock.sleep(for: .seconds(1))
					await send(.sortCompletedTodos, animation: .default)
				}
				.cancellable(id: CancelID(), cancelInFlight: true)

			case .todo:
				return .none

			case .sortCompletedTodos:
				state.todos = IdentifiedArray(
					uniqueElements: state.todos.sorted { !$0.isComplete && $1.isComplete }
				)
				return .none
			}
		}
		.forEach(\.todoRowStates, action: /Action.todo) {
			TodoRow()
		}
	}
}

struct RootView: View {
	let store: StoreOf<Root>

	var body: some View {
		NavigationView {
			List {
				ForEachStore(
					store.scope(state: \.todoRowStates, action: Root.Action.todo),
					content: TodoRowView.init
				)
			}
			.listStyle(.plain)
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle("Todos")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						withAnimation(.default) {
							store.send(.addButtonTapped)
						}
					}
				}
			}
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(
			store: Store(
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
		)
	}
}
