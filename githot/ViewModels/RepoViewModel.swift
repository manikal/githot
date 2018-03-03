//
//  RepoViewModel.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift

class RepoViewModel {
    
    private let repoService = RepoService()
    private var cellViewModels = [RepoCellViewModel]()
    
    var isLoading = MutableProperty(false)
    
    private func searchRepos(text: String) {
        repoService.searchRepos(text: text)
        
        repoService.repos.producer.startWithSignal { (observer, disposable) -> () in
            observer.observeValues({ [weak self] (repos) in
                guard let strongSelf = self else { return }
                strongSelf.cellViewModels = repos.map { RepoCellViewModel(repo: $0) }.flatMap { $0 }
                strongSelf.isLoading.value = false
            })
        }
    }
    
    var cellsCount: Int {
        return cellViewModels.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> RepoCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func searchBarSearchButtonTappedWith(text: String) {
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


