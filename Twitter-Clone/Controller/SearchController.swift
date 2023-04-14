//
//  SearchController.swift
//  Twitter-Clone
//
//  Created by Rocky on 2023/03/22.
//

import UIKit

private let reuseIdentifier = "UserCell"

enum SearchControllerConfiguration {
    case messages
    case userSearch
}

class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    // 검색창에서 텍스트가 변경될 때마다, 테이블뷰 리로드
    private var filterUsers = [User]() {
        didSet { tableView.reloadData() }
    }
    
    // 현재 검색모드에 있는 지 확인
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    init (config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = . white
        navigationItem.title = config == .messages ? "New Message" : "Search"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self, action: #selector(handleDismissal))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false   // 검색창을 눌렀을 때, false일 경우 배경이 흰색, true일 경우 배경이 회색
        searchController.hidesNavigationBarDuringPresentation = false   // 검색하는 동안 네비게이션바에 가려지지 않도록 설정
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false  // false일 경우 최상위 뷰컨트롤러의 뷰까지 올라온다.
    }
}

// MARK: - UITableViewDelegate/DataSource

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        // 검색모드인 경우 필터링된 유저 표시, 아니라면 모든 유저 표시
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 검색모드와 아닌 모드에서 index가 꼬일 수 있기 때문에, 그대로 가져와야 한다.
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    // 텍스트가 입력될 때마다 searchController.searchBar.text 글자를 받아온다.
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        // users 배열에서 searchText가 담고 있는 username을 가져온다.
        filterUsers = users.filter({ $0.username.contains(searchText) })
    }
}
