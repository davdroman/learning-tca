import CombineSchedulers
import ComposableArchitecture
import IdentifiedCollections
import TextArea
import TextFieldPadding
import SwiftUI
import SwiftUIInput

struct Todo: Equatable, Identifiable {
    var id: UUID
    var description: String
    var dueDate: Date?
    var isComplete = false
}

struct TodoRowState: Equatable, Identifiable {
    enum FocusedField: Hashable {
        case description
        case dueDate
    }

    var id: Todo.ID { todo.id }
    var todo: Todo
    @BindableState
    var focus: FocusedField?

    var showDueDate: Bool {
        todo.dueDate != nil || focus != nil
    }
}

enum TodoRowAction: Equatable {
    case focusDidChange(TodoRowState.FocusedField?)
    case setFocus(TodoRowState.FocusedField?)
    case textFieldDidChange(String)
    case dueDateDidChange(Date)
    case checkboxTapped
}

struct TodoRowEnvironment {
    var now: () -> Date
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let todoReducer = Reducer<TodoRowState, TodoRowAction, TodoRowEnvironment> { state, action, environment in
    switch action {
    case .focusDidChange(let newFocus):
        if state.focus == nil, newFocus != nil {
            return Effect(value: TodoRowAction.setFocus(newFocus))
                .deferred(for: 0, scheduler: environment.mainQueue)
        } else {
            return Effect(value: TodoRowAction.setFocus(newFocus))
        }
    case .setFocus(let newFocus):
        if state.todo.dueDate == nil, newFocus == .dueDate {
            state.todo.dueDate = environment.now()
        }
        state.focus = newFocus
        return .none
    case .textFieldDidChange(let text):
        state.todo.description = text
        return .none
    case .dueDateDidChange(let date):
        state.todo.dueDate = date
        return .none
    case .checkboxTapped:
        state.todo.isComplete.toggle()
        return .none
    }
}

struct TodoRowView: View {
    let store: Store<TodoRowState, TodoRowAction>

    @FocusState private var focus: TodoRowState.FocusedField?

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped, animation: .default) }) {
                    Image(systemName: viewStore.todo.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 0) {
                    TextArea(
                        "Untitled todo",
                        text: viewStore.binding(get: \.todo.description, send: TodoRowAction.textFieldDidChange)
                    )
                    .animationDisabled()
                    .focused($focus, equals: .description)
                    .textAreaScrollDisabled(true)
                    .textAreaPadding(.top, 12)
                    .textAreaPadding(.bottom, viewStore.showDueDate ? 4 : 12)
                    .textAreaPadding(.horizontal, 2)
                    .textAreaParagraphStyle(\.paragraphSpacing, 12)
                    .inputAccessory(.default)

                    if viewStore.showDueDate {
                        TextField(
                            "Due date",
                            text: .constant(viewStore.todo.dueDate?.formatted(.dateTime) ?? "")
                        )
                        .foregroundColor(.gray)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        .focused($focus, equals: .dueDate)
                        .textFieldPadding(.top, 4)
                        .textFieldPadding(.bottom, 12)
                        .textFieldPadding(.horizontal, 2)
                        .input(.datePicker(viewStore.binding(get: \.todo.dueDate.nowIfNil, send: TodoRowAction.dueDateDidChange)))
                        .inputAccessory(.default)
                    }
                }
                .disabled(viewStore.todo.isComplete)
                .font(.custom("whatever it takes", size: 23))
                .offset(y: 2) // slight offset to counter the font's natural y offset
            }
            .opacity(viewStore.todo.isComplete ? 0.5 : 1)
            .synchronize(viewStore.binding(get: \.focus, send: TodoRowAction.focusDidChange), $focus)
            .animation(.spring(), value: viewStore.showDueDate)
        }
    }
}

extension View {
    func animationDisabled(_ isDisabled: Bool = true) -> some View {
        transaction {
            if isDisabled {
                $0.animation = nil
            }
        }
    }
}

extension Optional where Wrapped == Date {
    var nowIfNil: Date {
        self ?? .now
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
                todo: Todo(id: UUID(), description: "", isComplete: false)
            ),
            TodoRowState(
                todo: Todo(id: UUID(), description: "Milk", isComplete: false)
            ),
            TodoRowState(
                todo: Todo(id: UUID(), description: "Milk", isComplete: true)
            ),
        ]
        ForEach(states) { state in
            TodoRowView(
                store: Store(
                    initialState: state,
                    reducer: todoReducer,
                    environment: TodoRowEnvironment(
                        now: Date.init,
                        mainQueue: .main
                    )
                )
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
