import ComposableArchitecture
import SwiftUI

@Reducer
struct Root {
	@ObservableState
	struct State: Equatable {
		typealias Focus = Identified<Todo.ID, TodoRow.State.Field>

		var todos: IdentifiedArrayOf<Todo>
		var focus: Focus?

		init(todos: IdentifiedArrayOf<Todo>, focus: Focus? = nil) {
			self.todos = todos
			self.focus = focus
		}

		var todoRowStates: IdentifiedArrayOf<TodoRow.State> {
			get {
				IdentifiedArray(
					uniqueElements: todos.map {
						TodoRow.State(
							todo: $0,
							focus: $0.id == focus?.id ? focus?.value : nil
						)
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
					state.focus = Identified(field, id: id)
				} else if state.focus?.id == id {
					state.focus = nil
				}
				return .none

			case .todo:
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
			List(store.scope(state: \.todoRowStates, action: \.todo)) {
				TodoRowView(store: $0)
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
