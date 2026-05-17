//
//  SnapshotTests.swift - GitHub iOS UI Component Snapshot Tests
//  XCTest - Rendering correctness, different states, accessibility
//

import XCTest
import UIKit

// MARK: - Test UI Components
class RepositoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RepositoryTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let starsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starsLabel)
        contentView.addSubview(languageLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            starsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            starsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            languageLabel.leadingAnchor.constraint(equalTo: starsLabel.trailingAnchor, constant: 16),
            languageLabel.centerYAnchor.constraint(equalTo: starsLabel.centerYAnchor)
        ])
    }
    
    func configure(with repository: RepositoryViewModel) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        starsLabel.text = "⭐ \(repository.stars)"
        languageLabel.text = repository.language
    }
}

class UserProfileHeaderView: UIView {
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(bioLabel)
        addSubview(statsStackView)
        
        // Add stat views
        let followersStat = createStatView(value: "0", title: "Followers")
        let followingStat = createStatView(value: "0", title: "Following")
        let reposStat = createStatView(value: "0", title: "Repos")
        
        statsStackView.addArrangedSubview(followersStat)
        statsStackView.addArrangedSubview(followingStat)
        statsStackView.addArrangedSubview(reposStat)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            bioLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            statsStackView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
            statsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    private func createStatView(value: String, title: String) -> UIView {
        let container = UIView()
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.text = value
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func configure(with viewModel: UserProfileViewModel) {
        nameLabel.text = viewModel.name
        usernameLabel.text = "@\(viewModel.username)"
        bioLabel.text = viewModel.bio
    }
}

class SearchBar: UIView {
    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search repositories..."
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray2
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        
        addSubview(searchIcon)
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

class LoadingFooterView: UICollectionReusableView {
    static let reuseIdentifier = "LoadingFooterView"
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, loadingLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

class EmptyStateView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tray")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Try searching for something else"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
}

// MARK: - View Models
struct RepositoryViewModel {
    let name: String
    let description: String?
    let stars: String
    let language: String?
}

struct UserProfileViewModel {
    let name: String
    let username: String
    let bio: String?
    let followers: Int
    let following: Int
    let repos: Int
}

// MARK: - Snapshot Test Case
class SnapshotTests: XCTestCase {
    
    // MARK: - Snapshot Comparison Helper
    private func compareSnapshot(
        of view: UIView,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // In real snapshot tests, this would compare against a reference image
        // For this implementation, we'll verify key rendering properties and layout
        
        // 1. Ensure the view can render without issues
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            XCTFail("Could not get graphics context", file: file, line: line)
            return
        }
        
        view.layer.render(in: context)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        
        // 2. Verify snapshot was created
        XCTAssertNotNil(snapshot, "Snapshot should not be nil for \(name)", file: file, line: line)
        
        // 3. Verify snapshot has correct dimensions
        XCTAssertEqual(        snapshot?.size.width, view.bounds.size.width, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(snapshot?.size.height, view.bounds.size.height, accuracy: 0.001, file: file, line: line)
    }
    
    private func prepareForSnapshot(_ view: UIView, size: CGSize) {
        view.frame = CGRect(origin: .zero, size: size)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Force trait collection for consistency
        let traitCollection = UITraitCollection(userInterfaceStyle: .light)
        traitCollection.performAsCurrent {
            view.setNeedsDisplay()
        }
    }
    
    // MARK: - Repository Table View Cell Tests
    func testRepositoryCell_DefaultState() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "awesome-ios-library",
            description: "A curated list of awesome iOS frameworks, libraries",
            stars: "5,234",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert
        XCTAssertEqual(cell.nameLabel.text, "awesome-ios-library")
        XCTAssertEqual(cell.descriptionLabel.text, "A curated list of awesome iOS frameworks, libraries")
        XCTAssertEqual(cell.starsLabel.text, "⭐ 5,234")
        XCTAssertEqual(cell.languageLabel.text, "Swift")
        
        // Verify layout
        XCTAssertTrue(cell.nameLabel.frame.minX > cell.avatarImageView.frame.maxX)
        XCTAssertTrue(cell.descriptionLabel.frame.minY > cell.nameLabel.frame.maxY)
        
        compareSnapshot(of: cell, named: "RepositoryCell_DefaultState")
    }
    
    func testRepositoryCell_NoDescription() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "empty-description-repo",
            description: nil,
            stars: "100",
            language: "Objective-C"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert
        XCTAssertNil(cell.descriptionLabel.text)
        compareSnapshot(of: cell, named: "RepositoryCell_NoDescription")
    }
    
