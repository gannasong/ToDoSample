//
//  ToDoStoreViewModelType.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/7.
//

import Foundation

public protocol ToDoStoreInputs {
    func retrieve()
    func delete(index: Int)
    func add(_ newTodo: String)
    func update(index: Int, title: String)
}

public protocol ToDoStoreOutputs {
    var storeResult: ((StoreResult) -> Void)? { get }
    func updateStoreResult(_ closure: ((StoreResult) -> Void)?)
}

public protocol ToDoStoreViewModelType {
    var inputs: ToDoStoreInputs { get }
    var outputs: ToDoStoreOutputs { get }
}
