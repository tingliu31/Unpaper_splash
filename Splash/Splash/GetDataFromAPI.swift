//
//  GetDataFromAPI.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import Foundation

struct Source {
    enum ParamConstants {
        static let perPage: Int = 30
        static let orderBy: OrderBy = .latest
        static let contentFilter: ContentFilter = .high
        
        enum OrderBy: String {
            case relevant, latest
        }
        enum ContentFilter: String {
            case low, high
        }
    }
    
    
    private func compareModelCountToPerPage(_ oldModels: Int,
                                            _ perPage: Int) -> Int {
        var page: Int = oldModels/perPage
        switch oldModels {
        case 0:
            page = 1
        case 1..<perPage:
            return 0
        default:
            page += 1
        }
        return page
    }
    
}
