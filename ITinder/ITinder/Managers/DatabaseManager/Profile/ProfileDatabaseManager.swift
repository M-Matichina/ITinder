//
//  ProfileDatabaseManager.swift
//  ITinder
//
//  Created by Mary Matichina on 26.08.2021.
//

import Firebase
import FirebaseAuth
import Foundation

final class ProfileDatabaseManager { // Менеджер по работе с данными Firebase профиля пользователя
    
    static let shared = ProfileDatabaseManager()

    // MARK: - Firebase properties

    private let databaseUser = Database.database().reference().child("users")

    // MARK: - Configure

    /// Получаем данные профиля
    func getProfile(for userId: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        databaseUser.child("\(userId)").getData(completion: { _, snapshot in
            guard let value = snapshot.value as? NSDictionary else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let id = value["id"] as? String ?? ""
            let name = value["name"] as? String ?? ""
            let email = value["email"] as? String ?? ""
            let phoneNumber = value["phoneNumber"] as? String ?? ""
            let position = value["position"] as? String ?? ""
            let education = value["education"] as? String ?? ""
            let city = value["city"] as? String ?? ""
            let description = value["description"] as? String ?? ""
            let skills = value["skills"] as? String ?? ""
            let levelOfEnglishLanguage = value["levelOfEnglishLanguage"] as? Int ?? 0
            let levelOfRussianLanguage = value["levelOfRussianLanguage"] as? Int ?? 0
            let interests = value["interests"] as? String ?? ""
            let workExperience = value["workExperience"] as? String ?? ""
            let imageUrl = URL(string: value["imageUrl"] as? String ?? "")
            let file = URL(string: value["file"] as? String ?? "")

            let profile = Profile(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                email: email,
                position: position,
                education: education,
                city: city,
                description: description,
                skills: skills,
                levelOfRussianLanguage: levelOfRussianLanguage,
                levelOfEnglishLanguage: levelOfEnglishLanguage,
                interests: interests,
                workExperience: workExperience,
                imageUrl: imageUrl,
                file: file
            )
            completion(.success(profile))
        })
    }

    /// Обновляем данные профиля
    func updateUser(_ profile: Profile) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        databaseUser.child(userId).updateChildValues(
            [
                "phoneNumber": profile.phoneNumber,
                "position": profile.position,
                "education": profile.education,
                "city": profile.city,
                "description": profile.description,
                "skills": profile.skills,
                "levelOfRussianLanguage": profile.levelOfRussianLanguage,
                "levelOfEnglishLanguage": profile.levelOfEnglishLanguage,
                "interests": profile.interests,
                "workExperience": profile.workExperience,
                "email": profile.email,
                "name": profile.name,
                "id": userId,
                "imageUrl": profile.imageUrl?.absoluteString ?? "",
                "file": profile.file?.absoluteString ?? ""
            ])
    }

    /// Получение всех пользователей
    func getAllUsers(_ completion: @escaping (Result<[Profile], Error>) -> Void) {
        databaseUser.observeSingleEvent(of: .value, with: { snapshot in
            guard let allUsersDictionary = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            var users: [Profile] = []

            for element in allUsersDictionary {
                guard let value = element.value as? [String: Any] else {
                    return
                }

                let id = value["id"] as? String ?? ""
                let name = value["name"] as? String ?? ""
                let email = value["email"] as? String ?? ""
                let phoneNumber = value["phoneNumber"] as? String ?? ""
                let position = value["position"] as? String ?? ""
                let education = value["education"] as? String ?? ""
                let city = value["city"] as? String ?? ""
                let description = value["description"] as? String ?? ""
                let skills = value["skills"] as? String ?? ""
                let levelOfEnglishLanguage = value["levelOfEnglishLanguage"] as? Int ?? 0
                let levelOfRussianLanguage = value["levelOfRussianLanguage"] as? Int ?? 0
                let interests = value["interests"] as? String ?? ""
                let workExperience = value["workExperience"] as? String ?? ""
                let imageUrl = URL(string: value["imageUrl"] as? String ?? "")

                let profile = Profile(
                    id: id,
                    name: name,
                    phoneNumber: phoneNumber,
                    email: email,
                    position: position,
                    education: education,
                    city: city,
                    description: description,
                    skills: skills,
                    levelOfRussianLanguage: levelOfRussianLanguage,
                    levelOfEnglishLanguage: levelOfEnglishLanguage,
                    interests: interests,
                    workExperience: workExperience,
                    imageUrl: imageUrl
                )

                if id != Auth.auth().currentUser?.uid {
                    users.append(profile)
                }
            }
            completion(.success(users))
        })
    }
}
