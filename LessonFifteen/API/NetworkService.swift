//
//  NetworkService.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//

import Foundation

enum Metod: String {
    case get, put, post
    
    var value: String {
        return self.rawValue.uppercased()
    }
}

enum RequestType: String {
    case collections
}

class NetworkService {
    static let shared = NetworkService()
    
//    MARK: - Properties
    private let config = NetworkConfiguration()
    private let configuration = URLSessionConfiguration.default
    private lazy var urlSession: URLSession? = {
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }()
    
//    MARK: - Helpers
    
    func request(requestType: RequestType, metod: Metod, completion: @escaping([UnsplashItem]?) -> Void) {
        let apiPath = config.getApiUrl() + requestType.rawValue + "/?" + "client_id=" + config.getApiKey()
        guard let url = URL(string: apiPath) else { return }
        let urlRequest = URLRequest(url: url)
        
        let dataTast = urlSession?.dataTask(with: urlRequest, completionHandler: { data, urlResponse, error in
            if let error = error {
                print(error.localizedDescription)
            }

            if let data = data {
                DispatchQueue.main.async {
                    let answer = JsonHelper.shared.decode(data: data)
                    completion(answer)
                }
            }
        })
        dataTast?.resume()
    }
    
    func downloadImg(urlString: String, completion: @escaping(Data) -> Void) {
        guard let url = URL(string: urlString) else { return }
        urlSession?.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                completion(data)
            }
        }).resume()
    }
}
