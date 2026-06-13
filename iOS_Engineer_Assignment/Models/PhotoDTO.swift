//
//  PhotoDTO.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

struct PhotoDTO: Decodable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}