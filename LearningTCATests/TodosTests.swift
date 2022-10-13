import ComposableArchitecture
@testable import LearningTCA
import XCTest

@MainActor
final class TodosTests: XCTestCase {
    func testCompletingTodo() async {
        let state = Root.State(todos: [
            Todo(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                description: "Milk",
                isComplete: false
            ),
        ])
        let store = TestStore(
            initialState: state,
            reducer: Root().dependency(\.mainQueue, .immediate)
        )

        _ = await store.send(.todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .checkboxTapped)) {
            $0.todos[id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!]?.isComplete = true
        }
        await store.receive(.sortCompletedTodos)
    }

    func testAddTodo() async {
        let store = TestStore(
            initialState: Root.State(todos: []),
            reducer: Root()
                .dependency(\.uuid, .constant(UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!))
                .dependency(\.mainQueue, .immediate)
        )

        _ = await store.send(.addButtonTapped) {
            $0.todos = [
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    description: "",
                    isComplete: false
                )
            ]
        }
        await store.receive(.todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, action: .setFocus(.description))) {
            $0.focus = .init(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, field: .description)
        }
    }

    func testTodoSorting() async {
        let state = Root.State(todos: [
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
            Todo(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                description: "Bread",
                isComplete: false
            ),
        ])
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: state,
            reducer: Root().dependency(\.mainQueue, scheduler.eraseToAnyScheduler())
        )

        _ = await store.send(.todo(id: state.todos[0].id, action: .checkboxTapped)) {
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
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    description: "Bread",
                    isComplete: false
                ),
            ]
        }
        await scheduler.advance(by: 0.5)
        _ = await store.send(.todo(id: state.todos[2].id, action: .checkboxTapped)) {
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
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    description: "Bread",
                    isComplete: true
                ),
            ]
        }
        await scheduler.advance(by: 1)
        await store.receive(.sortCompletedTodos) {
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
                Todo(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    description: "Bread",
                    isComplete: true
                ),
            ]
        }
    }
}
