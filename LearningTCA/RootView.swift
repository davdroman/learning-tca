import ComposableArchitecture2
import Sharing
import SwiftUI

@Feature
struct Root {
	struct State {
		var todoList = TodoList.State(todos: [])
	}

	enum Action {
		case addButtonTapped
		case todoList(TodoList.Action)
	}

	var body: some Feature {
		Update { state, action in
			switch action {
			case .addButtonTapped:
				state.todoList.addNewTodo()

			case .todoList:
				break
			}
		}
		Scope(state: \.todoList, action: \.todoList) {
			TodoList()
		}
	}
}

struct RootView: View {
	let store: StoreOf<Root>

	var body: some View {
		NavigationStack {
			TodoListView(store: store.scope(state: \.todoList, action: \.todoList))
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
			todoList: TodoList.State(todos: [
				Todo(id: UUID(), description: "Milk"),
				Todo(id: UUID(), description: "Eggs"),
				Todo(id: UUID(), description: "Hand soap", isComplete: true),
			])
		)
	) {
		Root()
	}

	RootView(store: store)
}
