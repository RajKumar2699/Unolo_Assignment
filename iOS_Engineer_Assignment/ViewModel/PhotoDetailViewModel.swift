//
//  PhotoDetailViewModel.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

@MainActor
final class PhotoDetailViewModel {
    private let repository: PhotoRepositoryProtocol
    private(set) var photo: PhotoItem

    init(photo: PhotoItem, repository: PhotoRepositoryProtocol) {
        self.photo = photo
        self.repository = repository
    }

    func saveTitle(_ title: String) async throws -> PhotoItem {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmed.isEmpty ? photo.title : trimmed
        try await repository.updateTitle(id: photo.id, title: finalTitle)
        photo = PhotoItem(albumId: photo.albumId, id: photo.id, title: finalTitle, url: photo.url, thumbnailUrl: photo.thumbnailUrl)
        return photo
    }

    func deletePhoto() async throws {
        try await repository.deletePhoto(id: photo.id)
    }
}