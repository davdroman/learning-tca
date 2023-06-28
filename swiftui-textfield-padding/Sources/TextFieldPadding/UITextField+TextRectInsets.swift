import UIKit
import ObjectiveC

extension UITextField {
	public var textRectInsets: UIEdgeInsets? {
		get {
			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
			return objc_getAssociatedObject(self, key) as? UIEdgeInsets
		}
		set {
			guard textRectInsets != newValue else {
				return
			}
			UITextField.swizzleTextRectMethodsIfNeeded()
			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
			objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
			text = text // hack to force reload field's rect insets
		}
	}
}

private extension UITextField {
	@objc func xxx_textRect(forBounds bounds: CGRect) -> CGRect {
		guard let textRectInsets = textRectInsets else {
			return self.xxx_textRect(forBounds: bounds)
		}
		return bounds.inset(by: textRectInsets)
	}
	
	@objc func xxx_editingRect(forBounds bounds: CGRect) -> CGRect {
		guard let textRectInsets = textRectInsets else {
			return self.xxx_editingRect(forBounds: bounds)
		}
		return bounds.inset(by: textRectInsets)
	}
}

private extension UITextField {
	static var didSwizzle = false
	
	static func swizzleTextRectMethodsIfNeeded() {
		if !didSwizzle {
			didSwizzle = true
			swizzle(#selector(UITextField.textRect), with: #selector(UITextField.xxx_textRect))
			swizzle(#selector(UITextField.editingRect), with: #selector(UITextField.xxx_editingRect))
		}
	}
	
	static func swizzle(_ original: Selector, with swizzled: Selector) {
		guard
			let originalMethod = class_getInstanceMethod(UITextField.self, original),
			let swizzledMethod = class_getInstanceMethod(UITextField.self, swizzled)
		else {
			return
		}
		method_exchangeImplementations(originalMethod, swizzledMethod)
	}
}
