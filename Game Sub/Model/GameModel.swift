//
//  GameModel.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 18/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import Foundation
import UIKit

class GameModel {
    let id: Int64
    let name: String
    let released: String
    let bgImage: URL
    let rating: Double
    
    var desc: String
    var image: UIImage?
    var state: DownloadState = .new
    
    init(id: Int64, name: String, released: String, bgImage: URL, rating:Double, desc: String) {
        self.id = id
        self.name = name
        self.released = released
        self.bgImage = bgImage
        self.rating = rating
        self.desc = desc
    }
}
