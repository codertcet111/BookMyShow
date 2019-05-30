//
//  detailViewClass.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import Foundation

struct  detailsViewClass: Codable {
    let id: Int
    let original_title: String?
    let title: String?
    let name: String?
    let overview: String?
    let popularity: Float?
    let production_companies: [productionCompanies]?
    struct productionCompanies: Codable{
        let logo_path: String?
        let name: String?
    }
    let poster_path: String?
    let vote_average: Float?
    let created_by: [createdBy]?
    struct createdBy: Codable{
        let name: String?
        let profile_path: String?
    }
}
