//
//  UploadTweetViewModel.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/11.
//

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet) // 답장 트윗의 경우 다른 트윗으로 연결
}

struct UploadTweetViewModel {
    
    // 일반 트윗의 경우 Tweet을 보여주고, 답장 트윗의 경우 Reply를 보여주기
    let actionButtonTitle: String
    // 일반 트윗의 경우와 답장 트윗에 따라 placeholder의 내용이 다르다
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var replyText: String?
    
    init(config: UploadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening"
            shouldShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
        }
    }
}
