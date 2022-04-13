import ComposableArchitecture
@testable import LearningTCA
import XCTest

final class TodosTests: XCTestCase {
    func testCompletingTodo() {
        let state = AppState(todos: [
            Todo(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                description: "Milk",
                isComplete: false
            ),
        ])
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                now: { fatalError("unimplemented") },
                uuid: { fatalError("unimplemented") },
                mainQueue: .immediate
            )
        )

        store.send(.todo(id: state.todos[0].id, action: .checkboxTapped)) {
            $0.todos[id: state.todos[0].id]?.isComplete = true
        }
        store.receive(.sortCompletedTodos)
    }

    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(todos: []),
            reducer: appReducer,
            environment: AppEnvironment(
                now: { fatalError("unimplemented") },
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! },
                mainQueue: .immediate
            )
        )
        store.send(.addButtonTapped) {
            $0.todos = [
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    description: "",
                    isComplete: false
                )
            ]
        }
        store.receive(.setFocus(.init(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, field: .description))) {
            $0.focus = .init(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, field: .description)
        }
    }

    func testTodoSorting() {
        let state = AppState(todos: [
            Todo(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                description: "Milk",
                isComplete: false
            ),
            Todo(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                description: "Eggs",
                isComplete: false
            ),
        ])
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                now: { fatalError("unimplemented") },
                uuid: { fatalError("unimplemented") },
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )

        store.send(.todo(id: state.todos[0].id, action: .checkboxTapped)) {
            $0.todos = [
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description: "Milk",
                    isComplete: true
                ),
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description: "Eggs",
                    isComplete: false
                ),
            ]
        }
        scheduler.advance(by: 1)
        store.receive(.sortCompletedTodos) {
            $0.todos = [
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description: "Eggs",
                    isComplete: false
                ),
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description: "Milk",
                    isComplete: true
                ),
            ]
        }
    }
}
