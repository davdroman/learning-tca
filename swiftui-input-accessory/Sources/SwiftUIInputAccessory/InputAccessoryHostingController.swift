import SwiftUI

final class InputAccessoryHostingController: UIHostingController<AnyView> {
    override func viewWillAppear(_ animated: Bool) {
        fixViewLayout()
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fixViewLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        fixViewLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewWillDisappear(_ animated: Bool) {
        fixViewLayout()
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fixViewLayout()
    }

    private func fixViewLayout() {
        removeAllViewConstraints()
        forceViewRelayout()
    }

    private func removeAllViewConstraints() {
        view.removeConstraints(view.constraints)
    }

    private func forceViewRelayout() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
