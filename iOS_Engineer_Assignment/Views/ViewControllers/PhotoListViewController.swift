//
//  PhotoListViewController.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import UIKit
import SDWebImage

final class PhotoListViewController: UIViewController {
    private let viewModel: PhotoListViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    private var isPerformingBatchUpdates = false

    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Gallery"
        self.tableView.separatorStyle = .none
        view.backgroundColor = .systemBackground
        setupTableView()
        setupStateViews()
        bindViewModel()
        viewModel.loadPhotos()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.reuseIdentifier)
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 84
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStateViews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            self?.renderState()
        }

        viewModel.onPhotosChange = { [weak self] (change: PhotoListViewModel.PhotoChange) in
            self?.apply(change: change)
        }
    }
    
    
    private func renderState() {
           switch viewModel.state {
           case .idle:
               activityIndicator.stopAnimating()
               messageLabel.isHidden = true
           case .loading:
               activityIndicator.startAnimating()
               messageLabel.isHidden = true
           case .loaded:
               activityIndicator.stopAnimating()
               messageLabel.isHidden = true
           case .empty:
               activityIndicator.stopAnimating()
               messageLabel.isHidden = false
               messageLabel.text = "No photos available."
           case .error(let message):
               activityIndicator.stopAnimating()
               messageLabel.isHidden = false
               messageLabel.text = message
               showRetryAlert(message: message)
           }
       }

       private func apply(change: PhotoListViewModel.PhotoChange) {
           switch change {
           case .reload:
               tableView.reloadData()

           case .inserted(let indexPaths):
               guard !indexPaths.isEmpty else { return }
               isPerformingBatchUpdates = true
               tableView.performBatchUpdates {
                   tableView.insertRows(at: indexPaths, with: .fade)
               } completion: { [weak self] _ in
                   self?.isPerformingBatchUpdates = false
               }

           case .deleted(let indexPaths):
               guard !indexPaths.isEmpty else { return }
               isPerformingBatchUpdates = true
               tableView.performBatchUpdates {
                   tableView.deleteRows(at: indexPaths, with: .automatic)
               } completion: { [weak self] _ in
                   self?.isPerformingBatchUpdates = false
               }

           case .updated(let indexPaths):
               guard !indexPaths.isEmpty else { return }
               tableView.reloadRows(at: indexPaths, with: .none)
           }
       }

       private func showRetryAlert(message: String) {
           guard presentedViewController == nil else { return }
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
               self?.viewModel.loadPhotos()
           })
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           present(alert, animated: true)
       }

       private func showDeleteConfirmation(at indexPath: IndexPath) {
           let alert = UIAlertController(
               title: "Delete Photo",
               message: "Are you sure you want to delete this photo?",
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
               self?.viewModel.deletePhoto(at: indexPath.row)
           })
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           present(alert, animated: true)
       }
   }

   extension PhotoListViewController: UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           viewModel.numberOfItems()
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(
               withIdentifier: PhotoCell.reuseIdentifier,
               for: indexPath
           ) as? PhotoCell else {
               return UITableViewCell()
           }

           let photo = viewModel.photo(at: indexPath.row)
           cell.configure(with: photo)
           return cell
       }
   }

   extension PhotoListViewController: UITableViewDelegate {
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)

           let photo = viewModel.photo(at: indexPath.row)
           let detailViewModel = PhotoDetailViewModel(photo: photo, repository: PhotoRepository())
           let controller = PhotoDetailViewController(viewModel: detailViewModel)

           controller.onSave = { [weak self] updated in
               self?.viewModel.refreshUpdatedPhoto(updated)
           }

           controller.onDelete = { [weak self] deletedID in
               self?.viewModel.removePhoto(id: deletedID)
           }

           navigationController?.pushViewController(controller, animated: true)
       }

       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
               self?.showDeleteConfirmation(at: indexPath)
               completion(true)
           }
           return UISwipeActionsConfiguration(actions: [deleteAction])
       }

       func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
       }
   }

   extension PhotoListViewController: UITableViewDataSourcePrefetching {
       func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
           let urls = indexPaths.compactMap { indexPath -> URL? in
               guard indexPath.row < viewModel.numberOfItems() else { return nil }
               return URL(string: viewModel.photo(at: indexPath.row).thumbnailUrl)
           }

           SDWebImagePrefetcher.shared.prefetchURLs(urls)
       }

       func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
           SDWebImagePrefetcher.shared.cancelPrefetching()
       }
   }
