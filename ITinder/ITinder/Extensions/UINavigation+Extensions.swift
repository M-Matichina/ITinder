//
//  UINavigation+Extensions.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

extension UIViewController {
    
    // MARK: - Configure
    
    class func instantiateFromStoryboard(storyboardName: String) -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboardName: storyboardName)
    }
    
    class func instantiateFromStoryboardHelper<T>(type: T.Type, storyboardName: String) -> T {
        let storyboardId = String(describing: T.self).components(separatedBy: ".").last
        
        let storyboad = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboad.instantiateViewController(withIdentifier: storyboardId!) as! T
        
        return controller
    }
}
