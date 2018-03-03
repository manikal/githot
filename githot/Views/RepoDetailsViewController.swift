//
//  RepoDetailsViewController.swift
//  githot
//
//  Created by Mijo Kaliger on 3/3/18.
//  Copyright © 2018 AirCutDev. All rights reserved.
//

import UIKit

class RepoDetailsViewController: UIViewController {
    var viewModel:RepoDetailsViewModel!
    
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.name
        avatarImageView.downloadedFrom(link: viewModel.avatarURL)
        usernameLabel.text = viewModel.username
        descriptionLabel.text = viewModel.description
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}
