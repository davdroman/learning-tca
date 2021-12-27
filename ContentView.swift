import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct Todo: Equatable, Identifiable {
    var id: UUID
    var description = ""
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {

}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: IdentifiedArrayOf<Todo>
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Todo.ID, action: TodoAction)
    case sortCompletedTodos
}

struct AppEnvironment {
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo,
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none

        case .todo(index: _, action: .checkboxTapped):
            struct CancelID: Hashable {}

            return Effect(value: AppAction.sortCompletedTodos)
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
//.debug()

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(state: \.todos, action: AppAction.todo),
                        content: TodoView.init
                    )
                    .listStyle(.plain)
                }
                .navigationTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped, animation: .default)
                })
            }
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped, animation: .default) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)

                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: { .textFieldChanged($0) }
                    )
                )
                .disabled(viewStore.isComplete)
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
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
                    uuid: UUID.init,
                    mainQueue: .main
                )
            )
        )
    }
}
