//
//  githotTests.swift
//  githotTests
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import XCTest
@testable import githot

class githotTests: XCTestCase {
    
    var repoService = MockRepoService()
    var repoViewModel: RepoViewModel!
    
    override func setUp() {
        repoViewModel = RepoViewModel(repoService: repoService)
    }
    
    func test_fetchRepos() {

        repoViewModel.fetchRepos()
        
        XCTAssert(repoService.fetchTrendingReposCalled)
    }
    
    func test_fetchRepoFail() {
        
        // Given
        let error = ServiceError.noNetwork
        
        // When
        repoViewModel.fetchRepos()
        repoService.fetchFail(error: error)
        
        // Then
        XCTAssertEqual(repoViewModel.alertMessage, error.rawValue)
    }
    
    func test_fetchRepoSuccess() {
        
        // Given
        // When
        repoViewModel.fetchRepos()
        repoService.fetchSuccess()
        
        // Then
        XCTAssertNil(repoViewModel.alertMessage)
        XCTAssertNotNil(repoViewModel.repos)
    }
    
}
