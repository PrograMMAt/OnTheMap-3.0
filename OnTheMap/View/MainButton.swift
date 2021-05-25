//
//  MainButton.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 07/12/2020.
//

import Foundation
import UIKit

class MainButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.init(red: 21/250, green: 163/255, blue: 221/250, alpha: 1)
        layer.cornerRadius = 3.0
        tintColor = UIColor.white
    }
    
}
