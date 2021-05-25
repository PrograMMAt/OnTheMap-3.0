//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 27/11/2020.
//

import Foundation
import UIKit

class OTMClient {
    
    struct Auth {
        static var sessionId = ""
        static var userId = ""
        static var objectId = ""
    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case postSession
        case deleteSession
        case getUserData
        case getStudentLocations(String)
        case postStudentLocation
        case putStudentLocation
        
        
        var stringValue: String {
            switch self {
            case .postSession: return Endpoints.base + "/session"
            case .deleteSession: return Endpoints.base + "/session"
            case .getUserData: return Endpoints.base + "/users" + "/\(Auth.userId)"
            case .getStudentLocations(let limitNumber): return Endpoints.base + "/StudentLocation" + "?limit=\(limitNumber)" + "&order=-updatedAt"
            case .postStudentLocation: return Endpoints.base + "/StudentLocation"
            case .putStudentLocation: return Endpoints.base + "/StudentLocation" + "/\(Auth.objectId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func postSession(username: String, password: String, completion: @escaping (Bool,Error?) -> Void) {
        
        let body = PostSessionRequest(udacity: UdacityDictValue(username: username, password: password))
        taskForPostRequest(url: Endpoints.postSession.url, body: body, responseType: SessionResponse.self, range: 5) { (jsonObject, error) in
            if let jsonObject = jsonObject {
                Auth.sessionId = jsonObject.session.id
                Auth.userId = jsonObject.account.key
                completion(true,nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    
    class func deleteSession(completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                print(error!)
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            Auth.sessionId = ""
            DispatchQueue.main.async {
                completion()
            }
        }
        task.resume()
    }
    
    
    class func getUserData(completion: @escaping (User?,Error?) -> Void){
        taskForGetRequest(url: Endpoints.getUserData.url, responseType: User.self, rangeFrom: 5) { (jsonObject, error) in
            if let jsonObject = jsonObject {
                completion(jsonObject,nil)
            } else {
                completion(nil,error)
            }
        }
    }
    
    
    class func getStudentLocations(numberOfStudents: String, completion: @escaping([StudentLocation], Error?) -> Void) {
        
        taskForGetRequest(url: Endpoints.getStudentLocations(numberOfStudents).url, responseType: StudentLocationsResults.self, rangeFrom: 0) { (jsonObject, error) in
            if let jsonObject = jsonObject {
                completion(jsonObject.results,nil)
            } else {
                completion([],error)
            }
        }
    }
    
    class func postStudentLocation(mapString: String, mediaURL: String, latitude: Float, longitude: Float, completion: @escaping(PostStudentLocationResponse?,Error?) -> Void) {
        let body = PostStudentLocationRequest(firstName: UserModel.user["firstName"] as! String, lastName: UserModel.user["lastName"] as! String, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL, uniqueKey: Auth.userId)
            
        taskForPostRequest(url: Endpoints.postStudentLocation.url, body: body, responseType: PostStudentLocationResponse.self, range: 0) { (jsonObject, error) in
            if let jsonObject = jsonObject {
                completion(jsonObject,nil)
            } else {
                completion(nil,error)
            }
        }
    }
            
    class func putStudentLocation(mapString: String, mediaURL: String, latitude: Float, longitude: Float, completion: @escaping(Bool,Error?) -> Void) {
        var request = URLRequest(url: Endpoints.putStudentLocation.url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostStudentLocationRequest(firstName: UserModel.user["firstName"] as! String, lastName: UserModel.user["lastName"] as! String, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL, uniqueKey: Auth.userId)
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(error)
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            print(String(data: data, encoding: .utf8))
            print("Location updated")
            DispatchQueue.main.async {
            completion(true,nil)
            }
        }
        task.resume()
    }
    
    
    
    // generic task declarations
    
    class func taskForGetRequest<ResponseType: Decodable> (url: URL, responseType: ResponseType.Type, rangeFrom: Int, completion: @escaping(ResponseType?, Error?)->Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            
            do {
                let range = rangeFrom..<data.count
                let newData = data.subdata(in: range)
                let jsonObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(jsonObject, nil)
                }
            } catch {
                print(error)
            }
            
        }
        task.resume()
    }
    
    class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable> (url: URL, body: RequestType, responseType: ResponseType.Type, range: Int, completion: @escaping(ResponseType?,Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }

            do {
                let range = range..<data.count
                let newData = data.subdata(in: range) /* subset response data! */
                let jsonObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(jsonObject,nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                print(error)
            }
        }
        task.resume()
    }
    
    
    
    
    
}
