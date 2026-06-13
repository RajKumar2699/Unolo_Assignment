//
//  PhotoRepositoryProtocol.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import CoreData

protocol PhotoRepositoryProtocol {
    func loadInitialPhotos() async throws -> [PhotoItem]
    func loadMore(offset: Int, limit: Int) throws -> [PhotoItem]
    func totalCount() throws -> Int
    func updateTitle(id: Int64, title: String) async throws
    func deletePhoto(id: Int64) async throws
}

final class PhotoRepository: PhotoRepositoryProtocol {
    private let apiClient: PhotoAPIClientProtocol
    private let persistence: PersistenceController

    init(
        apiClient: PhotoAPIClientProtocol = PhotoAPIClient(),
        persistence: PersistenceController = .shared
    ) {
        self.apiClient = apiClient
        self.persistence = persistence
    }

    func loadInitialPhotos() async throws -> [PhotoItem] {
        let existingCount = try totalCount()
        if existingCount > 0 {
            return try loadMore(offset: 0, limit: 50)
        }

        let remotePhotos = try await apiClient.fetchPhotos()
        try await saveOrUpdate(photos: remotePhotos)

        return try await fetchPhotos(limit: 50, offset: 0)
    }

    func loadMore(offset: Int, limit: Int) throws -> [PhotoItem] {
        try persistence.viewContext.performAndWait {
            try fetchPhotosSync(limit: limit, offset: offset)
        }
    }

    func totalCount() throws -> Int {
        let request: NSFetchRequest<CDPhoto> = CDPhoto.fetchRequest()
        do {
            return try persistence.viewContext.count(for: request)
        } catch {
            throw CoreDataError.fetchFailed
        }
    }

    func updateTitle(id: Int64, title: String) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<CDPhoto> = CDPhoto.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %d", id)

            guard let photo = try context.fetch(request).first else { return }
            guard photo.title != title else { return }

            photo.title = title
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    throw CoreDataError.saveFailed
                }
            }
        }
    }

    func deletePhoto(id: Int64) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<CDPhoto> = CDPhoto.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %d", id)

            guard let photo = try context.fetch(request).first else { return }
            context.delete(photo)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    throw CoreDataError.deleteFailed
                }
            }
        }
    }

    private func saveOrUpdate(photos: [PhotoDTO]) async throws {
        let context = persistence.newBackgroundContext()

        try await context.perform {
            for dto in photos {
                let request: NSFetchRequest<CDPhoto> = CDPhoto.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %d", dto.id)

                let entity = (try? context.fetch(request).first) ?? CDPhoto(context: context)
                entity.id = Int64(dto.id)
                entity.albumId = Int64(dto.albumId)
                entity.title = dto.title
                entity.url = dto.url
                entity.thumbnailUrl = dto.thumbnailUrl
            }

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    throw CoreDataError.saveFailed
                }
            }
        }

        persistence.viewContext.performAndWait {
            persistence.viewContext.refreshAllObjects()
        }
    }

    private func fetchPhotos(limit: Int, offset: Int) async throws -> [PhotoItem] {
        try await persistence.viewContext.perform {
            try self.fetchPhotosSync(limit: limit, offset: offset)
        }
    }

    private func fetchPhotosSync(limit: Int, offset: Int) throws -> [PhotoItem] {
        let request: NSFetchRequest<CDPhoto> = CDPhoto.fetchRequest()
        request.fetchOffset = offset
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        do {
            let result = try persistence.viewContext.fetch(request)
            return result.map { PhotoItem(entity: $0) }
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
}
