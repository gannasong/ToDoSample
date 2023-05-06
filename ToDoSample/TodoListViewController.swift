//
//  ToDoListViewController.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/4.
//

import UIKit
import SnapKit

class ToDoListViewController: UIViewController {
    private let viewModel: ToDoViewModel
    private var items = [String]()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - Initialization

    init(viewModel: ToDoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        setupNavigationBar()
        setupSubviews()
        setupTableViewdelegate()

        viewModel.updateTotoItems = { [weak self] newTodoItems in
            self?.items = newTodoItems
            self?.tableView.reloadData()
        }

        viewModel.retrieve()
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
                self?.viewModel.update(index: index, title: title)
            }
        }))

        present(alert, animated: true)
    }

    private func didTapDeleteTodo(indexPath: IndexPath) {
        viewModel.delete(indexPath: indexPath)
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
                self?.viewModel.add(title)
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

extension ToDoListViewController: UITableViewDelegate {
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

extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
