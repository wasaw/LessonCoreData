//
//  Model.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//

import UIKit

struct OutputData {
    let userName: String
    var profileImg: UIImage
    var workImage: UIImage
    let previewPhoto: PreviewPhoto
}

//  MARK: - Codable

struct UnsplashItem: Codable {
    let id: String
    let title: String
    let user: UserCredentials
    let preview_photos: [PreviewPhoto]
}

struct UserCredentials: Codable {
    let name: String
    let profile_image: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
}

struct PreviewPhoto: Codable {
    let id: String
    let urls: ImageUrl
}

struct ImageUrl: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let small_s3: String
}
