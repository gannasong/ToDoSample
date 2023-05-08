//
//  ToDoViewModel.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/5.
//

import Foundation

class ToDoViewModel: ToDoStoreViewModelType, ToDoStoreOutputs, ToDoStoreInputs {
    private let fileManager: FileManager
    private let cachePath: String

    private var items = [String]()

    var inputs: ToDoStoreInputs { self }
    var outputs: ToDoStoreOutputs = MyOutputs()

    public init(fileManager: FileManager = .default, cachePath: String = String(describing: ToDoStoreViewModelType.self)) {
        self.fileManager = fileManager
        self.cachePath = cachePath
    }

    var path: String {
        return getURL().appendingPathComponent(cachePath, isDirectory: false).path
    }

    var queue = DispatchQueue(label: "\(ToDoViewModel.self).Queue", qos: .userInitiated, attributes: .concurrent)

    func getURL() -> URL {
        if let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return directory
        } else {
            fatalError("Couldn't create directory to save.")
        }
    }

    // MARK: - Inputs

    func retrieve() {
        queue.async {
            if let data = self.fileManager.contents(atPath: self.path) {
                do {
                    let storeItems = try JSONDecoder().decode([String].self, from: data)
                    self.items = storeItems
                    self.storeCompletion(.found(items: self.items))
                } catch {
                    self.storeCompletion(.empty)
                }
            } else {
                self.storeCompletion(.empty)
            }
        }
    }

    func delete(index: Int) {
        if items.indices.contains(index) {
            items.remove(at: index)
        }

        insert(items)
    }

    func add(_ newTodo: String) {
        items.append(newTodo)
        insert(items)
    }

    func update(index: Int, title: String) {
        if items.indices.contains(index) {
            items[index] = title
        }

        insert(items)
    }

    // MARK: - Outputs

    var storeResult: ((StoreResult) -> Void)?

    func updateStoreResult(_ closure: ((StoreResult) -> Void)?) {
        storeResult = closure
    }

    // MARK: - Private Methods

    private func insert(_ items: [String]) {
        queue.async(flags: .barrier) {
            do {
                let data = try JSONEncoder().encode(items)
                if self.fileManager.fileExists(atPath: self.path) {
                    try self.fileManager.removeItem(atPath: self.path)
                }

                self.fileManager.createFile(atPath: self.path, contents: data)
                self.storeCompletion(.found(items: items))
            } catch {
                self.storeCompletion(.failure(error))
            }
        }
    }

    private func storeCompletion(_ result: StoreResult) {
        outputs.storeResult?(result)
    }
}

class MyOutputs: ToDoStoreOutputs {
    var storeResult: ((StoreResult) -> Void)?

    func updateStoreResult(_ closure: ((StoreResult) -> Void)?) {
        storeResult = closure
    }
}
