//
//  PhotoListData.swift
//  Splash
//
//  Created by student on 2021/7/23.
//


import Foundation

struct PhotoData: Codable {
    let id: String?
    let created_at: String? //po出時間
    let updated_at: String? //更新時間
    let width: Int?
    let height: Int?
    let color: String?
    let blur_hash: String?
    let description: String?
    let alt_description: String?
    let likes: Int
    let liked_by_user: Bool?
    let urls: Urls? //-----------
    let links: Links?
    let categories: Categories?
    let user: User?

    
    struct Urls: Codable {  //照片網址
        let raw: String?  //-----------
        let full: URL?
        let regular: URL?
        let small: URL?
    }
    
    struct Links: Codable {
        let self_: URL? //沒辦法顯示
        let html: URL? //照片在網站裡的頁面
        let download: URL? //可下載網址
        let download_location: URL? //沒辦法顯示
    }
    
    struct Categories: Codable {
    }
    
    
    //使用者資訊
    struct User: Codable {
        let id: String?
        let updated_at: String? //最新發文時間
        let username: String? //使用帳號
        let name: String? //-------------
        let first_name: String?
        let last_name: String?
        let twitter_username: String?
        let portfolio_url: URL? //個人網站 EX: Instagram
        let bio: String?
        let location: String?
        let instagram_username: String?  //-------------
        let total_collections: Int
        let total_likes: Int
        let total_photos: Int
        let links: Links?
        let profile_image: Profile_image? //-------------
        let social: Social? //-------------
        
        struct Links: Codable {
            let self_: URL? //不能顯示
            let html: URL? //個人Unsplash網站----------
            let photos: URL?  //不能顯示
            let likes: URL?  //不能顯示
        }
        
        struct Profile_image: Codable { //個人大頭照
            let small: URL?
            let medium: URL? //大小比較剛好-------------
            let large: URL?
        }
        
        struct Social: Codable {
            let instagram_username: String?  //-------------
            let portfolio_url: URL?  //-------------
            let twitter_username: String?
        }
    }
    
    // List Photos API
    //https://api.unsplash.com/photos?client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4&page=1&per_page=30&order_by=latest
}
