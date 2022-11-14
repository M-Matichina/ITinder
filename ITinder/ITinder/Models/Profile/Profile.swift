//
//  Profile.swift
//  ITinder
//
//  Created by Mary Matichina on 22.08.2021.
//

import Foundation
import SafariServices
import UIKit

struct Profile {
    var id: String = ""
    var name: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var position: String = ""
    var education: String = ""
    var city: String = ""
    var description: String = ""
    var skills: String = ""
    var levelOfRussianLanguage: Int = 0
    var levelOfEnglishLanguage: Int = 0
    var interests: String = ""
    var workExperience: String = ""
    var imageUrl: URL?
    var localImage: UIImage?
    var file: URL?
    var localFile: URL?
}

extension Profile {
    var isFullData: Bool {
        return
            name != "" &&
            phoneNumber != "" &&
            email != "" &&
            position != "" &&
            education != "" &&
            city != "" &&
            description != "" &&
            skills != "" &&
            interests != "" &&
            workExperience != "" &&
            (imageUrl != nil || localImage != nil)
    }

    func open() {
        guard let file = file else {
            return
        }
        UIApplication.shared.open(file)
    }
}
