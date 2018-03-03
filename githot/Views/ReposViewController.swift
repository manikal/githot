//
//  ReposViewController.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import UIKit

class ReposViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    let viewModel = RepoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.placeholder = "Search Repositories"
        tableView.tableHeaderView = searchController.searchBar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        viewModel.cellViewModels.producer.startWithSignal { (observer, disposable) -> () in
            observer.observeValues({ [weak self] (repos) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "repoViewCell", for: indexPath) as? RepoViewCell else { fatalError("Wrong cell type")}
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        
        cell.nameLabel.text = cellViewModel.name
        cell.starsLabel.text = cellViewModel.stars
        cell.descriptionLabel.text = cellViewModel.description
        
        return cell
    }
}

extension ReposViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel.searchBarSearchButtonTappedWith(text: searchText)
        }
    }
}

