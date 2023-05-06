//
//  StoreResult.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/7.
//

import Foundation

public enum StoreResult {
    case empty
    case found(items: [String])
    case failure(Error)
}
