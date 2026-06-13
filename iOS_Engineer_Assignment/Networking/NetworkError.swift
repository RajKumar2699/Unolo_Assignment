//
//  NetworkError.swift
//  iOS_Engineer_Assignment
//
//  Created by Askme Technologies on 13/06/26.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case badStatusCode(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .badStatusCode(let code):
            return "Server returned status code \(code)."
        case .decoding:
            return "Failed to decode photos."
        case .transport(let error):
            return error.localizedDescription
        }
    }
}
