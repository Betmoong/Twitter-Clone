//
//  FeedController.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/03/22.
//

import UIKit
import SDWebImage

private let reuseIdentifire = "TweetCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet { configureLeftBarButton() }
    }
    
    private var tweets = [Tweet]() {
        // 데이터를 가져올 때, collectionView를 다시 리로드 (데이터를 아직 가져오지 못한 상태에서 View가 더 빠르게 나타나기 때문)
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - API
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchTweets { tweets in
            // 가져온 데이터를 [tweets] 배열에 넘김
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()   // 사용자가 해당 트윗을 좋아하는 지 확인하는 메서드
                        
            self.collectionView.refreshControl?.endRefreshing() // 트윗을 시간 순서대로 정렬
        }
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = . white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifire)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl() // 아래로 스크롤하면 새로고침
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        // 프로필 이미지를 탭할 경우, 작동할 수 있도록 설정
        profileImageView.isUserInteractionEnabled = true
        
        let tab = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tab)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {
    // 섹션의 항목 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    // 어떤 cell을 보여줄 건지
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifire, for: indexPath) as! TweetCell
        
        cell.delegate = self
        
        // 각 셀의 순서에 맞게 TweetCell에 있는 Tweet에 넣어준다.
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Feed에 있는 tweet을 indexPath.row을 통해 몇 번째 tweet이 클릭되었는 지 확인 후, 넘겨준다.
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    // cell의 사이즈 조절
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 선택한 cell을 넘겨준다.
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width, font: UIFont.systemFont(ofSize: 14)).height
        return CGSize(width: view.frame.width, height: height + 85)
    }
}

// MARK: - TweetCellDelegate

extension FeedController: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            // 트윗에 '좋아요'가 표시되는 경우만 알림 업로드
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user,
                                                          type: .like,
                                                          tweetID: tweet.tweetID)
        }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
