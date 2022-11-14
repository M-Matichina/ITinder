//
//  ChatDatabaseManager.swift
//  ITinder
//
//  Created by Mary Matichina on 23.08.2021.
//

import Firebase
import FirebaseDatabase
import Foundation
import MessageKit

final class ChatDatabaseManager {
    
    static let shared = ChatDatabaseManager()

    // MARK: - Firebase properties

    private let databaseUser = Database.database().reference().child("users")
    private let databaseChat = Database.database().reference().child("chats")
}

extension ChatDatabaseManager {
    /// Создание нового чата с текущем пользователем и отправка первого сообщения
    func createNewChat(with otherUserId: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let currentName = ProfileManager.shared.profile?.name ?? "User"

        let ref = databaseUser.child("\(currentUserId)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("Пользователь не найден")
                return
            }

            let dateString = firstMessage.sentDate.milliseconds

            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            default:
                break
            }

            let chatId = "conversation_\(firstMessage.messageId)"
            let newChatData: [String: Any] = [
                "id": chatId,
                "other_user_id": otherUserId,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newChatData: [String: Any] = [
                "id": chatId,
                "other_user_id": currentUserId,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]

            // Обновить запись беседы получателя
            self.databaseUser.child("\(otherUserId)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var chats = snapshot.value as? [[String: Any]] {
                    chats.append(recipient_newChatData)
                    self?.databaseUser.child("\(otherUserId)/conversations").setValue(chats)
                } else {
                    self?.databaseUser.child("\(otherUserId)/conversations").setValue([recipient_newChatData])
                }
            })

            if var chats = userNode["conversations"] as? [[String: Any]] {
                chats.append(newChatData)
                userNode["conversations"] = chats
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingChat(chatId: chatId, name: name, firstMessage: firstMessage, completion: completion)
                })

            } else {
                userNode["conversations"] = [
                    newChatData
                ]

                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingChat(chatId: chatId, name: name, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }

    private func finishCreatingChat(chatId: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let dateString = firstMessage.sentDate.milliseconds

        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        default:
            break
        }

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindSttring,
            "content": message,
            "date": dateString,
            "sender_id": currentUserId,
            "is_read": false,
            "name": name
        ]

        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        databaseChat.child(chatId).setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    /// Очищение всех observers
    func removeChatsObserver(for userId: String) {
        databaseUser.child("\(userId)/conversations").removeAllObservers()
    }

    /// Получение всех чатов для пользователя с переданным id
    func getAllChats(for userId: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
        databaseUser.child("\(userId)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let chats: [Chat] = value.compactMap { dictionary in
                guard let chatId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let dateMs = latestMessage["date"] as? Int64,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool
                else {
                    return nil
                }

                let date = Date(milliseconds: dateMs)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"

                let latestMessageObject = LatestMessage(
                    date: dateFormatter.string(from: date),
                    text: message,
                    isRead: isRead
                )
                return Chat(
                    id: chatId,
                    name: name,
                    otherUserId: otherUserId,
                    imageUrl: URL(string: dictionary["imageUrl"] as? String ?? ""),
                    latestMessage: latestMessageObject
                )
            }

            completion(.success(chats))
        })
    }

    /// Получение всех сообщений
    func getAllMessages(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        databaseChat.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderId = dictionary["sender_id"] as? String,
                      let dateMs = dictionary["date"] as? Int64
                else {
                    return nil
                }

                let date = Date(milliseconds: dateMs)

                let sender = Sender(
                    photoUrl: "",
                    senderId: senderId,
                    displayName: name
                )

                return Message(
                    sender: sender,
                    messageId: messageID,
                    sentDate: date,
                    kind: .text(content)
                )
            }

            completion(.success(messages))
        })
    }

    /// Отправление сообщений в текущем чате
    func sendMessage(to chat: String, otherUserId: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        databaseChat.child("\(chat)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else {
                return
            }

            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }

            let dateString = newMessage.sentDate.milliseconds

            var message = ""

            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            default:
                break
            }

            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindSttring,
                "content": message,
                "date": dateString,
                "sender_id": currentUserId,
                "is_read": false,
                "name": name
            ]

            currentMessages.append(newMessageEntry)

            self.databaseChat.child("\(chat)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }

                self.databaseUser.child("\(currentUserId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryChats = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]

                    if var currentUserChats = snapshot.value as? [[String: Any]] {
                        var targetChat: [String: Any]?
                        var position = 0

                        for chatDictionary in currentUserChats {
                            if let currentId = chatDictionary["id"] as? String, currentId == chat {
                                targetChat = chatDictionary
                                break
                            }
                            position += 1
                        }

                        if var targetChat = targetChat {
                            targetChat["latest_message"] = updatedValue
                            currentUserChats[position] = targetChat
                            databaseEntryChats = currentUserChats
                        } else {
                            let newChatData: [String: Any] = [
                                "id": chat,
                                "other_user_id": otherUserId,
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserChats.append(newChatData)
                            databaseEntryChats = currentUserChats
                        }
                    } else {
                        let newChatData: [String: Any] = [
                            "id": chat,
                            "other_user_id": otherUserId,
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryChats = [
                            newChatData
                        ]
                    }

                    self.databaseUser.child("\(currentUserId)/conversations").setValue(databaseEntryChats, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        // Обновить последнее сообщение для пользователя-получателя
                        self.databaseUser.child("\(otherUserId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryChats = [[String: Any]]()
                            let currentName = ProfileManager.shared.profile?.name ?? "User"

                            if var otherUserChats = snapshot.value as? [[String: Any]] {
                                var targetChat: [String: Any]?
                                var position = 0

                                for chatDictionary in otherUserChats {
                                    if let currentId = chatDictionary["id"] as? String, currentId == chat {
                                        targetChat = chatDictionary
                                        break
                                    }
                                    position += 1
                                }

                                if var targetChat = targetChat {
                                    targetChat["latest_message"] = updatedValue
                                    otherUserChats[position] = targetChat
                                    databaseEntryChats = otherUserChats
                                } else {
                                    // Не удалось найти в текущей коллекции
                                    let newChatData: [String: Any] = [
                                        "id": chat,
                                        "other_user_id": currentUserId,
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserChats.append(newChatData)
                                    databaseEntryChats = otherUserChats
                                }
                            } else {
                                // Текущая коллекция не существует
                                let newChatData: [String: Any] = [
                                    "id": chat,
                                    "other_user_id": currentUserId,
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryChats = [
                                    newChatData
                                ]
                            }

                            self.databaseUser.child("\(otherUserId)/conversations").setValue(databaseEntryChats, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
}
