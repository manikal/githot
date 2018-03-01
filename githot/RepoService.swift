//
//  RepoService.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import Foundation

enum ServiceError: String, Error {
    case noNetwork = "No Network"
    case permissionDenied = "You don't have permission"
}

typealias CompletionClosure = (_ repos:[Repo], _ error: ServiceError?) -> ()

protocol RepoServiceProtocol {
    func fetchTrendingRepos(completed: @escaping CompletionClosure)
}

class RepoService: RepoServiceProtocol {
    
    func fetchTrendingRepos(completed: @escaping CompletionClosure) {
        completed([], .noNetwork)
    }
}

class MockRepoService: RepoServiceProtocol {
    var completionClosure: CompletionClosure!
    var fetchTrendingReposCalled = false
    
    func fetchTrendingRepos(completed: @escaping CompletionClosure) {
        completed([], .noNetwork)
        fetchTrendingReposCalled = true
        completionClosure = completed
    }
    
    func fetchSuccess() {
        completionClosure([Repo](), nil)
    }
    
    func fetchFail(error: ServiceError?) {
        completionClosure([Repo](), error)
    }
}
