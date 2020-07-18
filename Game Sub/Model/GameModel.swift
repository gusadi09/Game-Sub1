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
    let name: String
    let released: String
    let bgImage: URL
    let rating: Double
    
    var image: UIImage?
    var state: DownloadState = .new
    
    init(name: String, released: String, bgImage: URL, rating:Double) {
        self.name = name
        self.released = released
        self.bgImage = bgImage
        self.rating = rating
    }
}
