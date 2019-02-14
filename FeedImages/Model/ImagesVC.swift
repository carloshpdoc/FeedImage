//
//  ImagesVC.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 07/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import Foundation
import CoreData

class ImagesVC {
    
    var arrayName:[String] = []
    var arrayImage:[String] = []
    
    // MARK: Initializers
    init() {}
    
    func getUnsplash (_ category: String, completionHandler: @escaping (_ success: Bool, _ unsplash: UnsplashResponseKeys?, _ error: String?)-> Void) -> Void {
        
        let parameters: [String: String] = [
            Constants.UnsplashParameterKeys.Client: Constants.Unsplash.APIKey, Constants.UnsplashParameterKeys.Query: category,
            Constants.UnsplashParameterKeys.Per_page: Constants.UnsplashParameterKeys.page,
            ]
        
        let url = createURLRequest(parameters: parameters)
        
        // Create session and request
        URLSession.shared.dataTask(with: url) { (data, response
            , error) in
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                print("Error Returned: \(error.debugDescription)")
                completionHandler(false, nil, error.debugDescription)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No Data Returned")
                completionHandler(false, nil, "No Data Returned")
                return
            }
            
            do {
                let parsedResult = try JSONDecoder().decode(UnsplashResponseKeys.self, from: data)
                completionHandler(true, parsedResult, nil)
                
            } catch {
                print("unable to parse json \(String(data: data, encoding: .utf8)!)")
                completionHandler(false, nil, "unable to parse json")
                return
            }
            
            }.resume()
    }
    
    func createURLRequest(parameters: [String:String]) -> URLRequest {
        var components = URLComponents()
        components.scheme = Constants.Unsplash.APIScheme
        components.host = Constants.Unsplash.APIHost
        components.path = Constants.Unsplash.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = Constants.Unsplash.GetRequest
        return request
    }
    
    static let sharedInstance = ImagesVC()
}
