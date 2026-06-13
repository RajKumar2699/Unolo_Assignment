//
//  PhotoDetailViewController.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import UIKit
import SDWebImage

final class PhotoDetailViewController: UIViewController {
    private let viewModel: PhotoDetailViewModel
    var onSave: ((PhotoItem) -> Void)?
    var onDelete: ((Int64) -> Void)?

    private let imageView = UIImageView()
    private let textField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Detail"
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
        loadImage()
    }

    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .secondaryLabel

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Edit title"

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.configuration = .filled()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.configuration = .borderedTinted()
        deleteButton.configuration?.baseForegroundColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(deleteButton)

        view.addSubview(stackView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            imageView.heightAnchor.constraint(equalToConstant: 260),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureData() {
        textField.text = viewModel.photo.title.capitalized
    }


    private func loadImage() {
        let placeholder = UIImage(named: "img_placeholder") ?? UIImage(systemName: "photo")
        imageView.image = placeholder

        guard let url = URL(string: viewModel.photo.url) else {
            imageView.image = placeholder
            return
        }

        imageView.sd_setImage(
            with: url,
            placeholderImage: placeholder,
            options: [.retryFailed, .continueInBackground, .highPriority, .scaleDownLargeImages],
            completed: { [weak self] image, _, _, _ in
                self?.imageView.image = image ?? placeholder
            }
        )
    }

    @objc private func saveTapped() {
        setLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let updatedPhoto = try await self.viewModel.saveTitle(self.textField.text ?? "")
                self.onSave?(updatedPhoto)
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.presentError(error.localizedDescription)
            }
            self.setLoading(false)
        }
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Delete Photo", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performDelete() {
        setLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.viewModel.deletePhoto()
                self.onDelete?(self.viewModel.photo.id)
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.presentError(error.localizedDescription)
            }
            self.setLoading(false)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        saveButton.isEnabled = !isLoading
        deleteButton.isEnabled = !isLoading
        textField.isEnabled = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
