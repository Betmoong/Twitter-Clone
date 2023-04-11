//
//  ActionSheetLauncher.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/11.
//

import Foundation

class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties
    
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    // MARK: - Helpers
    
    func show() {
        print("DEBUG: Show action sheet for user \(user.username)")
    }
}
