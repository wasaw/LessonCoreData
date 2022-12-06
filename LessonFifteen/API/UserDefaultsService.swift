//
//  UserDefaultsService.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 06.12.2022.
//

import UIKit

class UserDefaultsService {
    static let shared = UserDefaultsService()
    
//    MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
//    MARK: - Helpers
    
    func firstLaunce() -> Bool {
        guard let _ = userDefaults.value(forKey: "total") else { return true }
        return false
    }
    
    func saveInformation(profiles: [Profile]) {
        userDefaults.set(profiles.count, forKey: "total")
        for i in 0..<profiles.count {
            let name = profiles[i].userName
            userDefaults.set(name, forKey: "\(i)")

            guard let profileImageData = profiles[i].profileImage.jpegData(compressionQuality: 0.8) else { return }
            guard let encodedProfileImage = try? PropertyListEncoder().encode(profileImageData) else { return }
            userDefaults.set(encodedProfileImage, forKey: "\(name)ProfileImage")

            guard let workImageData = profiles[i].workImage.jpegData(compressionQuality: 0.8) else { return }
            guard let encodedWorkImage = try? PropertyListEncoder().encode(workImageData) else { return }
            userDefaults.set(encodedWorkImage, forKey: "\(name)WorkImage")
        }
    }
    
    func loadInformation() -> [Profile]? {
        guard let total = userDefaults.value(forKey: "total") as? Int else { return nil }
        var profiles: [Profile] = []

        for i in 0..<total {
            guard let name = userDefaults.value(forKey: "\(i)") as? String else { return nil }
            
            guard let profileImageData = userDefaults.data(forKey: "\(name)ProfileImage") else { return nil }
            guard let decodedProfileImage = try? PropertyListDecoder().decode(Data.self, from: profileImageData) else { return nil }
            guard let profileImage = UIImage(data: decodedProfileImage) else { return nil }

            guard let workImageData = userDefaults.data(forKey: "\(name)WorkImage") else { return nil }
            guard let decodedWorkImage = try? PropertyListDecoder().decode(Data.self, from: workImageData) else { return nil }
            guard let workImage = UIImage(data: decodedWorkImage) else { return nil }

            let profile = Profile(userName: name, profileImage: profileImage, workImage: workImage)
            profiles.append(profile)
        }
        return profiles
    }
    
    func search(searchName: String) -> Profile? {
        guard let total = userDefaults.value(forKey: "total") as? Int else { return nil }
        for i in 0..<total {
            guard let name =  userDefaults.value(forKey: "\(i)") as? String else { return nil }
            
            if searchName == name {
                guard let profileImageData = userDefaults.data(forKey: "\(name)ProfileImage") else { return nil }
                let decodedProfileImage = try! PropertyListDecoder().decode(Data.self, from: profileImageData)
                guard let profileImage = UIImage(data: decodedProfileImage) else { return nil }

                guard let workImageData = userDefaults.data(forKey: "\(name)WorkImage") else { return nil }
                let decodedWorkImage = try! PropertyListDecoder().decode(Data.self, from: workImageData)
                guard let workImage = UIImage(data: decodedWorkImage) else { return nil }
                
                let profile = Profile(userName: name, profileImage: profileImage, workImage: workImage)
                return profile
            }
        }
        return nil
    }
}
