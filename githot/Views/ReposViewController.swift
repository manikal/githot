//
//  ReposViewController.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import UIKit
import ReactiveSwift

class ReposViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noReposLabel: UILabel!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel = RepoViewModel()
    private var noMorePagesToLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.placeholder = "Search Repositories"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView()
        
        definesPresentationContext = true
        
        viewModel.isLoading.signal.observeResult { [weak self]  (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.noReposLabel.text = ""
                
                if result.value! {
                    strongSelf.activityIndicator.startAnimating()
                } else {
                    strongSelf.activityIndicator.stopAnimating()
                    
                    if strongSelf.viewModel.cellsCount == 0 {
                        strongSelf.noReposLabel.text = "🤷‍♀️"
                    }
                }
            }
        }
        
        viewModel.alertMessageSignal.take(while: { (value) -> Bool in
            return self.isBeingPresented
        }).observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            if let message = result.value {
                DispatchQueue.main.async {
                    strongSelf.showAlert(message: message)
                    strongSelf.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.noMorePagesToLoadSignal.observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.noMorePagesToLoad = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        
        if let repoDetailsViewController = destinationViewController as? RepoDetailsViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
                let repoDetailsViewModel = viewModel.repoDetailsViewModel(at: selectedIndexPath)
                repoDetailsViewController.viewModel = repoDetailsViewModel
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ReposViewController: UITableViewDataSource, UITableViewDataSourcePrefetching {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "repoViewCell", for: indexPath) as? RepoViewCell else { fatalError("Wrong cell type")}
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        
        cell.nameLabel.text = cellViewModel.name
        cell.starsLabel.text = cellViewModel.stars
        cell.descriptionLabel.text = cellViewModel.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastRow = indexPaths.last,
            lastRow.row >= viewModel.cellsCount/2,
            !viewModel.isLoading.value,
            !noMorePagesToLoad {
            print("Row at index \(lastRow.row) cellsCount: \(viewModel.cellsCount)")
            viewModel.loadNextPage()
        }
    }
}

extension ReposViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel.searchBarSearchButtonTappedWith(text: searchText)
        }
    }
}

