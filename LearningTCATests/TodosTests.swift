import ComposableArchitecture
@testable import LearningTCA
import XCTest

@MainActor
final class TodosTests: XCTestCase {
	func testCompletingTodo() async {
		let store = TestStore(
			initialState: Root.State(todos: [
				Todo(id: UUID(0), description: "Milk", isComplete: false),
			])
		) {
			Root().dependency(\.continuousClock, ImmediateClock())
		}

		await store.send(.todo(.element(id: UUID(0), action: .checkboxTapped))) {
			$0.todos[id: UUID(0)]?.isComplete = true
		}
		await store.receive(.sortCompletedTodos)
	}

	func testAddTodo() async {
		let store = TestStore(initialState: Root.State(todos: [])) {
			Root()
		} withDependencies: {
			$0.uuid = .constant(UUID(0))
			$0.continuousClock = ImmediateClock()
		}

		await store.send(.addButtonTapped) {
			$0.todos = [
				Todo(id: UUID(0), description: "", isComplete: false)
			]
		}
		await store.receive(.todo(.element(id: UUID(0), action: .setFocus(.description)))) {
			$0.focus = .init(id: UUID(0), field: .description)
		}
	}

	func testTodoSorting() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: Root.State(todos: [
				Todo(id: UUID(0), description: "Milk", isComplete: false),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: false),
			])
		) {
			Root().dependency(\.continuousClock, clock)
		}

		await store.send(.todo(.element(id: UUID(0), action: .checkboxTapped))) {
			$0.todos = [
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: false),
			]
		}
		await clock.advance(by: .seconds(0.5))
		await store.send(.todo(.element(id: UUID(2), action: .checkboxTapped))) {
			$0.todos = [
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: true),
			]
		}
		await clock.advance(by: .seconds(1))
		await store.receive(.sortCompletedTodos) {
			$0.todos = [
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(2), description: "Bread", isComplete: true),
			]
		}
	}
}
