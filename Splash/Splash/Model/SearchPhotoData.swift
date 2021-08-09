//
//  SearchData.swift
//  Splash
//
//  Created by student on 2021/7/24.
//

import Foundation

struct SearchData : Codable {

    let results : [Result]
    let total : Int?
    let totalPages : Int?
}


struct Result : Codable {

    let altDescription : String?
    let blurHash : String?
    let categories : [String]?
    let color : String?
    let createdAt : String?
    let currentUserCollections : [String]?
    let descriptionField : String?
    let height : Int?
    let id : String?
    let likedByUser : Bool?
    let likes : Int?
    let links : Link?
    let promotedAt : String?
    //let sponsorship : String?
    //let tags : [Tag]?
    let updatedAt : String?
    let urls : Url?
    let user : User?
    let width : Int?

}

struct User : Codable {

    let acceptedTos : Bool?
    let bio : String?
    let firstName : String?
    let forHire : Bool?
    let id : String?
    let instagramUsername : String?
    let lastName : String?
    let links : Link?
    let location : String?
    let name : String?
    let portfolioUrl : String?
    let profile_image : ProfileImage?
    let social : Social?
    let totalCollections : Int?
    let totalLikes : Int?
    let totalPhotos : Int?
    let twitterUsername : String?
    let updatedAt : String?
    let username : String?
}

struct Social : Codable {

    let instagramUsername : String?
    let paypalEmail : String?
    let portfolioUrl : String?
    let twitterUsername : String?
}

struct ProfileImage : Codable {

    let large : String?
    let medium : String?
    let small : String?
}

struct Url : Codable {

    let full : String?
    let raw : String?
    let regular : String
    let small : String?
    let thumb : String?
}

struct Ancestry : Codable {
    let category : Category?
    let subcategory : Category?
    let type : Category?
}

struct Category : Codable {
    let prettySlug : String?
    let slug : String?
}


struct Link : Codable {

    let download : String?
    let download_location : String?
    let html : String?
    let self_ : String? //
    let followers : String?
    let following : String?
    let likes : String?
    let photos : String?
    let portfolio : String?

}


