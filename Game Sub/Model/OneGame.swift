//
//  OneGame.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 19/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import Foundation

struct OneGame: Codable {
    let desc: String
    
    enum CodingKeys: String, CodingKey{
        case desc = "description_raw"
    }
}
