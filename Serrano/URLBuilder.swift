//
//  URLBuilder.swift
//  Serrano
//
//  Created by Matt Jones on 8/11/16.
//  Copyright © 2016 Matt Jones. All rights reserved.
//

import Foundation

public protocol URLBuilder {
    var baseURL: URL { get }
    func url(path: String, parameters: [URLQueryItem]?) -> URL?
}

public extension URLBuilder {
    
    func url(path: String, parameters: [String: String?]) -> URL? {
        var items: [URLQueryItem]? = nil
        if parameters.count > 0 {
            items = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        
        return url(path: path, parameters: items)
    }
    
    func url(path: String, parameters: [URLQueryItem]?) -> URL? {
        return _url(path: path, parameters: parameters)
    }
    
    func url(path: String) -> URL? {
        return url(path: path, parameters: nil)
    }
    
    func _url(path: String, parameters: [URLQueryItem]? = nil) -> URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = parameters
        return components?.url
    }
    
}
