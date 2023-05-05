//
//  TodoListViewController.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/4.
//

import UIKit
import SnapKit

class TodoListViewController: UIViewController {
    private var items = [String]()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        setupNavigationBar()
        setupSubviews()
        setupTableViewdelegate()

        self.items = UserDefaults.standard.stringArray(forKey: "Todos") ?? []
    }

    private func didTapEditTodo(index: Int) {
        let alert = UIAlertController(title: "Edit Todo",
                                      message: "Enter new to do list item",
                                      preferredStyle: .alert)
        let item = items[index]

        alert.addTextField { title in
            title.text = item
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in

            if let titleField = alert.textFields?.first, let title = titleField.text, !title.isEmpty {
                DispatchQueue.main.async {
                    var currentItems = UserDefaults.standard.stringArray(forKey: "Todos") ?? []
                    currentItems[index] = title
                    self?.items = currentItems
                    UserDefaults.standard.set(currentItems, forKey: "Todos")
                    self?.tableView.reloadData()
                }
            }
        }))

        present(alert, animated: true)
    }

    private func didTapDeleteTodo(indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        UserDefaults.standard.set(items, forKey: "Todos")
    }

    @objc private func didTapAddTodo() {
        let alert = UIAlertController(title: "New Todo",
                                      message: "Enter new to do list item",
                                      preferredStyle: .alert)
        alert.addTextField { title in
            title.placeholder = "Enter Todo ..."
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in

            if let titleField = alert.textFields?.first, let title = titleField.text, !title.isEmpty {
                DispatchQueue.main.async {
                    var currentItems = UserDefaults.standard.stringArray(forKey: "Todos") ?? []
                    currentItems.append(title)
                    UserDefaults.standard.set(currentItems, forKey: "Todos")
                    self?.items.append(title)
                    self?.tableView.reloadData()
                }
            }
        }))

        present(alert, animated: true)
    }

    // MARK: - Private Methods

    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddTodo))
    }

    private func setupTableViewdelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] action, view, completion in
            self?.didTapEditTodo(index: indexPath.row)
            completion(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
            self?.didTapDeleteTodo(indexPath: indexPath)
            completion(true)
        }

        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .orange
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
