//
//  ImageExifData.swift
//  Splash
//
//  Created by student on 2021/7/30.
//

import Foundation

struct DetailData: Codable {
    let id: String?
    //let createdAt, updatedAt, promotedAt: Date?
    let width, height: Int?
    let urls: Urls?
    //let user: User?
    let exif: Exif?
    let location: Location?

    
    // MARK: - Exif
    struct Exif: Codable {
        let make, model, exposureTime, aperture: String?
        let focalLength: String?
        let iso: Int?

        enum CodingKeys: String, CodingKey {
            case make, model
            case exposureTime = "exposure_time"
            case aperture
            case focalLength = "focal_length"
            case iso
        }
    }
    
    
    // MARK: - Location
    struct Location: Codable {
        let title, name, city, country: String?
        let position: Position?
        
        // MARK: - Position
        struct Position: Codable {
            let latitude, longitude: Int?
        }
    }

    
    // MARK: - Urls
    struct Urls: Codable {
        let raw, full, regular, small: String?
        let thumb: String?
    }
    
    
    
    
}





