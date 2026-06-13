//
//  CoreDataError.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

enum CoreDataError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Unable to save data locally."
        case .fetchFailed:
            return "Unable to fetch saved photos."
        case .deleteFailed:
            return "Unable to delete the photo."
        }
    }
}