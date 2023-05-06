//
//  ToDoViewModel.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/5.
//

import Foundation

public protocol ToDoStoreInputs {
    func retrieve()
    func delete(indexPath: IndexPath)
    func add(_ newTodo: String)
    func update(index: Int, title: String)
}

public protocol ToDoStoreOutputs {
    var updateItems: (([String]) -> Void)? { get }
    func updateTotoItems(_ closure: (([String]) -> Void)?)
}

public protocol ToDoStoreViewModelType {
    var inputs: ToDoStoreInputs { get }
    var outputs: ToDoStoreOutputs { get }
}

class ToDoViewModel: ToDoStoreViewModelType, ToDoStoreOutputs, ToDoStoreInputs {
    let fileManager: FileManager
    private var items = [String]()

    var inputs: ToDoStoreInputs { self }
    var outputs: ToDoStoreOutputs = MyOutputs()

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var path: String {
        return getURL().appendingPathComponent(String(describing: "ToDoStore"), isDirectory: false).path
    }

    var queue = DispatchQueue(label: "\(ToDoViewModel.self).Queue", qos: .userInitiated, attributes: .concurrent)

    private func getURL() -> URL {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return directory
        } else {
            fatalError("Couldn't create directory to save.")
        }
    }

    // MARK: - Inputs

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

    // MARK: - Outputs

    var updateItems: (([String]) -> Void)?

    func updateTotoItems(_ closure: (([String]) -> Void)?) {
        updateItems = closure
    }

    // MARK: - Private Methods

    private func saveStoreItems(_ items: [String], _ key: String = "Todos") {
        UserDefaults.standard.set(items, forKey: key)
    }

    private func getStoreItems(_ key: String = "Todos") -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private func todoItemsDidChange() {
        outputs.updateItems?(items)
    }
}

class MyOutputs: ToDoStoreOutputs {
    var updateItems: (([String]) -> Void)?

    func updateTotoItems(_ closure: (([String]) -> Void)?) {
        updateItems = closure
    }
}
