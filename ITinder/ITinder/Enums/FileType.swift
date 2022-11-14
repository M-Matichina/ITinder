//
//  FileType.swift
//  ITinder
//
//  Created by Mary Matichina on 07.09.2021.
//

import Foundation
import UIKit

enum FileType: String, CaseIterable {
    case photo
    case photoLibrary
    case file
    
    var title: String {
        switch self {
        case .photo: return "Сделать фото"
        case .photoLibrary: return "Медиатека"
        case .file: return "Файл"
        }
    }
}

enum AttachmentType: String {
    case photoCamera, photoLibrary, file
}