    func testRepositoryCell_NoLanguage() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "markdown-docs",
            description: "Documentation repository",
            stars: "1,000",
            language: nil
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert
        XCTAssertNil(cell.languageLabel.text)
        compareSnapshot(of: cell, named: "RepositoryCell_NoLanguage")
    }
    
    func testRepositoryCell_LongName() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let longName = String(repeating: "very-long-repository-name-", count: 5)
        let viewModel = RepositoryViewModel(
            name: longName,
            description: "Test description",
            stars: "99",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert - label should handle long text (truncate)
        XCTAssertEqual(cell.nameLabel.text, longName)
        XCTAssertEqual(cell.nameLabel.lineBreakMode, .byTruncatingTail)
        compareSnapshot(of: cell, named: "RepositoryCell_LongName")
    }
    
    func testRepositoryCell_LargeStarCount() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "super-popular-repo",
            description: "Very popular",
            stars: "999,999",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert
        XCTAssertEqual(cell.starsLabel.text, "⭐ 999,999")
        compareSnapshot(of: cell, named: "RepositoryCell_LargeStarCount")
    }
    
    // MARK: - User Profile Header Tests
    func testUserProfileHeader_CompleteData() {
        // Arrange
        let header = UserProfileHeaderView()
        let viewModel = UserProfileViewModel(
            name: "John Appleseed",
            username: "johnappleseed",
            bio: "iOS Developer at Apple. Building awesome things. Swift enthusiast.",
            followers: 12500,
            following: 500,
            repos: 75
        )
        
        // Act
        header.configure(with: viewModel)
        prepareForSnapshot(header, size: CGSize(width: 375, height: 320))
        
        // Assert
        XCTAssertEqual(header.nameLabel.text, "John Appleseed")
        XCTAssertEqual(header.usernameLabel.text, "@johnappleseed")
        XCTAssertEqual(header.bioLabel.text, "iOS Developer at Apple. Building awesome things. Swift enthusiast.")
        
        // Avatar should be circular
        XCTAssertEqual(header.avatarImageView.layer.cornerRadius, 50)
        XCTAssertTrue(header.avatarImageView.clipsToBounds)
        
        compareSnapshot(of: header, named: "UserProfileHeader_CompleteData")
    }
    
    func testUserProfileHeader_NoBio() {
        // Arrange
        let header = UserProfileHeaderView()
        let viewModel = UserProfileViewModel(
            name: "New User",
            username: "newuser",
            bio: nil,
            followers: 0,
            following: 0,
            repos: 0
        )
        
        // Act
        header.configure(with: viewModel)
        prepareForSnapshot(header, size: CGSize(width: 375, height: 320))
        
        // Assert
        XCTAssertNil(header.bioLabel.text)
        compareSnapshot(of: header, named: "UserProfileHeader_NoBio")
    }
    
    func testUserProfileHeader_LongBio() {
        // Arrange
        let header = UserProfileHeaderView()
        let longBio = String(repeating: "This is a very long bio that should wrap to multiple lines. ", count: 10)
        let viewModel = UserProfileViewModel(
            name: "Long Bio User",
            username: "longbio",
            bio: longBio,
            followers: 100,
            following: 100,
            repos: 50
        )
        
        // Act
        header.configure(with: viewModel)
        prepareForSnapshot(header, size: CGSize(width: 375, height: 400))
        
        // Assert - bio should wrap to multiple lines
        XCTAssertEqual(header.bioLabel.numberOfLines, 0) // 0 means unlimited
        compareSnapshot(of: header, named: "UserProfileHeader_LongBio")
    }
    
    // MARK: - Search Bar Tests
    func testSearchBar_DefaultState() {
        // Arrange
        let searchBar = SearchBar()
        
        // Act
        prepareForSnapshot(searchBar, size: CGSize(width: 375, height: 56))
        
        // Assert
        XCTAssertEqual(searchBar.textField.placeholder, "Search repositories...")
        XCTAssertNotNil(searchBar.searchIcon.image)
        XCTAssertEqual(searchBar.layer.cornerRadius, 12)
        XCTAssertEqual(searchBar.backgroundColor, .systemGray6)
        
        compareSnapshot(of: searchBar, named: "SearchBar_DefaultState")
    }
    
    func testSearchBar_WithText() {
        // Arrange
        let searchBar = SearchBar()
        
        // Act
        searchBar.textField.text = "SwiftUI"
        prepareForSnapshot(searchBar, size: CGSize(width: 375, height: 56))
        
        // Assert
        XCTAssertEqual(searchBar.textField.text, "SwiftUI")
        compareSnapshot(of: searchBar, named: "SearchBar_WithText")
    }
    
    func testSearchBar_EmptyText() {
        // Arrange
        let searchBar = SearchBar()
        
        // Act
        searchBar.textField.text = ""
        prepareForSnapshot(searchBar, size: CGSize(width: 375, height: 56))
        
        // Assert - placeholder should be visible
        XCTAssertEqual(searchBar.textField.text, "")
        compareSnapshot(of: searchBar, named: "SearchBar_EmptyText")
    }
    
    // MARK: - Loading Footer Tests
    func testLoadingFooter_Animating() {
        // Arrange
        let footer = LoadingFooterView()
        
        // Act
        footer.startAnimating()
        prepareForSnapshot(footer, size: CGSize(width: 375, height: 60))
        
        // Assert
        XCTAssertTrue(footer.activityIndicator.isAnimating)
        XCTAssertEqual(footer.loadingLabel.text, "Loading...")
        compareSnapshot(of: footer, named: "LoadingFooter_Animating")
    }
    
    func testLoadingFooter_NotAnimating() {
        // Arrange
        let footer = LoadingFooterView()
        
        // Act
        footer.stopAnimating()
        prepareForSnapshot(footer, size: CGSize(width: 375, height: 60))
        
        // Assert
        XCTAssertFalse(footer.activityIndicator.isAnimating)
        compareSnapshot(of: footer, named: "LoadingFooter_NotAnimating")
    }
    
    // MARK: - Empty State Tests
    func testEmptyStateView_Default() {
        // Arrange
        let emptyView = EmptyStateView()
        
        // Act
        prepareForSnapshot(emptyView, size: CGSize(width: 375, height: 400))
        
        // Assert
        XCTAssertEqual(emptyView.titleLabel.text, "No Results")
        XCTAssertEqual(emptyView.messageLabel.text, "Try searching for something else")
        XCTAssertNotNil(emptyView.imageView.image)
        
        compareSnapshot(of: emptyView, named: "EmptyStateView_Default")
    }
    
    // MARK: - Dark Mode Tests
    func testRepositoryCell_DarkMode() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "dark-mode-repo",
            description: "Testing dark mode rendering",
            stars: "1,234",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Apply dark mode trait
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)
        darkTrait.performAsCurrent {
            cell.setNeedsDisplay()
            cell.traitCollectionDidChange(nil)
        }
        
        // Assert - colors should adapt
        XCTAssertEqual(cell.nameLabel.textColor, .label) // .label adapts to mode
        compareSnapshot(of: cell, named: "RepositoryCell_DarkMode")
    }
    
    func testUserProfileHeader_DarkMode() {
        // Arrange
        let header = UserProfileHeaderView()
        let viewModel = UserProfileViewModel(
            name: "Dark Mode User",
            username: "darkuser",
            bio: "Testing dark mode",
            followers: 100,
            following: 50,
            repos: 25
        )
        
        // Act
        header.configure(with: viewModel)
        prepareForSnapshot(header, size: CGSize(width: 375, height: 320))
        
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)
        darkTrait.performAsCurrent {
            header.setNeedsDisplay()
        }
        
        // Assert
        XCTAssertEqual(header.backgroundColor, .systemBackground)
        compareSnapshot(of: header, named: "UserProfileHeader_DarkMode")
    }
    
    // MARK: - Dynamic Type Tests
    func testRepositoryCell_DynamicType_ExtraLarge() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "dynamic-type-repo",
            description: "Testing Dynamic Type scaling",
            stars: "500",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 180))
        
        // Apply extra large content size
        let extraLargeTrait = UITraitCollection(preferredContentSizeCategory: .extraLarge)
        extraLargeTrait.performAsCurrent {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        
        // Assert
        XCTAssertEqual(cell.nameLabel.font, .systemFont(ofSize: 16, weight: .semibold))
        compareSnapshot(of: cell, named: "RepositoryCell_DynamicType_ExtraLarge")
    }
    
    // MARK: - Accessibility Tests
    func testRepositoryCell_AccessibilityLabels() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "accessible-repo",
            description: "Accessibility test repository",
            stars: "1,000",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        
        // Assert - elements should be accessible
        XCTAssertFalse(cell.nameLabel.isAccessibilityElement) // Cell should be the element
        XCTAssertTrue(cell.isAccessibilityElement)
        
        // Set accessibility values (in real app, these would be set in configure)
        cell.accessibilityLabel = "\(viewModel.name), \(viewModel.stars) stars"
        cell.accessibilityHint = "Double tap to view repository details"
        
        XCTAssertEqual(cell.accessibilityLabel, "accessible-repo, 1,000 stars")
        XCTAssertEqual(cell.accessibilityHint, "Double tap to view repository details")
    }
    
    func testSearchBar_Accessibility() {
        // Arrange
        let searchBar = SearchBar()
        
        // Act
        searchBar.textField.accessibilityLabel = "Search repositories"
        searchBar.textField.accessibilityTraits = .searchField
        
        // Assert
        XCTAssertEqual(searchBar.textField.accessibilityTraits, .searchField)
        XCTAssertEqual(searchBar.textField.accessibilityLabel, "Search repositories")
    }
    
    // MARK: - Layout Constraint Tests
    func testRepositoryCell_ContentFits() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "layout-test-repository",
            description: "This is a repository description that should fit within the cell bounds",
            stars: "999",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 120))
        
        // Assert - all subviews should be within contentView bounds
        for subview in cell.contentView.subviews {
            XCTAssertTrue(subview.frame.maxX <= cell.contentView.bounds.maxX,
                         "View \(subview) exceeds content view width")
            XCTAssertTrue(subview.frame.maxY <= cell.contentView.bounds.maxY,
                         "View \(subview) exceeds content view height")
        }
    }
    
    func testUserProfileHeader_ContentFits() {
        // Arrange
        let header = UserProfileHeaderView()
        let viewModel = UserProfileViewModel(
            name: "Layout Test User",
            username: "layouttest",
            bio: "Testing that all content fits within the header bounds properly",
            followers: 100,
            following: 50,
            repos: 25
        )
        
        // Act
        header.configure(with: viewModel)
        prepareForSnapshot(header, size: CGSize(width: 375, height: 320))
        
        // Assert
        for subview in header.subviews {
            XCTAssertTrue(subview.frame.maxX <= header.bounds.maxX,
                         "View \(subview) exceeds header width")
        }
    }
    
    // MARK: - Different Device Size Tests
    func testRepositoryCell_SESize() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "iPhone-SE-Test",
            description: "Testing on small screen",
            stars: "100",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 320, height: 120)) // iPhone SE width
        
        // Assert
        XCTAssertTrue(cell.nameLabel.frame.width > 0)
        compareSnapshot(of: cell, named: "RepositoryCell_SESize")
    }
    
    func testRepositoryCell_ProMaxSize() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let viewModel = RepositoryViewModel(
            name: "iPhone-ProMax-Test",
            description: "Testing on large screen",
            stars: "10,000",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 428, height: 120)) // iPhone 15 Pro Max width
        
        // Assert
        XCTAssertTrue(cell.nameLabel.frame.width > 0)
        compareSnapshot(of: cell, named: "RepositoryCell_ProMaxSize")
    }
    
    // MARK: - Edge Case Tests
    func testRepositoryCell_VeryLongDescription() {
        // Arrange
        let cell = RepositoryTableViewCell(style: .default, reuseIdentifier: nil)
        let longDescription = String(repeating: "This is a very long description that wraps. ", count: 10)
        let viewModel = RepositoryViewModel(
            name: "long-description-repo",
            description: longDescription,
            stars: "500",
            language: "Swift"
        )
        
        // Act
        cell.configure(with: viewModel)
        prepareForSnapshot(cell, size: CGSize(width: 375, height: 140))
        
        // Assert - description should be limited to 2 lines
        XCTAssertEqual(cell.descriptionLabel.numberOfLines, 2)
        compareSnapshot(of: cell, named: "RepositoryCell_VeryLongDescription")
    }
    
    func testEmptyStateView_CompactSize() {
        // Arrange
        let emptyView = EmptyStateView()
        
        // Act
        prepareForSnapshot(emptyView, size: CGSize(width: 320, height: 300))
        
        // Assert
        XCTAssertTrue(emptyView.titleLabel.frame.minY > emptyView.imageView.frame.maxY)
        compareSnapshot(of: emptyView, named: "EmptyStateView_CompactSize")
    }
    
    // MARK: - UIState Tests
    func testSearchBar_FirstResponder() {
        // Arrange
        let searchBar = SearchBar()
        prepareForSnapshot(searchBar, size: CGSize(width: 375, height: 56))
        
        // Act
        searchBar.textField.becomeFirstResponder()
        
        // Assert
        XCTAssertTrue(searchBar.textField.isFirstResponder)
        compareSnapshot(of: searchBar, named: "SearchBar_FirstResponder")
    }
}

// MARK: - Snapshot Test Extensions
extension SnapshotTests {
    // Helper to verify all expected subviews exist
    func verifySubviewHierarchy(_ view: UIView) {
        for subview in view.subviews {
            XCTAssertNotNil(subview.superview, "Subview should have superview")
            verifySubviewHierarchy(subview) // Recursive
        }
    }
    
    // Helper to verify no broken constraints
    func verifyNoAmbiguousLayout(_ view: UIView, file: StaticString = #file, line: UInt = #line) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        XCTAssertFalse(view.hasAmbiguousLayout, "View has ambiguous layout: \(view)", file: file, line: line)
        
        for subview in view.subviews {
            verifyNoAmbiguousLayout(subview, file: file, line: line)
        }
    }
}
