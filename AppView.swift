import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct AppState: Equatable {
    struct TodoFocus: Equatable {
        var id: Todo.ID
        var field: TodoRowState.FocusedField
    }

    var todos: IdentifiedArrayOf<Todo>
    var focus: TodoFocus?
}

extension AppState {
    var todoRowStates: IdentifiedArrayOf<TodoRowState> {
        get {
            IdentifiedArray(
                uniqueElements: todos.map {
                    TodoRowState(
                        todo: $0,
                        focus: focus?.id == $0.id ? focus?.field : nil
                    )
                }
            )
        }
        set(newTodoRowStates) {
            todos = IdentifiedArray(uniqueElements: newTodoRowStates.map(\.todo))
            if let focusedTodo = newTodoRowStates.first(where: { $0.focus != nil }), let field = focusedTodo.focus {
                focus = .init(id: focusedTodo.id, field: field)
            } else {
                focus = nil
            }
        }
    }
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(id: Todo.ID, action: TodoRowAction)
    case setFocus(AppState.TodoFocus?)
    case sortCompletedTodos
}

struct AppEnvironment {
    var now: () -> Date
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension AppEnvironment {
    var todoRowEnvironment: TodoRowEnvironment {
        TodoRowEnvironment(
            now: now,
            mainQueue: mainQueue
        )
    }
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todoRowStates,
        action: /AppAction.todo,
        environment: \.todoRowEnvironment
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            let newTodo = Todo(id: environment.uuid(), description: "")
            state.todos.insert(newTodo, at: 0)
            return Effect(value: .setFocus(.init(id: newTodo.id, field: .description)))
                .deferred(for: 0, scheduler: environment.mainQueue)

        case .setFocus(let focus):
            state.focus = focus
            return .none

        case .todo(id: _, action: .checkboxTapped):
            struct CancelID: Hashable {}

            return Effect(value: .sortCompletedTodos)
                .debounce(id: CancelID(), for: 1, scheduler: environment.mainQueue.animation(.default))

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
)

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(state: \.todoRowStates, action: AppAction.todo),
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

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    todos: [
                        Todo(id: UUID(), description: "Milk"),
                        Todo(id: UUID(), description: "Eggs"),
                        Todo(id: UUID(), description: "Hand soap", isComplete: true),
                    ]
                ),
                reducer: appReducer,
                environment: AppEnvironment(
                    now: Date.init,
                    uuid: UUID.init,
                    mainQueue: .main
                )
            )
        )
    }
}
