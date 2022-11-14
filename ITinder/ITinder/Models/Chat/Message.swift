//
//  Message.swift
//  ITinder
//
//  Created by Mary Matichina on 23.08.2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
