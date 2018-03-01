//
//  RepoViewModel.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import Foundation

class RepoViewModel {
    
    private let repoService: RepoServiceProtocol
    
    private(set) var repos = [Repo]()
    private(set) var alertMessage: String?
    
    init(repoService: RepoServiceProtocol) {
        self.repoService = repoService
    }
    
    func fetchRepos() {
        self.repoService.fetchTrendingRepos { [weak self] (repos, error) in
            self?.repos = repos
            self?.alertMessage = error?.rawValue
        }
    }
}


