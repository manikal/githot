//
//  RepoViewModelSpec.swift
//  githotTests
//
//  Created by Mijo Kaliger on 3/6/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa

@testable import githot

class RepoViewModelSpec: QuickSpec {
    
    override func spec() {
        
        context("should start search with unknown keyword") {

            let repoViewModel = RepoViewModel()

            repoViewModel.searchRepos(text: "lkjh34kh23o7439287323df")

            it ("should not have any cell") {
                expect(repoViewModel.cellsCount).toEventually(equal(0), timeout: 7)
            }
        }
        
        context("should start loading repos") {

            let repoViewModel = RepoViewModel()

            repoViewModel.searchRepos(text: "swift")
            
            it("should be in loading mode") {
                expect(repoViewModel.isLoading.value).to(beTrue())
            }

            it("should have items count") {
                // GitHub Search API is limited to max 10 pages (1000 items)
                expect(repoViewModel.allReposCount).toEventually(beGreaterThan(1000), timeout: 5)
            }
            
            it("should not be in loading mode") {
                expect(repoViewModel.isLoading.value).toEventually(beFalse(), timeout: 5)
            }
        }
    }
}

