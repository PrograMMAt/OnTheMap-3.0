//
//  PostStudentLocationRequest.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 17/12/2020.
//

import Foundation

import Foundation
import UIKit

struct PostStudentLocationRequest: Codable {
    let firstName: String
    let lastName: String
    let latitude: Float
    let longitude: Float
    let mapString: String
    let mediaURL: String
    let uniqueKey: String
}
