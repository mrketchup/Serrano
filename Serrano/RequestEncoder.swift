//
//  RequestEncoder.swift
//  Serrano
//
//  Created by Matt Jones on 8/9/16.
//  Copyright © 2016 Matt Jones. All rights reserved.
//

import Foundation

public protocol RequestEncoder {
    associatedtype ParameterType
    var headers: [String: String] { get }
    func request(from url: URL, method: HTTPMethod, parameters: ParameterType?, addedHeaders: [String: String]) throws -> URLRequest
}

public extension RequestEncoder {
    
    var headers: [String: String] { return [:] }
    
    func request(from url: URL, method: HTTPMethod = .GET, addedHeaders: [String: String] = [:]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        addedHeaders.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
    
}


// MARK: -

public struct BasicRequestEncoder: RequestEncoder {
    
    public typealias ParameterType = Void
    
    public init() {}
    
    public func request(from url: URL, method: HTTPMethod, parameters: ParameterType?, addedHeaders: [String: String]) throws -> URLRequest {
        return request(from: url, method: method, addedHeaders: addedHeaders)
    }
    
}


// MARK: -

public struct JSONRequestEncoder: RequestEncoder {
    
    public typealias ParameterType = Any
    
    public var additionalHeaders = ["Content-Type": "application/json"]
    
    public init() {}
    
    public func request(from url: URL, method: HTTPMethod, parameters: ParameterType?, addedHeaders: [String : String]) throws -> URLRequest {
        var request = self.request(from: url, method: method, addedHeaders: addedHeaders)
        request.httpBody = try body(from: parameters)
        return request
    }
    
    private func body(from parameters: ParameterType?) throws -> Data? {
        guard let parameters = parameters else { return nil }
        return try JSONSerialization.data(withJSONObject: parameters)
    }
    
}


// MARK: -

public struct FormRequestEncoder: RequestEncoder {
    
    public typealias ParameterType = [String: String]
    
    public var additionalHeaders = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
    
    public init() {}
    
    public func request(from url: URL, method: HTTPMethod, parameters: ParameterType?, addedHeaders: [String : String]) throws -> URLRequest {
        var request = self.request(from: url, method: method, addedHeaders: addedHeaders)
        request.httpBody = body(from: parameters)
        return request
    }
    
    private func body(from parameters: ParameterType?) -> Data? {
        guard let parameters = parameters, parameters.count > 0 else { return nil }
        
        let set = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-.~"))
        let encode: (String) -> String = { $0.addingPercentEncoding(withAllowedCharacters: set)! }
        let paramString = parameters.map({ "\(encode($0))=\(encode($1))" }).joined(separator: "&")
        return paramString.data(using: .utf8)
    }
    
}
