//
//  SearchUserData.swift
//  Splash
//
//  Created by student on 2021/7/31.
//

import Foundation


struct UserData: Codable {
    let total, totalPages: Int?
    let results: [Result]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
    
    struct Result: Codable {
        let id: String?
        //let updatedAt: Date?
        let username, name, firstName: String?
        let lastName, twitterUsername: String?
        let portfolioURL: String?
        let bio, location: String?
        let links: Links?
        let profileImage: ProfileImage?
        let instagramUsername: String?
        let totalCollections, totalLikes, totalPhotos: Int?
        //let acceptedTos, forHire: Bool?
        //let social: Social?
        let followedByUser: Bool?
        //let photos: [Photo]?

        enum CodingKeys: String, CodingKey {
            case id
            //case updatedAt = "updated_at"
            case username, name
            case firstName = "first_name"
            case lastName = "last_name"
            case twitterUsername = "twitter_username"
            case portfolioURL = "portfolio_url"
            case bio, location, links
            case profileImage = "profile_image"
            case instagramUsername = "instagram_username"
            case totalCollections = "total_collections"
            case totalLikes = "total_likes"
            case totalPhotos = "total_photos"
            //case acceptedTos = "accepted_tos"
            //case forHire = "for_hire"
            //case social
            case followedByUser = "followed_by_user"
            //case photos
        }
        
         
        struct Links: Codable {
            let linksSelf, html, photos, likes: String?
            let portfolio, following, followers: String?

            enum CodingKeys: String, CodingKey {
                case linksSelf = "self"
                case html, photos, likes, portfolio, following, followers
            }
        }
        
        
        // MARK: - ProfileImage
        struct ProfileImage: Codable {
            let small, medium, large: String?
        }
        
        
    }
    
    
    
    
    
}
