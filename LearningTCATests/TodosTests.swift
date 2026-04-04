import ComposableArchitecture2
import DependenciesTestSupport
import Foundation
@testable import LearningTCA
import Testing

struct TodosTests {
	@Test(
		.dependencies {
			$0.continuousClock = .immediate
		}
	)
	func `completing a todo`() async {
		let store = await TestStoreActor(
			initialState: Root.State(todos: [
				Todo(id: UUID(0), description: "Milk", isComplete: false),
			])
		) {
			Root()
		}

		await store.send(.todoRow(UUID(0), .checkboxTapped)) {
			$0.todos[0].isComplete = true
		}
	}

	@Test(
		.dependencies {
			$0.uuid = .constant(UUID(0))
			$0.continuousClock = .immediate
		}
	)
	func `adding a todo`() async {
		let store = await TestStoreActor(initialState: Root.State(todos: [])) {
			Root()
		}

		await store.send(.addButtonTapped) {
			$0.todos = [
				Todo(id: UUID(0), description: "", isComplete: false)
			]
			$0.focus = .init(id: UUID(0), field: .description)
		}
	}

	@Test(
		.dependencies {
			$0.continuousClock = TestClock()
		}
	)
	func `todo sorting`() async {
		@Dependency(\.continuousClock, as: TestClock<Duration>.self) var clock

		let store = await TestStoreActor(
			initialState: Root.State(todos: [
				Todo(id: UUID(0), description: "Milk", isComplete: false),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: false),
			])
		) {
			Root()
		}

		await store.send(.todoRow(UUID(0), .checkboxTapped)) {
			$0.todos = [
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: false),
			]
		}
		await clock.advance(by: .seconds(0.5))
		await store.send(.todoRow(UUID(2), .checkboxTapped)) {
			$0.todos = [
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(2), description: "Bread", isComplete: true),
			]
		}
		await clock.advance(by: .seconds(1))
		await store.expect {
			$0.todos = [
				Todo(id: UUID(1), description: "Eggs", isComplete: false),
				Todo(id: UUID(0), description: "Milk", isComplete: true),
				Todo(id: UUID(2), description: "Bread", isComplete: true),
			]
		}
	}
}
