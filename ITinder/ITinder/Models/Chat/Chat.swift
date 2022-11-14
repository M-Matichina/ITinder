//
//  Chat.swift
//  ITinder
//
//  Created by Mary Matichina on 23.08.2021.
//

import Foundation
import MessageKit

struct Chat {
    let id: String
    let name: String
    let otherUserId: String
    var imageUrl: URL?
    let latestMessage: LatestMessage
}
