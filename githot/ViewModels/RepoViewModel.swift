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
    private let readmeContentObserver: Signal<String,NoError>.Observer

    private(set) var isLoading = MutableProperty(false)
    private(set) var noMorePagesToLoad = false
    private(set) var alertMessageSignal: Signal<String,NoError>
    private(set) var readmeContentSignal: Signal<String,NoError>
    private(set) var allReposCount = 0
    
    init() {
        
        (alertMessageSignal, alertMessageObserver) = Signal.pipe()
        (readmeContentSignal, readmeContentObserver) = Signal.pipe()

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
        
        repoService.readmeSignal.observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            if let readmeContent = result.value {
                strongSelf.readmeContentObserver.send(value: readmeContent)
            }
        }
        
        repoService.noMorePagesSignal.observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.noMorePagesToLoad = true
            strongSelf.isLoading.value = false
        }
        
        repoService.itemsCountSignal.observeResult { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if let itemsCount = result.value {
                strongSelf.allReposCount = itemsCount
            }
        }
    }
    
    func loadNextPage() {
        isLoading.value = true
        repoService.loadNextRepoPage()
    }
    
    var cellsCount: Int {
        return cellViewModels.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> RepoCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func repoDetailsViewModel(at indexPath: IndexPath) -> RepoDetailsViewModel {
        let repo = repoService.repos.value[indexPath.row]
        let repoDetailsViewModel = RepoDetailsViewModel(repo: repo, readmeContentSignal: readmeContentSignal, readmeContentErrorSignal: alertMessageSignal)
        
        delay(0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.repoService.fetchReadme(owner: repo.author, repoName: repo.name)
        }
        
        return repoDetailsViewModel
    }
    
    func searchRepos(text: String) {
        repoService.searchRepos(text: text)
        isLoading.value = true
    }
}

extension RepoCellViewModel {
    init(repo: Repo) {
        self.name = repo.name
        self.stars = repo.stars
        self.description = repo.description
    }
}

extension RepoDetailsViewModel {
    init(repo: Repo, readmeContentSignal: Signal<String,NoError>, readmeContentErrorSignal: Signal<String,NoError>) {
        self.name = repo.name
        self.username = repo.author
        self.stars = repo.stars
        self.forks = repo.forks
        self.description = repo.description
        self.avatarURL = repo.avatarURL
        self.readmeContentSignal = readmeContentSignal
        self.readmeContentErrorSignal = readmeContentErrorSignal
    }
}


