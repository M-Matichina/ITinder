//
//  SizeSetting.swift
//  ITinder
//
//  Created by KirRealDev on 13.08.2021.
//

import UIKit

enum DeviceDiagonals: Double {
    case iPhone5Family = 4.0
    case iPhone6Family = 4.7
    case iPhone6PlusFamily = 5.5
}

enum BottomHomeViewConstraintValue: CGFloat {
    case iPhone5Family = 260.0
    case iPhone6Family = 280.0
    case iPhone6PlusFamily = 290.0
    case standard = 330.0
}

enum ConstraintBetweenHomeViewAttributesValue: CGFloat {
    case iPhone5Family = 31.0
    case iPhone6Family = 41.0
    case standard = 61.0
}

enum UpperLoginViewConstraintValue: CGFloat {
    case iPhone5Family = 5.0
    case iPhone6Family = 40.0
    case iPhone6PlusFamily = 60.0
    case standard = 70.0
}

enum UpperProfileViewConstraintValue: CGFloat {
    case iPhone5Family = 15.0
    case iPhone6Family = 50.0
    case iPhone6PlusFamily = 60.0
    case standard = 70.0
}

enum BottomProfileViewConstraintValue: CGFloat {
    case iPhone5Family = 15.0
    case iPhone6Family = 40.0
    case iPhone6PlusFamily = 50.0
    case standard = 60.0
}

enum BottomListChatViewConstraintValue: CGFloat {
    case iPhone5Family = 60.0
    case iPhone6Family = 135.0
    case iPhone6PlusFamily = 170.0
    case standard = 220.0
}

enum UpperMatchViewConstraintValue: CGFloat {
    case iPhone5Family = 5.0
    case iPhone6Family = 25.0
    case iPhone6PlusFamily = 35.0
    case standard = 70.0
}

enum GroupsMatchViewConstraintValue: CGFloat {
    case iPhone5Family = 20.0
    case iPhone6Family = 47.0
    case standard = 53.0
}

enum ButtonsSizeSearchView: CGFloat {
    case iPhone5Family = 320.0
    case iPhone6Family = 350.0
    case standard = 414.0
}
