import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        self.cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                if notification.name == UIResponder.keyboardWillHideNotification {
                    return CGRect.zero
                } else {
                    return notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
            }
            .map { rect in
                rect.height
            }
            .assign(to: \.keyboardHeight, on: self)
    }

    deinit {
        self.cancellable?.cancel()
    }
}

struct KeyboardAdaptive: ViewModifier {
    @StateObject private var keyboardObserver = KeyboardObserver()

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeOut(duration: 0.3), value: keyboardObserver.keyboardHeight)
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var onTap: () -> Void

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onTap()
        }

        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

