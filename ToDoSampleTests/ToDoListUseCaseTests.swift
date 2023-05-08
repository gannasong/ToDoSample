//
//  ToDoListUseCaseTests.swift
//  ToDoSampleTests
//
//  Created by miguel on 2023/5/8.
//

import XCTest
@testable import ToDoSample

final class ToDoListUseCaseTests: XCTestCase {

    func test_viewDidLoad_setTitle() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, "To Do List")
    }

    func test_viewDidLoad_initialState() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.numberOfItems(), 0)
    }

    // MARK: - Helpers

    private func makeSUT() -> ToDoListViewController {
        let viewModel = ToDoViewModel(cachePath: "\(type(of: self)).store")
        let sut = ToDoListViewController(viewModel: viewModel)
        return sut
    }
}

extension ToDoListViewController {
    func numberOfItems() -> Int {
        tableView.numberOfRows(inSection: todoSection)
    }

    private var todoSection: Int { 0 }
}
