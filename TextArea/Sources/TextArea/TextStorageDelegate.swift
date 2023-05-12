import UIKit

final class TextStorageDelegate: NSObject, NSTextStorageDelegate {
	typealias OnProcessEditing = (NSTextStorage) -> Void
	
	var onWillProcessEditing: OnProcessEditing?
	var onDidProcessEditing: OnProcessEditing?
	
	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
		onWillProcessEditing?(textStorage)
	}
	
	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
		onDidProcessEditing?(textStorage)
	}
}
