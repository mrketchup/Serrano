//
//  SessionManager.swift
//  Serrano
//
//  Created by Matt Jones on 8/9/16.
//  Copyright © 2016 Matt Jones. All rights reserved.
//

import Foundation

public protocol SessionManager {
    var session: URLSession { get }
    func execute<S, E, P: ResponseParser>(request: URLRequest, responseParser: P, completion: ((Result<S, E>) -> Void)?) -> URLSessionTask where P.SuccessType == S, P.ErrorType == E
}

public extension SessionManager {
    
    var session: URLSession { return URLSession.shared }
    
    func execute<S, E, P: ResponseParser>(request: URLRequest, responseParser: P, completion: ((Result<S, E>) -> Void)?) -> URLSessionTask where P.SuccessType == S, P.ErrorType == E {
        var request = request
        
        if let accept = responseParser.acceptType {
            request.addValue(accept, forHTTPHeaderField: "Accept")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            completion?(responseParser.result(from: data, response, error))
        }
        
        task.resume()
        return task
    }
    
}


// MARK: -

public enum Result<S, E> {
    case Success(S)
    case Error(ResultError<E>)
}

public enum ResultError<E>: Error {
    case Client(E)
    case Server(ServerError)
    case Network(URLError)
    case Unexpected(Error)
}

public enum ServerError: Error {
    case Default(code: Int, url: URL?)
    case Serialization(DataError)
    case Parsing(DataError)
    case Unexpected(String?)
}

public enum DataError: Error {
    case Default(Error)
    case Format(String, object: Any)
}

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}
