//
//  ListItemViewModelTests.swift
//  KodaboveAssessmentTests
//
//  Created by Drew Barnes on 10/08/2022.
//

import XCTest
@testable import KodaboveAssessment

class EventListViewModelTests: XCTestCase {

    let items = [
        Event(
            id: "1",
            title: "Chelsea vs Manchester Utd",
            subtitle: "EPL",
            date: .distantFuture,
            imageUrl: URL(string: "https://via.placeholder.com/150")!
        ),
        Event(
            id: "2",
            title: "Manchester Utd vs Juventus",
            subtitle: "Champions League",
            date: Date(),
            imageUrl: URL(string: "https://via.placeholder.com/150")!
        ),
        Event(
            id: "3",
            title: "Arsenal vs Ajax",
            subtitle: "Champions League",
            date: .distantPast,
            imageUrl: URL(string: "https://via.placeholder.com/150")!
        )
    ]

    func test_viewModel_contains_no_items() {
        let sut = makeSut().vm
        XCTAssertTrue(sut.isEmpty)
    }

    func test_viewModel_contains_items_after_fetching_data() {
        let sut = makeSut(items: items).vm
        sut.loadData()

        XCTAssertFalse(sut.isEmpty)
    }

    func test_viewModel_at_index_returns_data_correctly() {
        let sut = makeSut(items: items).vm
        sut.loadData()

        XCTAssertEqual(
            sut.viewModel(at: 1),
            EventViewModel(item: items[1])
        )
    }

    func test_loaded_items_are_sorted_by_date_in_ascending_order() {
        let sut = makeSut(items: items).vm
        sut.loadData()

        let date1 = sut.viewModel(at: 0).date
        let date2 = sut.viewModel(at: 1).date
        let date3 = sut.viewModel(at: 2).date

        XCTAssertTrue(date1 < date2)
        XCTAssertTrue(date2 < date3)
        XCTAssertTrue(date1 < date3)
    }

    func test_fetching_items_periodically() {
        let exp = expectation(description: "Fetch Data")
        exp.expectedFulfillmentCount = 5

        let sut = makeSut(items: items, expectation: exp)
        let loader = sut.loader

        XCTAssertEqual(loader.didCall, 0)
        sut.vm.loadData(every: 1)

        wait(for: [exp], timeout: 5)
        XCTAssertEqual(loader.didCall, 5)
        sut.vm.stopLoadingData()
    }

    // MARK: - Helpers
    func makeSut(
        items: [Event] = [],
        expectation: XCTestExpectation? = nil
    ) -> (vm: EventListViewModel, loader: DataLoaderSpy) {
        let itemLoader = DataLoaderSpy(items: items)
        itemLoader.expectation = expectation
        let viewModel = EventListViewModel(dataLoader: itemLoader)
        return (viewModel, itemLoader)
    }

}
