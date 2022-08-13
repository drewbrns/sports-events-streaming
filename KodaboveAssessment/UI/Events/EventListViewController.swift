//
//  EventListViewController.swift
//  KodaboveAssessment
//
//  Created by Drew Barnes on 11/08/2022.
//

import UIKit
import Combine

class EventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    var vm: ItemListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let remoteItemLoader = RemoteItemLoader(resource: .events)
        vm = ItemListViewModel(dataLoader: remoteItemLoader)

        configureTableView()
        bindFetchCompletePublisher()

        vm?.loadData(limit: PageSize.limit)

    }
}

extension EventListViewController {

    private func configureTableView() {
        registerCell()
        removeEmptyCellsFromBottom()
        configureTableViewCellHeight()
    }

    private func bindVmPublishers() {
        bindFetchCompletePublisher()
    }

    private func registerCell() {
        tableView.register(
            UINib(nibName: ListItemCell.cellId, bundle: nil),
            forCellReuseIdentifier: ListItemCell.cellId
        )
    }

    private func removeEmptyCellsFromBottom() {
        tableView.tableFooterView = UIView()
    }

    private func configureTableViewCellHeight() {
        tableView.estimatedRowHeight = 124
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func bindFetchCompletePublisher() {
        vm?.$onFetchComplete.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
    }
}

extension EventListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm?.totalCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListItemCell.cellId, for: indexPath
        ) as? ListItemCell else {
            fatalError("Unexpected error")
        }

        cell.configure(with: vm?.viewModel(at: indexPath.row))
        return cell
    }

}

extension EventListViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }

}

extension EventListViewController: UITableViewDelegate {

}
