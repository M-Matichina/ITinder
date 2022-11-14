//
//  StorageDatabaseManager.swift
//  ITinder
//
//  Created by Mary Matichina on 26.08.2021.
//

import Firebase
import FirebaseStorage
import Foundation

final class StorageDatabaseManager {
    
    static let shared = StorageDatabaseManager()

    // MARK: - Firebase properties

    private let databaseStorageImage = Storage.storage().reference().child("avatars")
    private let databaseStorageFile = Storage.storage().reference().child("files")
    private let metadata = StorageMetadata()

    // MARK: - Configure

    /// Загрузка фото
    func uploadImage(currentUserId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("Ошибка при получении фото")
            return
        }

        metadata.contentType = "image/jpeg"

        databaseStorageImage.child(currentUserId).putData(imageData, metadata: metadata) { metadata, _ in
            guard let _ = metadata else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            self.databaseStorageImage.child(currentUserId).downloadURL { url, _ in
                guard let url = url else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(url))
            }
        }
    }

    /// Загрузка файла
    func uploadFile(currentUserId: String, file: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        databaseStorageFile.child(currentUserId).putFile(from: file, metadata: nil, completion: { [weak self] _, error in
            guard error == nil else {
                print("Не удалось загрузить файл в firebase")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            self?.databaseStorageFile.child(currentUserId).downloadURL(completion: { url, _ in
                guard let url = url else {
                    print("Не удалось получить URL для скачивания")
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }

                let urlString = url
                print("URL загрузки возвращает: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
}
