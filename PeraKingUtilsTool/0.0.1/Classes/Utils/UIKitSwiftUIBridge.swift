import UIKit
import Foundation
import SwiftUI

/// A utility class that provides methods to convert between UIKit and SwiftUI views
public class UIKitSwiftUIBridge {
    
    // MARK: - SwiftUI to UIKit
    
    /// Converts a SwiftUI view to a UIViewController
    /// - Parameter view: The SwiftUI view to convert
    /// - Returns: A UIViewController containing the SwiftUI view
    public static func makeUIViewController<Content: View>(from view: Content) -> UIViewController {
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    /// Converts a SwiftUI view to a UIView
    /// - Parameter view: The SwiftUI view to convert
    /// - Returns: A UIView containing the SwiftUI view
    public static func makeUIView<Content: View>(from view: Content) -> UIView {
        let hostingController = UIHostingController(rootView: view)
        return hostingController.view
    }
    
    /// Embeds a SwiftUI view as a child view controller in a parent UIViewController
    /// - Parameters:
    ///   - view: The SwiftUI view to embed
    ///   - parent: The parent UIViewController
    ///   - container: The container view in which to embed the SwiftUI view
    public static func embed<Content: View>(_ view: Content, in parent: UIViewController, container: UIView) {
        let hostingController = UIHostingController(rootView: view)
        parent.addChild(hostingController)
        container.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: parent)
    }
    
    // MARK: - UIKit to SwiftUI
    
    /// A SwiftUI wrapper for UIKit views
    public struct UIViewWrapper<Wrapped: UIView>: UIViewRepresentable {
        let makeView: () -> Wrapped
        let updateView: (Wrapped, Context) -> Void
        
        init(makeView: @escaping () -> Wrapped, 
             updateView: @escaping (Wrapped, Context) -> Void = { _, _ in }) {
            self.makeView = makeView
            self.updateView = updateView
        }
        
        public func makeUIView(context: Context) -> Wrapped {
            makeView()
        }
        
        public func updateUIView(_ uiView: Wrapped, context: Context) {
            updateView(uiView, context)
        }
    }
    
    /// A SwiftUI wrapper for UIKit view controllers
    public struct UIViewControllerWrapper<Wrapped: UIViewController>: UIViewControllerRepresentable {
        let makeViewController: () -> Wrapped
        let updateViewController: (Wrapped, Context) -> Void
        
        init(makeViewController: @escaping () -> Wrapped, 
             updateViewController: @escaping (Wrapped, Context) -> Void = { _, _ in }) {
            self.makeViewController = makeViewController
            self.updateViewController = updateViewController
        }
        
        public func makeUIViewController(context: Context) -> Wrapped {
            makeViewController()
        }
        
        public func updateUIViewController(_ uiViewController: Wrapped, context: Context) {
            updateViewController(uiViewController, context)
        }
    }
    
    /// Creates a SwiftUI view that wraps a UIKit view
    /// - Parameter makeView: A closure that creates the UIKit view
    /// - Parameter updateView: An optional closure to update the UIKit view when SwiftUI updates
    /// - Returns: A SwiftUI view containing the UIKit view
    public static func makeView<WrappedView: UIView>(
        _ makeView: @escaping () -> WrappedView,
        update updateView: @escaping (WrappedView, UIViewWrapper<WrappedView>.Context) -> Void = { _, _ in }
    ) -> some View {
        UIViewWrapper(makeView: makeView, updateView: updateView)
    }
    
    /// Creates a SwiftUI view that wraps a UIKit view controller
    /// - Parameter makeViewController: A closure that creates the UIKit view controller
    /// - Parameter updateViewController: An optional closure to update the UIKit view controller when SwiftUI updates
    /// - Returns: A SwiftUI view containing the UIKit view controller
    public static func makeViewController<WrappedViewController: UIViewController>(
        _ makeViewController: @escaping () -> WrappedViewController,
        update updateViewController: @escaping (WrappedViewController, UIViewControllerWrapper<WrappedViewController>.Context) -> Void = { _, _ in }
    ) -> some View {
        UIViewControllerWrapper(makeViewController: makeViewController, updateViewController: updateViewController)
    }
}

// MARK: - Convenience Extensions

extension UIViewController {
    /// Embeds a SwiftUI view in the view controller
    /// - Parameters:
    ///   - view: The SwiftUI view to embed
    ///   - container: The container view in which to embed the SwiftUI view
    func embed<Content: View>(_ view: Content, in container: UIView) {
        UIKitSwiftUIBridge.embed(view, in: self, container: container)
    }
}

extension View {
    /// Converts the SwiftUI view to a UIViewController
    /// - Returns: A UIViewController containing this SwiftUI view
    func toUIViewController() -> UIViewController {
        UIKitSwiftUIBridge.makeUIViewController(from: self)
    }
    
    /// Converts the SwiftUI view to a UIView
    /// - Returns: A UIView containing this SwiftUI view
    func toUIView() -> UIView {
        UIKitSwiftUIBridge.makeUIView(from: self)
    }
} 
