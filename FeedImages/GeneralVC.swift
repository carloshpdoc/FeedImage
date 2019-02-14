//
//  GeneralVC.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 07/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Alerts
    func showAlert(_ title: String?, message: String, handler: @escaping() -> Void = {}) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (action) -> Void in
            handler()
        })
        
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
