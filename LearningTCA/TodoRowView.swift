import ComposableArchitecture
import IdentifiedCollections
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

import Introspect
import SwiftUI

struct MultilineTextField: View {
    private var placeholder: String
    @Binding
    private var text: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: .constant(""))
                .hidden()
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextFieldHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )

            Text(text)
                .hidden()
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.tertiaryLabel))
            }

            TextEditor(text: $text)
                .frame(height: max(textFieldHeight, textHeight))
                .introspectTextView {
                    $0.isScrollEnabled = false
                    $0.backgroundColor = .clear
                    $0.textContainerInset = .zero
                    $0.textContainer.lineFragmentPadding = .zero
                }
        }
        .onPreferenceChange(TextFieldHeightKey.self) {
            textFieldHeight = $0
        }
        .onPreferenceChange(TextHeightKey.self) {
            textHeight = $0
        }
    }

    @State private var textFieldHeight: CGFloat = 0
    @State private var textHeight: CGFloat = 0
}

private struct TextFieldHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

private struct TextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
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
