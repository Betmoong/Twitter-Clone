//
//  ProfileHeaderViewModel.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/04.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String{
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: User
    
    let usernameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var bioString: String? {
        return user.bio
    }
    
    var actionButtonTitle: String {
        // 현재 사용자가 자신의 프로필을 열람할 경우
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        // 열람하는 프로필의 사용자가 팔로우가 안되어 있고, 현재 사용자가 아닐경우
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        
        if user.isFollowed {
            return "Following"
        }
        
        return "Loading"
    }
    
    init(user: User) {
        self.user = user
        
        self.usernameText = "@" + user.username
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                   attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                 .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
