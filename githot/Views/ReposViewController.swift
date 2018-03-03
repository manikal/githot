//
//  ReposViewController.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import UIKit

class ReposViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel = RepoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.placeholder = "Search Repositories"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView()
        
        definesPresentationContext = true
        
        viewModel.isLoading.producer.startWithSignal { (observer, disposable) -> () in
            observer.observeValues({ [weak self] (loading) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    if loading {
                        strongSelf.activityIndicator.isHidden = false
                        strongSelf.activityIndicator.startAnimating()
                    } else {
                        strongSelf.tableView.reloadData()
                        strongSelf.activityIndicator.stopAnimating()
                    }
                }
            })
        
        }
    }
}

extension ReposViewController: UITableViewDataSource {
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
}

extension ReposViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel.searchBarSearchButtonTappedWith(text: searchText)
        }
    }
}

