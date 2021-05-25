//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 26/11/2020.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBAction func logOutBarButtonTapped(_ sender: Any) {
        OTMClient.deleteSession {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
