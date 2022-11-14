//
//  ActivityIndicatorView.swift
//  ITinder
//
//  Created by Mary Matichina on 28.08.2021.
//

import Foundation
import UIKit

class ActivityIndicatorViewController: UIViewController {
    
    // MARK: - Properties
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
    }
}
