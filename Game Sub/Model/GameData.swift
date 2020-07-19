//
//  GameData.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 15/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import Foundation

struct GameData: Codable {
    let next: String?
    let previous: String?
    let results: [Results]
}

struct Results: Codable {
    let id: Int64
    let name: String
    let released: String
    let bgImage: String?
    let rating: Double
    let ratingsCount: Int
    let genres: [Genres]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case released
        case bgImage = "background_image"
        case rating
        case ratingsCount = "ratings_count"
        case genres
    }
}

struct Genres: Codable {
    let name: String
}
