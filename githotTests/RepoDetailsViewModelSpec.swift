//
//  RepoDetailsViewModelSpec.swift
//  githotTests
//
//  Created by Mijo Kaliger on 3/6/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa

@testable import githot

class RepoDetailsViewModelSpec: QuickSpec {
    
    override func spec() {
        context("given repository with readme content") {
            let repoViewModel = RepoViewModel()
            
            repoViewModel.searchRepos(text: "thorrson")
            
            var readmeContent = ""
            
            it("should have one repo") {
                expect(repoViewModel.cellsCount).toEventually(equal(1), timeout:5)
                
                let repoDetailsViewModel = repoViewModel.repoDetailsViewModel(at: IndexPath(row: 0, section: 0))
                

                repoDetailsViewModel.readmeContentSignal.observeResult({ (result) in
                    if let content = result.value {
                        readmeContent = content
                    }
                })
            }
            
            it("should load readme content") {
                expect(readmeContent.count).toEventually(beGreaterThan(0), timeout:10)
            }
        }
        
        context("given repository without readme content") {
            let repoViewModel = RepoViewModel()
            
            repoViewModel.searchRepos(text: "kaliger")
            
            var readmeContentError = ""
            
            it("should have one repo") {
                expect(repoViewModel.cellsCount).toEventually(equal(1), timeout:5)
                
                let repoDetailsViewModel = repoViewModel.repoDetailsViewModel(at: IndexPath(row: 0, section: 0))
                
                repoDetailsViewModel.readmeContentErrorSignal.observeResult({ (result) in
                    if let content = result.value {
                        readmeContentError = content
                    }
                })
            }
            
            it("should have readme content empty message") {
                expect(readmeContentError).toEventually(equal(ServiceError.readmeContentEmpty.rawValue), timeout:10)
            }
        }
    }
}
