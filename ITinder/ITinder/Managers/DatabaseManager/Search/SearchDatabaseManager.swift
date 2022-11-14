//
//  SearchDatabaseManager.swift
//  ITinder
//
//  Created by KirRealDev on 29.08.2021.
//

import Firebase
import FirebaseAuth
import Foundation

final class SearchDatabaseManager { // Менеджер по работе поиска пользователей
    
    // MARK: - Properties
    
    static let shared = SearchDatabaseManager()
    
    // MARK: - Firebase properties
    
    private let currentUser = Auth.auth().currentUser
    private let usersRef = Database.database().reference().child("users")
    private let actionsRef = Database.database().reference().child("actions")
    
    // MARK: - Configure
    
    /// получаем список пользователей
    func getListOfUsers(currentUserId: String, completion: @escaping (Result<[Profile], Error>) -> Void) {
        getListOfActions(currentUserId: currentUserId) { [weak self] result in
            
            var usersActions = [String: String]()
            
            switch result {
            case .success(let resultDictionary):
                usersActions = resultDictionary
            case .failure(let error):
                print("Ошибка: \(error)")
            }
            
            guard let self = self else {
                return
            }
            
            self.usersRef.observeSingleEvent(of: .value, with: { snapshot in
                
                guard let childSnaps = snapshot.children.allObjects as? [DataSnapshot] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                var usersCardData = [Profile]()
                
                for child in childSnaps where child.key != currentUserId && usersActions[child.key] == nil {
                    let snapDict = child.value as? NSDictionary
                    let id = snapDict?["id"] as? String ?? ""
                    let name = snapDict?["name"] as? String ?? ""
                    let position = snapDict?["position"] as? String ?? ""
                    let skills = snapDict?["skills"] as? String ?? ""
                    let imageUrl = URL(string: snapDict?["imageUrl"] as? String ?? "")
                    
                    usersCardData.append(Profile(id: id, name: name, position: position, skills: skills, imageUrl: imageUrl))
                    
                }
                print("loaded persons cards", usersCardData)
                completion(.success(usersCardData))
            })
        }
    }
    
    /// получаем список активностей пользователей
    private func getListOfActions(currentUserId: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        actionsRef.child(currentUserId).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? [String: String] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("loaded array of actions", value)
            completion(.success(value))
        })
    }
    
    /// Обновить активность текущего пользователя
    func updateAction(subjectId: String, objectId: String, action: String) {
        actionsRef.child(subjectId).updateChildValues([objectId: action])
    }
    
    /// Проверить активность конкретного пользователя
    func checkPersonAction(currentPersonId: String, otherPersonId: String, completion: @escaping (Result<String, Error>) -> Void) {
        actionsRef.child(otherPersonId).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? NSDictionary else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let value = value[currentPersonId] as? String else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    /// Получение пользователей у которых произошел коннект
    func fetchConnectUser(completion: @escaping (Result<[Profile], Error>) -> Void) {
        var connectUsers: [Profile] = []
        
        ProfileDatabaseManager.shared.getAllUsers { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let users):
                self.fetchConnectUserIds { result in
                    switch result {
                    case .success(let userIds):
                        for userId in userIds {
                            if !connectUsers.contains(where: { $0.id == userId }), let user = users.first(where: { $0.id == userId }) {
                                connectUsers.append(user)
                                completion(.success(connectUsers))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        print("Ошибка: \(error)")
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Получение id пользователей которые лайкнули меня
    private func fetchConnectUserIds(_ completion: @escaping (Result<[String], Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        fetchLikedUsers { [weak self] result in
            guard let self = self else {
                return
            }
            
            var userLikedIds: [String] = []
            
            switch result {
            case .success(let userIds):
                // Проверяем, кто лайкнул меня (из тех, кого лайкнула я)
                for id in userIds {
                    self.getListOfActions(currentUserId: id) { result in
                        switch result {
                        case .success(let resultDictionary):
                            if resultDictionary[currentUserId] == "like" {
                                userLikedIds.append(id)
                            }
                            completion(.success(userLikedIds))
                        case .failure(let error):
                            completion(.failure(error))
                            print("Ошибка: \(error)")
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
                print("Ошибка: \(error)")
            }
        }
    }
    
    /// Получаем список пользователей, которых мы лайкнули
    private func fetchLikedUsers(_ completion: @escaping (Result<[String], Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        getListOfActions(currentUserId: currentUserId) { result in
            var userLikedIds: [String] = []
            
            switch result {
            case .success(let resultDictionary):
                for userId in resultDictionary.keys where resultDictionary[userId] == "like" {
                    userLikedIds.append(userId)
                }
                completion(.success(userLikedIds))
            case .failure(let error):
                completion(.failure(error))
                print("Ошибка: \(error)")
            }
        }
    }
    
    func checkMatch(otherProfileId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentProfileId = currentUser?.uid else { return }
        
        checkPersonAction(currentPersonId: currentProfileId, otherPersonId: otherProfileId) { result in
            
            switch result {
            case .success(let personAction):
                if personAction == "like" {
                    self.checkPersonAction(currentPersonId: otherProfileId, otherPersonId: currentProfileId) { result in
                        
                        switch result {
                        case .success(let personAction):
                            if personAction == "like" {
                                completion(.success(true))
                            } else {
                                completion(.success(false))
                            }
                        case .failure(let error):
                            print("Ошибка: \(error)")
                            completion(.failure(DatabaseError.failedToFetch))
                        }
                    }
                } else {
                    completion(.success(false))
                }
            case .failure(let error):
                print("Ошибка: \(error)")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
}
