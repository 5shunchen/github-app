//
//  ProfileViewController.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import UIKit

public protocol ProfileViewControllerDelegate: AnyObject {
    func didLogout()
}

public final class ProfileViewController: UIViewController {
    
    public weak var delegate: ProfileViewControllerDelegate?
    
    private var user: GitHubUser?
    private var imageLoadTask: Task<Void, Never>?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        fetchUserProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(logoutButton)
        
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            statsStackView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 32),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            infoStackView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 32),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            logoutButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private func fetchUserProfile() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let user = try await UserService.shared.fetchCurrentUser()
                await MainActor.run {
                    self.user = user
                    self.updateUI(with: user)
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showError(message: "Failed to load profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI(with user: GitHubUser) {
        nameLabel.text = user.displayName
        usernameLabel.text = "@\(user.login)"
        bioLabel.text = user.bio
        
        imageLoadTask = avatarImageView.loadImage(
            from: user.avatarURL,
            placeholder: UIImage(systemName: "person.circle.fill")
        )
        
        setupStatsView(repos: user.publicRepos, followers: user.followers, following: user.following)
        setupInfoView(with: user)
    }
    
    private func setupStatsView(repos: Int, followers: Int, following: Int) {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let repoView = createStatView(value: "\(repos)", title: "Repos")
        let followersView = createStatView(value: "\(followers)", title: "Followers")
        let followingView = createStatView(value: "\(following)", title: "Following")
        
        statsStackView.addArrangedSubview(repoView)
        statsStackView.addArrangedSubview(followersView)
        statsStackView.addArrangedSubview(followingView)
    }
    
    private func createStatView(value: String, title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.text = value
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
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
    
    private func setupInfoView(with user: GitHubUser) {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let company = user.company, !company.isEmpty {
            infoStackView.addArrangedSubview(createInfoRow(icon: "building.2", text: company))
        }
        
        if let location = user.location, !location.isEmpty {
            infoStackView.addArrangedSubview(createInfoRow(icon: "location", text: location))
        }
        
        if let blog = user.blog, !blog.isEmpty {
            infoStackView.addArrangedSubview(createInfoRow(icon: "link", text: blog))
        }
        
        infoStackView.addArrangedSubview(createInfoRow(icon: "calendar", text: user.formattedJoinDate))
    }
    
    private func createInfoRow(icon: String, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: icon)
        imageView.tintColor = .secondaryLabel
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.text = text
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            GitHubAuthManager.shared.logout()
            self?.delegate?.didLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
