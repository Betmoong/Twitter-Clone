//
//  ActionSheetViewModel.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/11.
//

import Foundation

struct ActionSheetViewModel {
    
    private let user: User
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        // 현재 사용자의 트윗일 경우 삭제 옵션 추가
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            // 현재 사용자가 다른 사용자를 팔로우 중이라면 언팔로우, 아니라면 팔로우 옵션 추가
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.report)
        
        return results
    }
    
    init(user: User) {
        self.user = user
    }
}

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user): return "Follow @\(user.username)"
        case .unfollow(let user): return "Unfollow @\(user.username)"
        case .report: return "Report Tweet"
        case .delete: return "Delete Tweet"
        }
    }
}
