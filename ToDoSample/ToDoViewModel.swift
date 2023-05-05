//
//  ToDoViewModel.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/5.
//

import Foundation

public protocol ToDoStoreViewModelType {
    typealias RetrievalCompletion = ([String]) -> Void

    func retrieve(completion: @escaping RetrievalCompletion)
}

class ToDoViewModel: ToDoStoreViewModelType {

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let todos = UserDefaults.standard.stringArray(forKey: "Todos") ?? []
        completion(todos)
    }
}
