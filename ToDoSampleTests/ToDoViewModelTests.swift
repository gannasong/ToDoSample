//
//  ToDoViewModelTests.swift
//  ToDoSampleTests
//
//  Created by miguel on 2023/5/7.
//

import XCTest

final class ToDoViewModelTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        sut.inputs.retrieve()

        expect(sut, toRetrieve: .empty)
    }


    // MARK: - Helpers

    private func makeSUT() -> ToDoStoreViewModelType {
        let fileManager = FileManager()
        let pathKey = testSpecificsPathKey()
        let sut = ToDoViewModel(fileManager: fileManager, cachePath: pathKey)
        return sut
    }

    private func testSpecificsPathKey() -> String {
        return "\(type(of: self)).store"
    }

    func expect(_ sut: ToDoStoreViewModelType, toRetrieve expectResult: StoreResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.outputs.updateStoreResult { retrievedResult in
            switch (expectResult, retrievedResult) {
                case (.empty, .empty):
                    break
                case (.failure, .failure):
                    break
                case let (.found(expected), .found(retrieved)):
                    XCTAssertEqual(retrieved.count, expected.count)
                default:
                    XCTFail("Expected to retrieve \(expectResult), got \(retrievedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
