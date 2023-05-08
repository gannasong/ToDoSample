//
//  StoreResult.swift
//  ToDoSample
//
//  Created by miguel on 2023/5/7.
//

import Foundation

public enum StoreResult: Equatable {
    case empty
    case found(items: [String])
    case failure(Error)

    public static func == (lhs: StoreResult, rhs: StoreResult) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case let (.found(lhsItems), .found(rhsItems)):
            return lhsItems == rhsItems
        case let (.failure(lhsError), .failure(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
