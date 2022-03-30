import UIKit

final class TextStorageDelegate: NSObject, NSTextStorageDelegate {
    typealias OnProcessEditing = (NSTextStorage) -> Void

    private let onWillProcessEditing: OnProcessEditing
    private let onDidProcessEditing: OnProcessEditing

    init(
        onWillProcessEditing: @escaping OnProcessEditing,
        onDidProcessEditing: @escaping OnProcessEditing
    ) {
        self.onWillProcessEditing = onWillProcessEditing
        self.onDidProcessEditing = onDidProcessEditing
        super.init()
    }

    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        onWillProcessEditing(textStorage)
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        onDidProcessEditing(textStorage)
    }
}
