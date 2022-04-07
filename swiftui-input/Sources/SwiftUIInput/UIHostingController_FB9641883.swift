import SwiftUI

final class UIHostingController_FB9641883<Content: View>: UIHostingController<Content> {
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            heightConstraint = view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height)
            NSLayoutConstraint.activate([
                heightConstraint!,
            ])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightConstraint?.constant = view.intrinsicContentSize.height
    }
}
