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
    
    var cellViewModels = MutableProperty([RepoCellViewModel]())
    
    private func searchRepos(text: String) {
        self.repoService.searchRepos(text: text)
        
        self.repoService.repos.producer.startWithSignal { (observer, disposable) -> () in
            observer.observeValues({ [weak self] (repos) in
                guard let strongSelf = self else { return }
                strongSelf.cellViewModels.value = repos.map { RepoCellViewModel(repo: $0) }.flatMap { $0 }
            })
        }
    }
    
    var cellsCount: Int {
        return cellViewModels.value.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> RepoCellViewModel {
        return cellViewModels.value[indexPath.row]
    }
    
    func searchBarSearchButtonTappedWith(text: String) {
        self.searchRepos(text: text)
    }
}

extension RepoCellViewModel {
    init(repo: Repo) {
        self.name = repo.name
        self.stars = repo.stars
        self.description = repo.description
    }
}


