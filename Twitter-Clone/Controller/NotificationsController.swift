//
//  NotificationsController.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/03/22.
//

import UIKit

class NotificationsController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()        
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = . white
        navigationItem.title = "Notifications"
    }
}
