import ComposableArchitecture
import SwiftUI

@main
struct App: SwiftUI.App {
	var body: some Scene {
		WindowGroup {
			RootView(
				store: Store(
					initialState: Root.State(
						todos: [
							Todo(id: UUID(), description: "Milk"),
							Todo(id: UUID(), description: "Eggs"),
							Todo(id: UUID(), description: "Dust filter for Hoover Max Extract Pressure Pro model 60"),
							Todo(id: UUID(), description: "Hand soap", isComplete: true),
						]
					),
					reducer: Root()
				)
			)
		}
	}
}
