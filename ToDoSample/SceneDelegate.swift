//
//  SceneDelegate.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/4.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }

    func configureWindow() {
        let controller = makeToDoListViewController()
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()
    }

    private func makeToDoListViewController() -> ToDoListViewController {
        let viewModel = ToDoViewModel()
        let controller = ToDoListViewController(viewModel: viewModel)
        return controller
    }
}
