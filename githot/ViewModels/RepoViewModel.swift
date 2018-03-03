//
//  RepoViewModel.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError

class RepoViewModel {
    
    private let repoService = RepoService()
    private var cellViewModels = [RepoCellViewModel]()
    private let alertMessageObserver: Signal<String,NoError>.Observer

    var isLoading = MutableProperty(false)
    var alertMessageSignal: Signal<String,NoError>
    
    init() {
        
        (alertMessageSignal, alertMessageObserver) = Signal.pipe()

        repoService.repos.signal.observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            if let repos = result.value {
                strongSelf.cellViewModels = repos.map { RepoCellViewModel(repo: $0) }.map { $0 }
            }
            strongSelf.isLoading.value = false
        }
        
        repoService.errorSignal.observeResult { [weak self]  (result) in
            guard let strongSelf = self else { return }
            if let error = result.value {
                strongSelf.alertMessageObserver.send(value: error.rawValue)
            }
        }
    }
    
    private func searchRepos(text: String) {
        repoService.searchRepos(text: text)
    }
    
    var cellsCount: Int {
        return cellViewModels.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> RepoCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func searchBarSearchButtonTappedWith(text: String) {
        cellViewModels.removeAll()
        isLoading.value = true
        searchRepos(text: text)
    }
}

extension RepoCellViewModel {
    init(repo: Repo) {
        self.name = repo.name
        self.stars = repo.stars
        self.description = repo.description
    }
}


