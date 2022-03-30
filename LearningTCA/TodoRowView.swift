import ComposableArchitecture
import IdentifiedCollections
import KeyboardToolbar
import TextArea
import TextFieldInsets
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

                TextArea(
                    "Untitled todo",
                    text: viewStore.binding(get: \.todo.description, send: TodoRowAction.textFieldDidChange)
                )
                .textAreaPadding(.vertical, 12)
                .textAreaPadding(.horizontal, 2)
                .textAreaScrollDisabled(true)
                .textAreaParagraphSpacing(12)
                .keyboardToolbar()
                .focused($isFocused)
                .disabled(viewStore.todo.isComplete)
                .font(.custom("whatever it takes", size: 22))
                .offset(y: 2) // slight offset to counter the font's natural y offset
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
        let states = [
            TodoRowState(
                todo: Todo(id: UUID(), description: "", isComplete: false),
                isFocused: false
            ),
            TodoRowState(
                todo: Todo(id: UUID(), description: "Milk", isComplete: false),
                isFocused: false
            ),
            TodoRowState(
                todo: Todo(id: UUID(), description: "Milk", isComplete: true),
                isFocused: false
            ),
        ]
        ForEach(states) { state in
            TodoRowView(
                store: Store(
                    initialState: state,
                    reducer: todoReducer,
                    environment: TodoRowEnvironment()
                )
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
