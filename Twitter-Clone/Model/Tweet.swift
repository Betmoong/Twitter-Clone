//
//  Tweet.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/03.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetID: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    var user: User // user 속성을 사용하기 위함
    var didLike = false
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil } // TweetCell의 replyLabel을 표시할지 말지 결정하는 변수
    
    init(user:User, tweetID: String, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
