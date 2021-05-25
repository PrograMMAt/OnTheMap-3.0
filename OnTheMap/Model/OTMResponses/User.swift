//
//  User.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 28/11/2020.
//

import Foundation
import UIKit

struct User: Codable, Equatable, Hashable {
    let firstName: String
    let lastName: String
    
    
    var dictionary: [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    private enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
    }
}
