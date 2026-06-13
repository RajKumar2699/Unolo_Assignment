//
//  PhotoMapper.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//

import Foundation

extension PhotoItem {
    init(dto: PhotoDTO) {
        self.albumId = Int64(dto.albumId)
        self.id = Int64(dto.id)
        self.title = dto.title
        self.url = dto.url
        self.thumbnailUrl = dto.thumbnailUrl
    }

    init(entity: CDPhoto) {
        self.albumId = entity.albumId
        self.id = entity.id
        self.title = entity.title ?? ""
        self.url = entity.url ?? ""
        self.thumbnailUrl = entity.thumbnailUrl ?? ""
    }
}
