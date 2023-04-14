//
//  User.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/03/30.
//

import Foundation
import Firebase

struct User {
    var fullname: String
    let email: String
    var username: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false // 사용자가 팔로우를 하고 있는 지 확인하는 변수, 사용자 데이터를 가져온 후에 사용할 수 있기 때문에 값을 넣어줌
    var stats: UserRelationStats?
    var bio: String?
    
    // 사용자가 로그인 했는지 안했는지 확인해주는 변수
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""

        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            // String을 URL의 형태로 바꾸기
            guard let url = URL(string: profileImageUrlString) else { return }
            // url값 넣어주기
            self.profileImageUrl = url
        }
    }
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}
