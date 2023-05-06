//
//  ToDoViewModel.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/5.
//

import Foundation

public protocol ToDoStoreViewModelType {
    var updateTotoItems: (([String]) -> Void)? { get set }

    func retrieve()
    func delete(indexPath: IndexPath)
    func add(_ newTodo: String)
    func update(index: Int, title: String)
}

class ToDoViewModel: ToDoStoreViewModelType {
    var updateTotoItems: (([String]) -> Void)?

    private var items = [String]()

    func retrieve() {
        let storeItems = getStoreItems()
        items = storeItems
        todoItemsDidChange()
    }

    func delete(indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        saveStoreItems(items)
        todoItemsDidChange()
    }

    func add(_ newTodo: String) {
        items.append(newTodo)
        saveStoreItems(items)
        todoItemsDidChange()
    }

    func update(index: Int, title: String) {
        items[index] = title
        saveStoreItems(items)
        todoItemsDidChange()
    }

    // MARK: - Private Methods

    private func saveStoreItems(_ items: [String], _ key: String = "Todos") {
        UserDefaults.standard.set(items, forKey: key)
    }

    private func getStoreItems(_ key: String = "Todos") -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private func todoItemsDidChange() {
        updateTotoItems?(items)
    }
}
