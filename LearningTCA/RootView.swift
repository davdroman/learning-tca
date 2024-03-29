import ComposableArchitecture
import SwiftUI

@Reducer
struct Root {
	struct State: Equatable {
		@ObservableState
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

	enum Action {
		case addButtonTapped
		case todo(IdentifiedActionOf<TodoRow>)
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
					await send(.todo(.element(id: newTodo.id, action: .setFocus(.description))))
				}

			case .todo(.element(let id, .setFocus(let field))):
				if let field = field {
					state.focus = .init(id: id, field: field)
				} else if state.focus?.id == id {
					state.focus = nil
				}
				return .none

			case .todo(.element(id: _, action: .checkboxTapped)):
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
		.forEach(\.todoRowStates, action: \.todo) {
			TodoRow()
		}
	}
}

struct RootView: View {
	let store: StoreOf<Root>

	var body: some View {
		NavigationView {
			List {
				ForEachStore(store.scope(state: \.todoRowStates, action: \.todo)) { // TODO: ForEachStore -> ForEach
					TodoRowView(store: $0)
				}
			}
			.listStyle(.plain)
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle("Todos")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						store.send(.addButtonTapped, animation: .default)
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
