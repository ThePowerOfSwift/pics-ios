//
//  HttpClient.swift
//  pics-ios
//
//  Created by Michael Skogberg on 26/11/2017.
//  Copyright © 2017 Michael Skogberg. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HttpClient {
    private let log = LoggerFactory.shared.network(HttpClient.self)
    static let JSON = "application/json", CONTENT_TYPE = "Content-Type", ACCEPT = "Accept", DELETE = "DELETE", GET = "GET", POST = "POST", AUTHORIZATION = "Authorization", BASIC = "Basic"
    
    static func basicAuthValue(_ username: String, password: String) -> String {
        let encodable = "\(username):\(password)"
        let encoded = encodeBase64(encodable)
        return "\(HttpClient.BASIC) \(encoded)"
    }
    
    static func authHeader(_ word: String, unencoded: String) -> String {
        let encoded = HttpClient.encodeBase64(unencoded)
        return "\(word) \(encoded)"
    }
    
    static func encodeBase64(_ unencoded: String) -> String {
        return unencoded.data(using: String.Encoding.utf8)!.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
    
    let session: URLSession
    
    init() {
        self.session = URLSession.shared
    }
    
    func get(_ url: URL, headers: [String: String] = [:]) -> Observable<HttpResponse> {
        let req = buildRequest(url: url, httpMethod: HttpClient.GET, headers: headers, body: nil)
        return executeHttp(req)
    }
    
    func postJSON(_ url: URL, headers: [String: String] = [:], payload: [String: AnyObject]) -> Observable<HttpResponse> {
        return postData(url, headers: headers, payload: try? JSONSerialization.data(withJSONObject: payload, options: []))
    }
    
    func postData(_ url: URL, headers: [String: String] = [:], payload: Data?) -> Observable<HttpResponse> {
        let req = buildRequest(url: url, httpMethod: HttpClient.POST, headers: headers, body: payload)
        return executeHttp(req)
    }
    
    func postGeneric(_ url: URL, headers: [String: String] = [:], payload: Data?, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        let req = buildRequest(url: url, httpMethod: HttpClient.POST, headers: headers, body: payload)
        executeRequest(req, completionHandler: completionHandler)
    }
    
    func delete(_ url: URL, headers: [String: String] = [:]) -> Observable<HttpResponse> {
        let req = buildRequest(url: url, httpMethod: HttpClient.DELETE, headers: headers, body: nil)
        return executeHttp(req)
    }
    
    func executeHttp(_ req: URLRequest, retryCount: Int = 0) -> Observable<HttpResponse> {
        return session.rx.response(request: req).flatMap { (result) -> Observable<HttpResponse> in
            let (response, data) = result
            return Observable.just(HttpResponse(http: response, data: data))
        }
    }
    
    func buildRequest(url: URL, httpMethod: String, headers: [String: String], body: Data?) -> URLRequest {
        var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 3600)
        let useCsrfHeader = httpMethod != HttpClient.GET
        if useCsrfHeader {
            req.addCsrf()
        }
        req.httpMethod = httpMethod
        for (key, value) in headers {
            req.addValue(value, forHTTPHeaderField: key)
        }
        if let body = body {
            req.httpBody = body
        }
        return req
    }
    
    func executeRequest(_ req: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        let task = session.dataTask(with: req, completionHandler: completionHandler)
        task.resume()
    }
}

extension URLRequest {
    mutating func addCsrf() {
        self.addValue("nocheck", forHTTPHeaderField: "Csrf-Token")
    }
}
