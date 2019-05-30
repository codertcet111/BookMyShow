//
//  TvShowResultsClass.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import Foundation

struct TvShowResultsClass: Codable{
    let page: Int
    let results: [IndivisualShows]
    
    struct IndivisualShows: Codable {
        let id: Int
        let backdrop_path: String
        let original_language: String
        let poster_path: String
        let vote_average: Float
        let vote_count: Float
        let popularity: Float
        let name: String
        let original_name: String
    }
}
