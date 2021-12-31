import ComposableArchitecture
import IdentifiedCollections
import KeyboardToolbar
import MultilineTextField
import SwiftUI

struct Todo: Equatable, Identifiable {
    var id: UUID
    var description: String
    var isComplete = false
}

struct TodoRowState: Equatable, Identifiable {
    var id: Todo.ID { todo.id }
    var todo: Todo
    @BindableState
    var isFocused: Bool
}

enum TodoRowAction: BindableAction, Equatable {
    case binding(BindingAction<TodoRowState>)
    case textFieldDidChange(String)
    case checkboxTapped
}

struct TodoRowEnvironment {}

let todoReducer = Reducer<TodoRowState, TodoRowAction, TodoRowEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .textFieldDidChange(let text):
        state.todo.description = text
        return .none
    case .checkboxTapped:
        state.todo.isComplete.toggle()
        return .none
    }
}
.binding()

struct TodoRowView: View {
    let store: Store<TodoRowState, TodoRowAction>

    @FocusState private var isFocused: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped, animation: .default) }) {
                    Image(systemName: viewStore.todo.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)

                MultilineTextField(
                    "Untitled todo",
                    text: viewStore.binding(get: \.todo.description, send: TodoRowAction.textFieldDidChange)
                )
//                TextField(
//                    "Untitled todo",
//                    text: viewStore.binding(get: \.todo.description, send: TodoRowAction.textFieldDidChange)
//                )
                .keyboardToolbar { endEditing in
                    UIBarButtonItem.flexibleSpace()
                    UIBarButtonItem(systemItem: .done, primaryAction: endEditing)
                }
//                .font(.largeTitle)
                .foregroundColor(.red)
                .focused($isFocused)
                .disabled(viewStore.todo.isComplete)
            }
            .foregroundColor(viewStore.todo.isComplete ? .gray : nil)
            .synchronize(viewStore.binding(\.$isFocused), $isFocused)
        }
    }
}

extension View {
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self.onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}

struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TodoRowView(
                store: Store(
                    initialState: .init(
                        todo: Todo(id: UUID(), description: "Milk", isComplete: true),
                        isFocused: false
                    ),
                    reducer: todoReducer,
                    environment: TodoRowEnvironment()
                )
            )
            TodoRowView(
                store: Store(
                    initialState: .init(
                        todo: Todo(id: UUID(), description: "", isComplete: true),
                        isFocused: false
                    ),
                    reducer: todoReducer,
                    environment: TodoRowEnvironment()
                )
            )
        }
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
