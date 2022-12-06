//
//  DatabaseService.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 30.11.2022.
//

import UIKit
import CoreData

class DatabaseService {
    static let shared = DatabaseService()
    
    //    MARK: - Properties

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//    MARK: - Helpers
    
    func firstLaunch() -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profiles")
        do {
            let result = try context.fetch(fetchRequest)
            if result.isEmpty {
                return true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return false
    }
    
    func saveInformation(profiles: [Profile]) {
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Profiles", in: context) else { return }
        for item in profiles {
            let newRecord = NSManagedObject(entity: entity, insertInto: context)
            newRecord.setValue(item.userName, forKey: "name")
            let imgData = item.profileImage.jpegData(compressionQuality: 1.0)
            newRecord.setValue(imgData, forKey: "profileImage")
            let workImgData = item.workImage.jpegData(compressionQuality: 1.0)
            newRecord.setValue(workImgData, forKey: "workImage")
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func loadInformation() -> [Profile]?{
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profiles")
        
        do {
            let result = try context.fetch(fetchRequest)
            var profiles: [Profile] = []
            for data in result {
                let profileImageData = data.value(forKey: "profileImage") as? Data
                guard let profileImageData = profileImageData else { return nil }
                let profileImage = UIImage(data: profileImageData)
                guard let profileImage = profileImage else { return nil }
                
                let workImageData = data.value(forKey: "workImage") as? Data
                guard let workImageData = workImageData else { return nil }
                let workImage = UIImage(data: workImageData)
                guard let workImage = workImage else { return nil }
                
                let name = data.value(forKey: "name") as? String ?? ""
                let imgURl = ImageUrl(raw: "", full: "", regular: "", small: "", thumb: "", small_s3: "")
                let profile = Profile(userName: name, profileImage: profileImage, workImage: workImage)
                profiles.append(profile)
            }
            return profiles
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func searchInDB(_ searchItem: String) -> [Profile]? {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profiles")
        fetchRequest.predicate = NSPredicate(format: "ANY name CONTAINS %@", searchItem)
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.isEmpty {
                return nil
            } else {
                var profiles: [Profile] = []
                for data in result {
                    if let data = data as? NSManagedObject {
                        let profileImageData = data.value(forKey: "profileImage") as? Data
                        guard let profileImageData = profileImageData else { return nil }
                        let profileImage = UIImage(data: profileImageData)
                        guard let profileImage = profileImage else { return nil }
                        
                        let workImageData = data.value(forKey: "workImage") as? Data
                        guard let workImageData = workImageData else { return nil }
                        let workImage = UIImage(data: workImageData)
                        guard let workImage = workImage else { return nil }
                        
                        let name = data.value(forKey: "name") as? String ?? ""
                        let imgURl = ImageUrl(raw: "", full: "", regular: "", small: "", thumb: "", small_s3: "")
                        let profile = Profile(userName: name, profileImage: profileImage, workImage: workImage)
                        profiles.append(profile)
                    }
                }
                return profiles
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
