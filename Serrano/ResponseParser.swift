//
//  ResponseDeserializer.swift
//  Serrano
//
//  Created by Matt Jones on 8/9/16.
//  Copyright © 2016 Matt Jones. All rights reserved.
//

import Foundation

public protocol Initializable { init() }
extension Dictionary: Initializable {}
extension Array: Initializable {}


// MARK: -

public protocol ResponseParser {
    associatedtype SuccessType
    associatedtype ErrorType
    var acceptType: String? { get }
    func result(from data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<SuccessType, ErrorType>
}

public extension ResponseParser {
    
    var acceptType: String? { return nil }
    
    func basicError(from response: URLResponse?, _ error: Error?) -> ResultError<ErrorType>? {
        if let error = error {
            if let error = error as? URLError {
                return .Network(error)
            } else {
                return .Unexpected(error)
            }
        }
        
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        
        if response.statusCode >= 500 {
            return .Server(.Default(code: response.statusCode, url: response.url))
        } else {
            return nil
        }
    }
    
}


// MARK: -

public struct JSONResponseParser<S: Initializable, E>: ResponseParser {
    
    public typealias SuccessType = S
    public typealias ErrorType = E
    
    public init() {}
    
    public var acceptType: String? { return "application/json" }
    
    public func result(from data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<SuccessType, ErrorType> {
        if let error = basicError(from: response, error) {
            return .Error(error)
        }
        
        guard let data = data, data.count > 0 else {
            return .Success(SuccessType())
        }
        
        return parse(data, response)
    }
    
    private func parse(_ data: Data, _ response: URLResponse?) -> Result<SuccessType, ErrorType> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let json = json as? SuccessType {
                return .Success(json)
            } else {
                return .Error(.Server(.Parsing(.Format("Cannot caste to \(SuccessType.self)", object: json))))
            }
        } catch let error as NSError {
            return .Error(.Server(.Parsing(.Default(error))))
        }
    }
    
}


// MARK: -

public struct FormResponseParser<E>: ResponseParser {
    
    public typealias SuccessType = [String: String]
    public typealias ErrorType = E
    
    public init() {}
    
    public var acceptType: String? { return "application/x-www-form-urlencoded" }
    
    public func result(from data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<SuccessType, ErrorType> {
        if let error = basicError(from: response, error) {
            return .Error(error)
        }
        
        guard let data = data, data.count > 0 else {
            return .Success(SuccessType())
        }
        
        return parse(data, response)
    }
    
    private func parse(_ data: Data, _ response: URLResponse?) -> Result<SuccessType, ErrorType> {
        guard let string = String(data: data, encoding: .utf8) else {
            return .Error(.Server(.Unexpected("Response body encoding is not UTF8")))
        }
        
        var parameters: [String: String] = [:]
        for pair in string.components(separatedBy: "&") {
            let keyValue = pair.components(separatedBy: "=")
            guard let key = keyValue.first, let value = keyValue.last else {
                return .Error(.Server(.Parsing(.Format("Cannot parse form response", object: string))))
            }
            
            parameters[key] = value
        }
        
        return .Success(parameters)
    }
    
}
