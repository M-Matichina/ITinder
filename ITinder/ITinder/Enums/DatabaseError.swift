//
//  DatabaseError.swift
//  ITinder
//
//  Created by Mary Matichina on 24.08.2021.
//

import Foundation

enum DatabaseError: Error {
    
    case failedToFetch
    
    // MARK: - Properties
    
    var localizedDescription: String {
        switch self {
        case .failedToFetch:
            return "Ошибка"
        }
    }
}
