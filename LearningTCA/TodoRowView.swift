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

struct TodoRow: ReducerProtocol {
    struct State: Equatable, Identifiable {
        enum FocusedField: Hashable {
            case description
            case dueDate
        }

        var id: Todo.ID { todo.id }
        var todo: Todo
        var focus: FocusedField?

        var showDueDate: Bool {
            todo.dueDate != nil || focus != nil
        }
    }

    enum Action: Equatable {
        case setFocus(State.FocusedField?)
        case textFieldDidChange(String)
        case dueDateDidChange(Date)
        case checkboxTapped
    }

    @Dependency(\.date.now) var now

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .setFocus(let newFocus):
            if state.todo.dueDate == nil, newFocus == .dueDate {
                state.todo.dueDate = now
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
}

struct TodoRowView: View {
    let store: StoreOf<TodoRow>

    @FocusState private var focus: TodoRow.State.FocusedField?

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
                        text: viewStore.binding(get: \.todo.description, send: TodoRow.Action.textFieldDidChange)
                    )
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
                        .focused($focus, equals: .dueDate)
                        .textFieldPadding(.top, 4)
                        .textFieldPadding(.bottom, 12)
                        .textFieldPadding(.horizontal, 2)
                        .input(.datePicker(viewStore.binding(get: \.todo.dueDate.nowIfNil, send: TodoRow.Action.dueDateDidChange)))
                        .inputAccessory(.default)
                    }
                }
                .disabled(viewStore.todo.isComplete)
                .font(.custom("whatever it takes", size: 23))
                .offset(y: 2) // slight offset to counter the font's natural y offset
            }
            .opacity(viewStore.todo.isComplete ? 0.5 : 1)
            .synchronize(viewStore.binding(get: \.focus, send: TodoRow.Action.setFocus), $focus)
        }
    }
}

extension View {
    func animationDisabled(_ isDisabled: Bool = true) -> some View {
        transaction {
            if isDisabled {
                $0.disablesAnimations = true
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
            TodoRow.State(
                todo: Todo(id: UUID(), description: "", isComplete: false)
            ),
            TodoRow.State(
                todo: Todo(id: UUID(), description: "Milk", isComplete: false)
            ),
            TodoRow.State(
                todo: Todo(id: UUID(), description: "Milk", isComplete: true)
            ),
        ]
        ForEach(states) { state in
            TodoRowView(
                store: Store(
                    initialState: state,
                    reducer: TodoRow()
                )
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
