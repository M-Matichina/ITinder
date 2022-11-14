//
//  ChatViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 21.08.2021.
//

import Firebase
import InputBarAccessoryView
import IQKeyboardManagerSwift
import MessageKit
import UIKit

final class ChatViewController: MessagesViewController {
    
    // MARK: - Properties

    var chatId: String?

    private var isNewChat: Bool = true
    private var chat: Chat?
    private var user: Profile?
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return Sender(photoUrl: currentUser.photoURL?.absoluteString ?? "", senderId: currentUser.uid, displayName: currentUser.displayName ?? "")
    }

    // MARK: - Init

    deinit {
        guard let userId = chat?.otherUserId ?? user?.id else {
            return
        }
        ChatDatabaseManager.shared.removeChatsObserver(for: userId)
    }

    init(chat: Chat) {
        self.chat = chat
        isNewChat = false
        super.init(nibName: nil, bundle: nil)
    }

    init(user: Profile) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMessageView()
        removeMessageAvatars()
        fetchChatWithUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatViewController.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let chat = chat else {
            return
        }
        listenForMessages(id: chat.id, shouldScrollToBottom: true)
    }

    // MARK: - Data

    private func fetchChatWithUser() {
        guard let user = user,
              let currentUserId = Auth.auth().currentUser?.uid
        else {
            return
        }
        ChatDatabaseManager.shared.getAllChats(for: currentUserId, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let chats):
                if let chat = chats.first(where: { $0.otherUserId == user.id }) {
                    self.isNewChat = false
                    self.chat = chat
                    self.listenForMessages(id: chat.id, shouldScrollToBottom: true)
                } else {
                    self.isNewChat = true
                }
            case .failure:
                break
            }
        })
    }

    // MARK: - Observers

    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        ChatDatabaseManager.shared.getAllMessages(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("Успешно получили сообщения: \(messages)")
                guard !messages.isEmpty else {
                    print("Сообщения пустые")
                    return
                }
                self?.messages = messages

                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()

                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("Ошибка при получении сообщений: \(error)")
            }
        })
    }

    // MARK: - Configure

    private func configureSetNavBar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.view.backgroundColor = .gray
    }

    private func configureNavBar() {
        configureSetNavBar()
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Назад"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem

        let button = UIButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setImage(UIImage(named: "arrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -3, right: -10)
        if let chat = chat {
            button.setTitle(chat.name, for: .normal)
        } else if let user = user {
            button.setTitle(user.name, for: .normal)
        }
        button.addTarget(self, action: #selector(clickOnTitle), for: .touchUpInside)
        navigationItem.titleView = button
    }

    private func setUpMessageView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        showMessageTimestampOnSwipeLeft = true
        maintainPositionOnKeyboardFrameChanged = true
    }

    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)

        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        )
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)

        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        )
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }

    // MARK: - Actions

    @objc func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc func clickOnTitle() {
        let navigator = NavigatorManager(navigationController: navigationController)
        if let chat = chat {
            navigator.navigate(to: .detailUserProfile(chat.otherUserId))
        } else if let user = user {
            navigator.navigate(to: .detailUserProfile(user.id))
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .systemBlue
        }
        return .secondarySystemBackground
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 8
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self отправитель = nil, электронная почта должна быть кеширована")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId()
        else {
            return
        }

        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))

        // Отправляем сообщение
        if isNewChat {
            guard let user = user else {
                return
            }
            ChatDatabaseManager.shared.createNewChat(with: user.id, name: user.name, firstMessage: message, completion: { [weak self] success in
                if success {
                    print("Сообщение отправлено")
                    self?.isNewChat = false
                    let newChatId = "conversation_\(message.messageId)"
                    self?.chatId = newChatId
                    self?.listenForMessages(id: newChatId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Ошибка")
                }
            })
        } else {
            guard let chat = chat else {
                return
            }

            // Добавляем сообщения в существующий чат
            ChatDatabaseManager.shared.sendMessage(to: chat.id, otherUserId: chat.otherUserId, name: chat.name, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("Сообщение отправлено")
                } else {
                    print("Ошибка")
                }
            })
        }
    }

    private func createMessageId() -> String? {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let otherUserId = isNewChat ? user?.id : chat?.otherUserId
        else {
            return nil
        }

        let dateString = Date().milliseconds
        return "\(otherUserId)_\(currentUserId)_\(dateString)"
    }
}

extension MessageKind {
    var messageKindSttring: String {
        switch self {
        default:
            break
        }
        return ""
    }
}
