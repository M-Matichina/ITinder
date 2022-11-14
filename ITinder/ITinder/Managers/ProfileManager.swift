//
//  ProfileManager.swift
//  ITinder
//
//  Created by Mary Matichina on 30.08.2021.
//

import Firebase
import Foundation

final class ProfileManager { // Менеджер по работе с данными профиля пользователя
    
    static let shared = ProfileManager()

    // MARK: - Keys

    private let chatTappedKey = "chatTappedUserIds"

    // MARK: - Properties

    var profile: Profile?

    var chatTappedUserIds: [String] {
        get {
            return (UserDefaults.standard.array(forKey: chatTappedKey) as? [String]) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: chatTappedKey)
        }
    }

    // MARK: - Logout

    func clear() {
        UserDefaults.standard.removeObject(forKey: chatTappedKey)
    }

    // MARK: - Fetch data

    func fetchProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        ProfileDatabaseManager.shared.getProfile(for: userId) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profile):
                self.profile = profile
            case .failure(let error):
                print("Ошибка: \(error)")
            }
            completion(result)
        }
    }
}
