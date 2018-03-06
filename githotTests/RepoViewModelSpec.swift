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
        
        describe("A RepoViewModel") {
            
            let repoViewModel = RepoViewModel()
            
            context("After being properly initialized as a RepoViewModel") {
                
                it("should have at least one wheel") {
                    repoViewModel.searchBarSearchButtonTappedWith(text: "Swift")
                }
                
                it("should be loading") {
                    expect(repoViewModel.isLoading.value).to(beTrue())
                }
            }
        }
    }
    
}

