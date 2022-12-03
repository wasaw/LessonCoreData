//
//  JsonHelper.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//

import Foundation

class JsonHelper {
    static let shared = JsonHelper()
    private var jsonDecoder = JSONDecoder()
    
    func decode(data: Data) -> [UnsplashItem]? {
        return try? jsonDecoder.decode([UnsplashItem].self, from: data)
    }
}
