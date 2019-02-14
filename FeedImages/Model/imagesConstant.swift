//
//  Constant.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 07/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import Foundation
import UIKit

extension ImagesVC {
    
    struct Constants {
        
        struct Unsplash {
            static let APIScheme = "https"
            static let APIHost = "api.unsplash.com"
            static let APIPath = "/search/photos"
            static let GetRequest = "GET"
            static let APIKey = "6d7482cd6d2d509c1e0bbe367bc8e23ed7f17ddcbe8ae0895adce17e87149929"
           
        }
        
        struct UnsplashParameterKeys {
            static let Client = "client_id"
            static let Query = "query"
            static let Per_page = "per_page"
            static let page = "20"
        }

        // MARK: Unsplash Response Values
        struct UnsplashResponseValues {
            static let OKStatus = "ok"
        }
    }
    
    struct UnsplashResponseKeys: Decodable {
        let results: [Results]
    }
    
    struct Results: Decodable {
        let urls: Urls
        let user: User
    }
    
    struct Urls: Decodable {
        let small: String
    }
    
    struct User: Decodable {
        let name: String
    }
}

