//
//  ViewController.swift
//  Serrano Example
//
//  Created by Matt Jones on 8/9/16.
//
//

import UIKit
import Serrano

class FOAASSessionManager: SessionManager {}
enum FOAASError: Error {}

struct FOAASURLBuilder: URLBuilder {
    
    let baseURL = URL(string: "http://foaas.com")!
    let shout: Bool
    let locale: Locale
    
    init(shout: Bool = false, locale: Locale = Locale.current) {
        self.shout = shout
        self.locale = locale
    }
    
    func url(path: String, parameters: [URLQueryItem]?) -> URL? {
        var parameters = parameters ?? []
        
        if shout {
            parameters.append(URLQueryItem(name: "shoutcloud", value: nil))
        }
        
        if let code = locale.languageCode {
            parameters.append(URLQueryItem(name: "i18n", value: code))
        }
        
        return _url(path: path, parameters: parameters)
    }
    
}

class ViewController: UIViewController {
    
    let manager: SessionManager = FOAASSessionManager()
    let builder: URLBuilder = FOAASURLBuilder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = builder.url(path: "/thumbs/Harambe/mrketchup")!
        let request = BasicRequestEncoder().request(from: url)
        _ = manager.execute(request: request, responseParser: JSONResponseParser<[String: Any], FOAASError>()) { result in
            print(result)
        }
    }
    
}

