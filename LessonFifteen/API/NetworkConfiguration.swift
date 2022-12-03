//
//  NetworkConfiguration.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//
import Foundation

class NetworkConfiguration {
//    MARK: - Properties
    
    private let apiUrl = "https://api.unsplash.com/"
    private let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    
//    MARK: - Helpers
    
    func getApiUrl() -> String {
        return apiUrl
    }
    
    func getApiKey() -> String {
        return apiKey
    }
}
