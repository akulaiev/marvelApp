//
//  NetworkManager.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 24.12.2020.
//

import Foundation
import CryptoKit
import UIKit
import Alamofire
import AlamofireImage

struct Credentials: Decodable {
    let publicKey: String
    let privateKey: String
}

struct AuthData {
    let credentials: Credentials
    var ts = String(Date().timeIntervalSince1970)
    var hash: String {
        return createHash(with: ts + credentials.privateKey + credentials.publicKey)
    }
    var credentialsDict: [String : String] {
        return ["apikey" : credentials.publicKey, "ts" : ts, "hash" : hash]
    }
    
    init(credentials: Credentials) {
        self.credentials = credentials
    }
    
    //MARK: - Helper
    private func createHash(with stringToHash: String) -> String {
        let digest = Insecure.MD5.hash(data: stringToHash.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

enum Request {
    case searchCharacters(String)
    case searchAuthors(String)
    case showComics(catalog: String, id: String)
    case downloadImage(String)
}

protocol Requestable {
    var pathComponent: String {get}
    var queryItems: [String : String] {get}
}

enum NetworkManagerError: Error {
    case credentialsError
    case fileReadingError(Error)
    case imageUrlError
    case urlError
    case networkRequestFailure(Error)
    case decoderError(Error)
    case networkError
}

extension Request: Requestable {
    var queryItems: [String : String] {
        switch self {
        case let .searchCharacters(item):
            return ["nameStartsWith" : item]
        case let .searchAuthors(item):
            return ["lastNameStartsWith" : item]
        case .showComics:
            return [:]
        case .downloadImage:
            return [:]
        }
    }
    
    var pathComponent: String {
        switch self {
        case .searchAuthors:
            return "/creators"
        case .searchCharacters:
            return "/characters"
        case let .showComics(catalog: catalog, id: id):
            return "/\(catalog)/\(id)/comics"
        case .downloadImage:
            return ""
        }
    }
}

class NetworkManager {
    
    let requestLimit: Int
    var requestOffset = 0
    var baseString: String = "https://gateway.marvel.com"
    private let authData: AuthData!
    private var dataTask: URLSessionDataTask?
    
    init(requestLimit: Int) {
        self.requestLimit = requestLimit
        guard let credsUrl = Bundle.main.url(forResource: "Credentials", withExtension: "json") else {
            fatalError(NetworkManagerError.credentialsError.localizedDescription)
        }
        do {
            let credentialsData = try Data(contentsOf: credsUrl)
            let decoder = JSONDecoder()
            let credentials = try decoder.decode(Credentials.self, from: credentialsData)
            authData = AuthData(credentials: credentials)
        }
        catch {
            fatalError(NetworkManagerError.fileReadingError(error).localizedDescription)
        }
    }
    
    //MARK: - Perform request
    func performRequest<Response>(request: Request, completion: @escaping (Result<Response, Error>) -> Void) where Response : Decodable {
            guard let builtRequest = build(request: request) else {
                completion(.failure(NetworkManagerError.imageUrlError))
                return
            }
            AF.request(builtRequest).response { (response) in
            DispatchQueue.main.async {
                guard let data = response.data else {
                    completion(.failure(NetworkManagerError.networkRequestFailure(response.error!)))
                    return
                }
                switch request {
                    case .downloadImage:
                        completion(.success(data as! Response))
                    default:
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let decodedData = try decoder.decode(Response.self, from: data)
                            completion(.success(decodedData))
                        } catch {
                            completion(.failure(NetworkManagerError.decoderError(response.error ?? NetworkManagerError.networkError)))
                    }
                }
            }
        }
    }
    
    //MARK: - Helper
    private func build(request: Request) -> URLRequest? {
        switch request {
        case let .downloadImage(urlString):
            guard let url = URL(string: urlString) else {
                return nil
            }
            return URLRequest(url: url)
        default:
            guard var components = URLComponents(url: URL(string: baseString)!, resolvingAgainstBaseURL: true) else {
                fatalError(NetworkManagerError.urlError.localizedDescription)
                
            }
            components.path = "/v1/public" + request.pathComponent
            components.queryItems = authData.credentialsDict.map(URLQueryItem.init) + request.queryItems.map(URLQueryItem.init)
            components.queryItems?.append(contentsOf: [URLQueryItem(name: "offset", value: "\(requestOffset)"), URLQueryItem(name: "limit", value: "\(requestLimit)")])
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        }
    }
}
