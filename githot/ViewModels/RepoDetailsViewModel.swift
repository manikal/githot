//
//  RepoDetailsViewModel.swift
//  githot
//
//  Created by Mijo Kaliger on 3/3/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError

struct RepoDetailsViewModel {
    let name: String
    let avatarURL: String
    let username: String
    let description: String
    let stars: String
    let forks: String
    
    var readmeContentSignal: Signal<String,NoError>
    var readmeContentErrorSignal: Signal<String, NoError>
}

