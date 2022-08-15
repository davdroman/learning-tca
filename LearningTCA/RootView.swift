import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct Root: ReducerProtocol {
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
    @Dependency(\.mainQueue) var mainQueue

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let newTodo = Todo(id: uuid(), description: "")
                state.todos.insert(newTodo, at: 0)
                return Effect(value: .todo(id: newTodo.id, action: .setFocus(.description)))
                    .deferred(for: 0, scheduler: mainQueue)

            case .todo(let id, .setFocus(let field)):
                if let field = field {
                    state.focus = .init(id: id, field: field)
                } else if state.focus?.id == id {
                    state.focus = nil
                }
                return .none

            case .todo(id: _, action: .checkboxTapped):
                struct CancelID: Hashable {}

                return Effect(value: .sortCompletedTodos)
                    .debounce(id: CancelID(), for: 1, scheduler: mainQueue.animation(.default))

            case .todo:
                return .none

            case .sortCompletedTodos:
                state.todos = IdentifiedArray(uniqueElements:
                    state.todos.enumerated().sorted {
                        (!$0.element.isComplete && $1.element.isComplete) || $0.offset < $1.offset
                    }
                    .map(\.element)
                )
                return .none
            }
        }
        .forEach(\.todoRowStates, action: /Action.todo, TodoRow.init)
    }
}

struct RootView: View {
    let store: StoreOf<Root>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(state: \.todoRowStates, action: Root.Action.todo),
                        content: TodoRowView.init
                    )
                }
                .listStyle(.plain)
                .navigationTitle("Todos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            viewStore.send(.addButtonTapped, animation: .default)
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
                ),
                reducer: Root()
            )
        )
    }
}
