//
//  ViewExtension.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/8/22.
//

import Foundation
import SwiftUI

extension View {
    func dismissKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func withoutAnimation(_ work: @escaping () -> Void) {
        UIView.setAnimationsEnabled(false) //<== Disable animation for whole app
        work()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.setAnimationsEnabled(true) //<== Again enable animation for whole app
        }
    }
}

extension View {
    /// A view modifier to set the color of the iOS Status Bar
    func statusBarStyle(_ style: UIStatusBarStyle, ignoreDarkMode: Bool = true) -> some View {
        background(HostingWindowFinder(callback: { window in
            guard let rootViewController = window?.rootViewController else { return }
            let hostingController = HostingViewController(rootViewController: rootViewController, style: style, ignoreDarkMode: ignoreDarkMode)
            window?.rootViewController = hostingController
        }))
    }
}

fileprivate class HostingViewController: UIViewController {
    private var rootViewController: UIViewController?
    private var style: UIStatusBarStyle = .lightContent
    private var ignoreDarkMode: Bool = true
    
    init(rootViewController: UIViewController, style: UIStatusBarStyle, ignoreDarkMode: Bool) {
        self.rootViewController = rootViewController
        self.style = style
        self.ignoreDarkMode = ignoreDarkMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let child = rootViewController else { return }
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ignoreDarkMode || traitCollection.userInterfaceStyle == .light {
            return style
        } else {
            if style == .darkContent {
                return .lightContent
            } else {
                return .darkContent
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
}

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // NO-OP
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

