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
    @IBOutlet weak var filterButton: UIButton!
    
    private var viewModel: SearchViewModel?
    private let debouncer = Debouncer(interval: 0.25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupTableView()
        addOutsideTapToCloseKeyboard()
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        view.endEditing(true)
        guard let vc = R.storyboard.main.filterViewController() else { return }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        vc.year = viewModel?.getYear()
        vc.type = viewModel?.getType()
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel?.moviesCount() ?? 0
        // Show no data view if there is no items
        count == 0 ? tableView.addNoDataView() : tableView.removeNoDataView()
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchResultTableViewCell, for: indexPath)
        if let movie = viewModel?.movie(at: indexPath.row) {
            cell?.configure(with: movie)
        }
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel else { return }
        // if cell is last one and there are more items to load, load more
        if viewModel.hasMore, indexPath.row == viewModel.moviesCount() - 1 {
            viewModel.search(isPagination: true) { [weak self] result in
                guard let self = self else { return }
                self.handleAPIResult(result: result)
            }
        }
    }
}

// MARK: SearchViewModelDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clearTable()
        tableView.addActivityIndicator()
        viewModel?.search(query: searchBar.text ?? "") { [weak self] result in
            guard let self = self else { return }
            self.handleAPIResult(result: result)
        }
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (searchBar.text as? NSString)?.replacingCharacters(in: range, with: text)
        let characterLimit = 255
        // Check if the new length exceeds the character limit
        return (newText?.count ?? 256) <= characterLimit
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel?.clear()
            tableView.reloadData()
            return
        }
        // add debounce to avoid multiple requests
        debouncer.debounce { [weak self] in
            DispatchQueue.main.async {
                self?.clearTable()
                self?.tableView.addActivityIndicator()
            }
            self?.viewModel?.search(query: searchText) { [weak self] result in
                guard let self = self else { return }
                self.handleAPIResult(result: result)
            }
        }
    }
}

// MARK: Private methods
private extension SearchViewController {
    func setupViewModel() {
        viewModel = SearchViewModel(apiService: ApiService())
    }
    
    func setupTableView() {
        tableView.register(R.nib.searchResultTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func handleAPIResult(result: Result<SearchViewModelResponse, Error>) {
        tableView.removeActivityIndicator()
        switch result {
        case .success(let response):
            if response.isPagination {
                let moviesCount = viewModel?.moviesCount() ?? 0
                var indexPaths: [IndexPath] = []
                for i in moviesCount-response.rowsAdded...moviesCount-1 {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                self.tableView.insertRows(at: indexPaths, with: .fade)
            } else {
                self.tableView.reloadData()
            }
        case .failure(let error):
            handleAPIError(error)
        }
    }
    
    func clearTable() {
        viewModel?.clear()
        tableView.reloadData()
    }
}

// MARK: SearchResultTableViewCellDelegate
extension SearchViewController: SearchResultTableViewCellDelegate {
    func didTapButton(movie: Movie) {
        print(movie.title)
        print("Button that does nothing :)")
    }
}

// MARK: FilterViewControllerDelegate
extension SearchViewController: FilterViewControllerDelegate {
    func didSaveNewFilter(year: Int?, type: MovieType?) {
        viewModel?.setYear(year)
        viewModel?.setType(type)
        clearTable()
        tableView.addActivityIndicator()
        viewModel?.search(query: searchBar.text ?? "") { [weak self] result in
            guard let self = self else { return }
            self.handleAPIResult(result: result)
        }
    }
}
