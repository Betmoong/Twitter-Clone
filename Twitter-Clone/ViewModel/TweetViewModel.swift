//
//  TweetViewModel.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/04/03.
//

import UIKit

struct TweetViewModel {
    
    // MARK: - Properties
    
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL? {
        return tweet.user.profileImageUrl
    }
    
    var timestamp: String {
        // 날짜를 어떻게 나타날지
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date() // 현재 시간
        // 트윗했을 때의 시간과 현재 시간을 비교
        return formatter.string(from: tweet.timestamp, to: now) ?? ""
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ･ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var retweetAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.retweetCount, text: "Retweets")
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.likes, text: "Likes")
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname,
                                              attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user.username)",
            attributes: [.font: UIFont.systemFont(ofSize: 14),
                         .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " ・ \(timestamp)",
            attributes: [.font: UIFont.systemFont(ofSize: 14),
                         .foregroundColor: UIColor.lightGray]))
        
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }
    
    var replyText: String? {
        guard let replyingToUsername = tweet.replyingTo else { return nil }
        return "→ replying to @\(replyingToUsername)"
    }
    
    // MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                   attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                 .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
    // MARK: - Helpers
    
    // label의 텍스트 수에 따라 높이를 반환해주는 함수
    func size(forWidth width: CGFloat, font: UIFont) -> CGSize {
        let measurementLabel = UILabel()    // caption의 길이를 측정하는 UILabel
        measurementLabel.text = tweet.caption
        measurementLabel.font = font
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping    // 단어 단위로 줄바꿈
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
