//
//  ViewController.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: SearchViewModel?
    private let debouncer = Debouncer(interval: 0.25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupTableView()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.moviesCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchResultTableViewCell, for: indexPath)
        if let movie = viewModel?.movie(at: indexPath.row) {
            cell?.configure(with: movie)
        }
        return cell ?? UITableViewCell()
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel else { return }
        if viewModel.hasMore, indexPath.row == viewModel.moviesCount() - 1 {
            viewModel.loadMore { [weak self] result in
                guard let self = self else { return }
                self.handleAPIResult(result: result)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.search(query: searchBar.text ?? "") { [weak self] result in
            guard let self = self else { return }
            self.handleAPIResult(result: result)
        }
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel?.clear()
            tableView.reloadData()
            return
        }
        // add debounce to avoid multiple requests
        debouncer.debounce { [weak self] in
            self?.viewModel?.search(query: searchText) { [weak self] result in
                guard let self = self else { return }
                self.handleAPIResult(result: result)
            }
        }
    }
}

private extension SearchViewController {
    func setupViewModel() {
        viewModel = SearchViewModel(apiService: ApiService())
    }
    
    func setupTableView() {
        tableView.register(R.nib.searchResultTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func handleAPIResult(result: Result<SearchResponse, Error>) {
        switch result {
        case .success(_):
            // Handle successful result
            self.tableView.reloadData()
        case .failure(let error):
            handleAPIError(error)
        }
    }
}
