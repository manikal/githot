//
//  RepoService.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import Foundation
//import AFNetworking
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError

private struct RepoServiceConstants {
    static let SearchReposAPI = "https://api.github.com/search/repositories?q=%@&sort=stars&order=desc&per_page=200" // 30 requests per minute
    static let Token = "1be19c55826dce97ac9f831f5e7b2aac13260104"
    static let UserName = "manikal"
}

enum ServiceError: String, Error {
    case noData = "No Data"
    case requestFailed = "Request Failed"
    case conversionFailed = "JSON response serialization failed"
    case creatingRequestFailed = "Creating search request URL failed"
}

class RepoService {
    
    private(set) var repos = MutableProperty([Repo]())
    private(set) var errorSignal:  Signal<ServiceError,NoError>
    private let errorObserver: Signal<ServiceError,NoError>.Observer
    
    init() {
        (errorSignal, errorObserver) = Signal.pipe()
    }
    
    private func performSearchRepos(text: String) -> SignalProducer<[Repo], ServiceError> {
        return SignalProducer { producer, disposable -> () in
            
            guard let searchReposAPI = String(format:RepoServiceConstants.SearchReposAPI, text).addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed), let searchRequestURL = URL(string: searchReposAPI) else { return producer.send(error: ServiceError.creatingRequestFailed) }
            
            var request = URLRequest(url: searchRequestURL)
            request.setValue("token \(RepoServiceConstants.Token)", forHTTPHeaderField: "Authentication")
            request.setValue(RepoServiceConstants.UserName, forHTTPHeaderField: "User-Agent")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    guard let data = data else { throw ServiceError.noData }

                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { throw ServiceError.conversionFailed }
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        if let itemsArray = json["items"] as? [Dictionary<String,Any>] {
                            var models = [Repo]()
                            for data in itemsArray {
                                let model = Repo(data: data)
                                models.append(model)
                            }
                            if models.count > 0 {
                                producer.send(value: models)
                            } else {
                                throw ServiceError.noData
                            }
                        }
                    } else {
                        throw ServiceError.requestFailed
                    }
                } catch let error as ServiceError {
                    producer.send(error: error)
                } catch let error as NSError {
                    if let serviceError = ServiceError(rawValue: error.debugDescription) {
                        producer.send(error: serviceError)
                    }
                }
              }.resume()
        }
    }
    
    func searchRepos(text: String) {
        self.performSearchRepos(text:text).startWithResult { [weak self] result in
            guard let strongSelf = self else { return }
            if let models = result.value {
                strongSelf.repos.value = models
            } else if let error = result.error {
                strongSelf.errorObserver.send(value: error)
            }
        }
    }
}

extension Repo {
    init(data: [String : Any]) {
        self.name = data["name"] as? String ?? ""
        
        if let stars = data["watchers"] as? Int {
            self.stars = String(stars)
        } else {
            self.stars = "0"
        }
        
        if let forks = data["forks"] as? Int {
            self.forks = String(forks)
        } else {
            self.forks = "0"
        }
        
        self.description = data["description"] as? String ?? ""
        
        if let owner = data["owner"] as? [String : Any] {
            self.avatarURL = owner["avatar_url"] as? String ?? ""
            self.author = owner["login"] as? String ?? ""
        } else {
            self.avatarURL = ""
            self.author = ""
        }
    }
}

