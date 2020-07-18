//
//  GameManager.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 15/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import Foundation

struct GameManager {
    let url = URL(string: "https://api.rawg.io/api/games")
    let popUrl = URL(string: "https://api.rawg.io/api/games?dates=2020-01-01,2020-12-31&ordering=-added")
}
