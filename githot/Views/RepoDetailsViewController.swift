//
//  RepoDetailsViewController.swift
//  githot
//
//  Created by Mijo Kaliger on 3/3/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import MarkdownView

struct RepoDetailsViewControllerConstants {
    static let AvatarImageViewBorderCGColor = UIColor(rgb: 0x607D8B).cgColor
    static let StarsForksContainerViewBorderCGColor = UIColor(rgb: 0xC9D3D8).cgColor
}

class RepoDetailsViewController: UIViewController {
    var viewModel:RepoDetailsViewModel!
    
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet var starsForksContainerView: UIView!
    @IBOutlet var starsButton: UIButton!
    @IBOutlet var forksButton: UIButton!
    @IBOutlet var markdownView: MarkdownView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.name
        avatarImageView.downloadedFrom(link: viewModel.avatarURL)
        usernameLabel.text = viewModel.username
        descriptionLabel.text = viewModel.description
        starsButton.setTitle(" \(viewModel.stars) Stars", for: .disabled)
        forksButton.setTitle(" \(viewModel.forks) Forks", for: .disabled)
                
        viewModel.readmeContentSignal.observeResult { (result) in
            if let readmeContent = result.value {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.markdownView.load(markdown: readmeContent)
                }
            }
        }
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        avatarImageView.layer.borderColor = RepoDetailsViewControllerConstants.AvatarImageViewBorderCGColor
        starsForksContainerView.layer.borderColor = RepoDetailsViewControllerConstants.StarsForksContainerViewBorderCGColor
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}
