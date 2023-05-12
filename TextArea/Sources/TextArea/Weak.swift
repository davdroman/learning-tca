import Foundation

@propertyWrapper
class Weak<T: AnyObject> {
	var wrappedValue: T? {
		get { weakValue }
		set { weakValue = newValue }
	}
	
	weak var weakValue: T?
	
	init(wrappedValue: T?) {
		self.weakValue = wrappedValue
	}
}
