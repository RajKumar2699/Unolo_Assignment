//
//  PhotoCell.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import UIKit
import SDWebImage

final class PhotoCell: UITableViewCell {
    static let reuseIdentifier = "PhotoCell"

    private let placeholderImage = UIImage(named: "img_placeholder") ?? UIImage(systemName: "photo")

    private let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .secondaryLabel
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.sd_cancelCurrentImageLoad()
        thumbImageView.image = placeholderImage
        titleLabel.text = nil
    }

    func configure(with photo: PhotoItem) {
        titleLabel.text = photo.title.capitalized
        subtitleLabel.text = "Album #\(photo.albumId) · ID \(photo.id)"
        thumbImageView.image = placeholderImage

        guard let url = URL(string: photo.thumbnailUrl) else {
            thumbImageView.image = placeholderImage
            return
        }

        thumbImageView.sd_setImage(
            with: url,
            placeholderImage: placeholderImage,
            options: [.retryFailed, .continueInBackground, .scaleDownLargeImages],
            completed: { [weak self] image, _, _, _ in
                self?.thumbImageView.image = image ?? self?.placeholderImage
            }
        )
    }

    
    private func setupUI() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        contentView.addSubview(thumbImageView)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 64),
            thumbImageView.heightAnchor.constraint(equalToConstant: 64),
            thumbImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

            stack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
