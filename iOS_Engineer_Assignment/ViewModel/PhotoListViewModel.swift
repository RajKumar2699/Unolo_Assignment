//
//  PhotoListViewModel.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation
import UIKit

@MainActor
final class PhotoListViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    enum PhotoChange {
        case reload
        case inserted([IndexPath])
        case deleted([IndexPath])
        case updated([IndexPath])
    }

    private let repository: PhotoRepositoryProtocol

    private(set) var photos: [PhotoItem] = []
    private(set) var state: State = .idle {
        didSet { onStateChange?() }
    }

    var onStateChange: (() -> Void)?
    var onPhotosChange: ((PhotoChange) -> Void)?

    private let batchSize = 50
    private var currentOffset = 0
    private var isLoadingMore = false
    private var hasMoreData = true

    init(repository: PhotoRepositoryProtocol) {
        self.repository = repository
    }

    func loadPhotos() {
        state = .loading
        Task { await performInitialLoad() }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= photos.count - 10,
              !isLoadingMore,
              hasMoreData,
              state != .loading else { return }

        isLoadingMore = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let newItems = try self.repository.loadMore(offset: self.currentOffset, limit: self.batchSize)
                await MainActor.run {
                    if newItems.isEmpty {
                        self.hasMoreData = false
                    } else {
                        let startIndex = self.photos.count
                        self.photos.append(contentsOf: newItems)
                        self.currentOffset += newItems.count
                        let indexPaths = (startIndex..<self.photos.count).map { IndexPath(row: $0, section: 0) }
                        self.onPhotosChange?(.inserted(indexPaths))
                        self.state = .loaded
                    }
                    self.isLoadingMore = false
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                    self.isLoadingMore = false
                }
            }
        }
    }

    func numberOfItems() -> Int {
        photos.count
    }

    func photo(at index: Int) -> PhotoItem {
        photos[index]
    }

    func refreshUpdatedPhoto(_ updatedPhoto: PhotoItem) {
        guard let index = photos.firstIndex(where: { $0.id == updatedPhoto.id }) else { return }
        photos[index] = updatedPhoto
        onPhotosChange?(.updated([IndexPath(row: index, section: 0)]))
    }

    func removePhoto(id: Int64) {
        guard let index = photos.firstIndex(where: { $0.id == id }) else { return }
        photos.remove(at: index)
        onPhotosChange?(.deleted([IndexPath(row: index, section: 0)]))
        state = photos.isEmpty ? .empty : .loaded
    }

    func deletePhoto(at index: Int) {
        guard photos.indices.contains(index) else { return }
        let id = photos[index].id
        Task {
            do {
                try await repository.deletePhoto(id: id)
                await MainActor.run {
                    self.removePhoto(id: id)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    private func performInitialLoad() async {
        do {
            let initial = try await repository.loadInitialPhotos()
            photos = initial
            currentOffset = initial.count
            hasMoreData = (try repository.totalCount()) > currentOffset

            onPhotosChange?(.reload)
            state = initial.isEmpty ? .empty : .loaded
        } catch {
            photos = []
            onPhotosChange?(.reload)
            state = .error(error.localizedDescription)
        }
    }
}
