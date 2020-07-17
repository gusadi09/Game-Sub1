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
    
    func fetchGame() {
        performRequest(with: url!)
    }

    func performRequest(with url: URL) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            
            if response.statusCode == 200 {
                self.decodeJSON(data: data)
            } else {
                print("ERROR: \(data), HTTP Status: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    
    func decodeJSON(data: Data) {
        let decoder = JSONDecoder()
        
        let game = try! decoder.decode(GameData.self, from: data)
        
        game.results.forEach { (result) in
            print(result.name)
            print(result.released)
            print(result.bgImage!)
            print(result.rating)
        }
    }
}
