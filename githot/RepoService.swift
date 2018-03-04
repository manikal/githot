//
//  RepoService.swift
//  githot
//
//  Created by Mijo Kaliger on 3/1/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError

private struct RepoServiceConstants {
    static let SearchReposAPI = "https://api.github.com/search/repositories?q=%@&sort=stars&order=desc&per_page=100" // 30 requests per minute
    static let ReadmeAPI = "https://api.github.com/repos/%@/%@/readme"
    static let Token = "1be19c55826dce97ac9f831f5e7b2aac13260104"
    static let UserName = "manikal"
}

enum ServiceError: String, Error {
    case requestFailed = "Request Failed"
    case conversionFailed = "JSON response serialization failed"
    case creatingRequestFailed = "Creating search request URL failed"
    case creatingReadmeRequestFailed = "Creating readme request URL failed"
    case decodingReadmeFailed = "Decoding readme content failed"
    case encodingReadmeFailed = "Encoding readme data to string failed"
    case readmeContentEmpty = "Readme content empty"
}

class RepoService {
    
    private(set) var repos = MutableProperty([Repo]())
    private(set) var errorSignal:  Signal<ServiceError,NoError>
    private(set) var readmeSignal: Signal<String, NoError>
    private let readmeObserver: Signal<String, NoError>.Observer
    private let errorObserver: Signal<ServiceError,NoError>.Observer
    
    init() {
        (errorSignal, errorObserver) = Signal.pipe()
        (readmeSignal, readmeObserver) = Signal.pipe()
    }
    
    private func performSearchRepos(text: String) -> SignalProducer<[Repo], ServiceError> {
        return SignalProducer { producer, disposable -> () in
            
            guard let searchReposAPI = String(format:RepoServiceConstants.SearchReposAPI, text).addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed), let searchRequestURL = URL(string: searchReposAPI) else { return producer.send(error: ServiceError.creatingRequestFailed) }
            
            var request = URLRequest(url: searchRequestURL)
            request.setValue("token \(RepoServiceConstants.Token)", forHTTPHeaderField: "Authentication")
            request.setValue(RepoServiceConstants.UserName, forHTTPHeaderField: "User-Agent")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    guard let data = data else { return producer.send(value: []) }

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
                                producer.send(value: [])
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
    
    private func performReadmeFetch(owner: String, repoName: String) -> SignalProducer<String, ServiceError>  {
        return SignalProducer { producer, disposable -> () in
           
            let readmeURLString = String(format: RepoServiceConstants.ReadmeAPI, owner, repoName)
            guard let readmeURL = URL(string: readmeURLString) else { return producer.send(error: ServiceError.creatingRequestFailed) }
            
            var request = URLRequest(url: readmeURL)
            request.setValue("token \(RepoServiceConstants.Token)", forHTTPHeaderField: "Authentication")
            request.setValue(RepoServiceConstants.UserName, forHTTPHeaderField: "User-Agent")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    guard let data = data else {  throw ServiceError.requestFailed }
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { throw ServiceError.conversionFailed }
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        if let base64EncodedContentString = json["content"] as? String {
                            guard let decodedData = Data(base64Encoded: base64EncodedContentString, options: .ignoreUnknownCharacters) else { throw ServiceError.decodingReadmeFailed }
                            guard let decodedString = String(data: decodedData, encoding: .utf8) else { throw ServiceError.encodingReadmeFailed }
                            
                            if decodedString.count > 0 {
                                producer.send(value: decodedString)
                            } else {
                                 throw ServiceError.readmeContentEmpty
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
    
    func fetchReadme(owner: String, repoName: String) {
        self.performReadmeFetch(owner: owner, repoName: repoName).startWithResult { [weak self] result in
            guard let strongSelf = self else { return }
            if let readmeContent = result.value {
                strongSelf.readmeObserver.send(value: readmeContent)
            } else if let error = result.error {
                strongSelf.errorObserver.send(value: error)
            }
        }
    }
}

extension Repo {
    init(data: [String : Any]) {
        
        self.name = data["name"] as? String ?? ""
        self.description = data["description"] as? String ?? ""

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
        
        if let owner = data["owner"] as? [String : Any] {
            self.avatarURL = owner["avatar_url"] as? String ?? ""
            self.author = owner["login"] as? String ?? ""
        } else {
            self.avatarURL = ""
            self.author = ""
        }
    }
}

