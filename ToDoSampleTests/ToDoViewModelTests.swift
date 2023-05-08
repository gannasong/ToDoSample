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

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        sut.inputs.delete(index: 0)
        let deletionError = expectDelete(sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succed")
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let item = uniqueItem()

        sut.inputs.add(item)
        let deletionError = expectDelete(sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succed")
    }

    func test_update_modifyPreviouslyAddCache() {
        let sut = makeSUT()
        let item = uniqueItem()
        sut.inputs.add(uniqueItem())
        expect(sut, toRetrieve: .found(items: [item]))

        sut.inputs.update(index: 0, title: item)
        let expectItme = expectUpdate(sut)

        XCTAssertEqual(item, expectItme)
    }

    // MARK: - Helpers

    private func makeSUT() -> ToDoStoreViewModelType {
        let pathKey = testSpecificsPathKey()
        let sut = ToDoViewModel(cachePath: pathKey)
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

    private func setupPreviouslyCache(items: [String]) {
        do {
            let data = try JSONEncoder().encode(items)
            FileManager.default.createFile(atPath: testSpecificsPathKey(), contents: data)
        } catch {
            fatalError(">>> Set previously cache error")
        }
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
    func expectUpdate(_ sut: ToDoStoreViewModelType, at index: Int = 0) -> String? {
        let exp = expectation(description: "Wait for cache update")
        var updateTitle: String?
        sut.outputs.updateStoreResult { result in
            if case .found(let items) = result {
                updateTitle = items[index]
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return updateTitle
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

    @discardableResult
    func expectDelete(_ sut: ToDoStoreViewModelType) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?

        sut.outputs.updateStoreResult { receivedDeletionResult in
            if case .failure(let receivedDeletionError) = receivedDeletionResult {
                deletionError = receivedDeletionError
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}
