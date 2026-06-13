//
//  PhotoItem.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

struct PhotoItem: Hashable {
    let albumId: Int64
    let id: Int64
    var title: String
    let url: String
    let thumbnailUrl: String
}