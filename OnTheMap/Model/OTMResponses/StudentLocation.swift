//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 01/12/2020.
//

import Foundation
import UIKit

struct StudentLocation: Codable {
    let firstName: String
    let lastName: String
    let latitude: Float
    let longitude: Float
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
}

