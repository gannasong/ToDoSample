//
//  ToDoViewModelTests.swift
//  ToDoSampleTests
//
//  Created by miguel on 2023/5/7.
//

import XCTest

final class ToDoViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        sut.inputs.retrieve()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        sut.inputs.retrieve()
        expect(sut, toRetrieve: .empty)

        sut.inputs.retrieve()
        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let item = uniqueItem()
        let sut = makeSUT()

        sut.inputs.add(item)
        expect(sut, toRetrieve: .found(items: [item]))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let item1 = uniqueItem()
        let item2 = uniqueItem()
        let sut = makeSUT()

        sut.inputs.add(item1)
        expect(sut, toRetrieve: .found(items: [item1]))

        sut.inputs.add(item2)
        expect(sut, toRetrieve: .found(items: [item1, item2]))
    }

    func test_add_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let item = uniqueItem()

        sut.inputs.add(item)

        let additionError = expectAdd(sut)

        XCTAssertNil(additionError, "Expected to add cache successfully")
    }

    // MARK: - Helpers

    private func makeSUT() -> ToDoStoreViewModelType {
        let fileManager = FileManager()
        let pathKey = testSpecificsPathKey()
        let sut = ToDoViewModel(fileManager: fileManager, cachePath: pathKey)
        return sut
    }

    private func uniqueItem() -> String {
        return UUID().uuidString
    }

    private func testSpecificsPathKey() -> String {
        return cacheURL().appendingPathComponent(String(describing: "\(type(of: self)).store"), isDirectory: false).path
    }

    private func cacheURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(atPath: testSpecificsPathKey())
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

    @discardableResult
    func expectAdd(_ sut: ToDoStoreViewModelType) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var addError: Error?

        sut.outputs.updateStoreResult { receivedStoreResult in
            if case .failure(let receivedAddError) = receivedStoreResult {
                addError = receivedAddError
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return addError
    }
}
