//
//  Date+Extensions.swift
//  ITinder
//
//  Created by Mary Matichina on 27.08.2021.
//

import Foundation

extension Date {
    
    // MARK: - Properties
    
    var milliseconds: Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
    }
    
    // MARK: - Init
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
