import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import LearningTCA
import Testing

@MainActor
struct TodosTests {
	@Test(
		.dependencies {
			$0.continuousClock = .immediate
		}
	)
	func `completing a todo`() async {
		let store = TestStore(
			initialState: Root.State(todos: [
				Todo(id: UUID(0), description: "Milk", isComplete: false),
			])
		) {
			Root()
		}

		await store.send(.todo(.element(id: UUID(0), action: .checkboxTapped))) {
			$0.todos[id: UUID(0)]?.isComplete = true
		}
		await store.receive(\.sortCompletedTodos)
	}

	@Test(
		.dependencies {
			$0.uuid = .constant(UUID(0))
			$0.continuousClock = .immediate
		}
	)
	func `adding a todo`() async {
		let store = TestStore(initialState: Root.State(todos: [])) {
			Root()
		}

		store.send(.addButtonTapped) {
			$0.todos = [
				Todo(id: UUID(0), description: "", isComplete: false)
			]
		}
		await store.receive(\.todo) {
			$0.focus = .init(id: UUID(0), field: .description)
		}
	}

	@Test func `todo sorting`() async {
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
		await store.receive(\.sortCompletedTodos) {
			$0.todos = [
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(2), description: "Bread", isComplete: true),
			]
		}
	}
}
