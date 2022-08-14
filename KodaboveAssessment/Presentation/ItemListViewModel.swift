//
//  ItemListViewModel.swift
//  KodaboveAssessment
//
//  Created by Drew Barnes on 10/08/2022.
//

import Foundation
import Combine

protocol ItemList {
    var isEmpty: Bool { get }
    var totalCount: Int { get }
    var currentCount: Int { get }
    func viewModel(at index: Int) -> ItemViewModel

    func loadData(limit: Int)
    func loadData(limit: Int, every: TimeInterval)
    func stopLoadingData()
}

private var responsePage = 1

final class ItemListViewModel: ObservableObject, ItemList {
    @Published private(set) var onFetchComplete: [IndexPath]?
    @Published private(set) var onError: Error?
    private var timerCancellable: AnyCancellable?
    private var itemType: ItemType

    var isEmpty: Bool { items.isEmpty }
    private(set) var totalCount: Int = 0
    var currentCount: Int { items.count }

    private(set) var isLoadingData = false
    private var currentPage = 1

    private var items = [Item]()
    private var dataLoader: ItemLoader

    init(dataLoader: ItemLoader, itemType: ItemType = .event) {
        self.dataLoader = dataLoader
        self.itemType = itemType
    }

    func viewModel(at index: Int) -> ItemViewModel {
        return ItemViewModel(
            item: items[index],
            itemType: itemType
        )
    }

    func loadData(limit: Int = 10) {
        guard !isLoadingData else { return }

        self.isLoadingData = true
        self.dataLoader.fetch(page: self.currentPage, limit: limit) { [weak self] result in
            self?.isLoadingData = false

            switch result {
            case .success(let items):
                self?.currentPage += 1
                self?.totalCount = 100 // Faking total number of items on server
                self?.items.append(contentsOf: items)
                self?.items = self?.sort(items: self?.items) ?? [Item]()

                if responsePage > 1 {
                    let indexPathsToReload = IndexPath.generateIndexPaths(
                        rowStart: self?.items.count ?? 0,
                        rowEnd: items.count
                    )
                    self?.onFetchComplete = indexPathsToReload
                } else {
                    self?.onFetchComplete = .none
                }

                // Faking response page on server
                responsePage += 1

            case .failure(let error):
                self?.onError = error
            }
        }
    }

    func loadData(limit: Int = 10, every interval: TimeInterval) {
        let timer = Timer.publish(every: interval, on: .main, in: .common)
        timerCancellable = timer.autoconnect().sink { _ in
            self.loadData(limit: limit)
        }
    }

    func stopLoadingData() {
        timerCancellable?.cancel()
    }

    private func sort(items: [Item]?) -> [Item] {
        guard let items = items else { return [Item]() }
        return items.sorted(by: {$0.date.compare($1.date) == .orderedAscending})
    }

    //TODO:
    private func handlePullToRefresh() {}

}
