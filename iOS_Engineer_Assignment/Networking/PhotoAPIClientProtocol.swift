//
//  PhotoAPIClientProtocol.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

protocol PhotoAPIClientProtocol {
    func fetchPhotos() async throws -> [PhotoDTO]
}

final class PhotoAPIClient: PhotoAPIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPhotos() async throws -> [PhotoDTO] {
        do {
            let (data, response) = try await session.data(from: APIEndpoint.photos)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.badStatusCode(httpResponse.statusCode)
            }
            do {
                return try JSONDecoder().decode([PhotoDTO].self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch {
            if error is NetworkError { throw error }
            throw NetworkError.transport(error)
        }
    }
}
