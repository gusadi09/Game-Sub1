//
//  ViewController.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 15/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var gamesButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var gameTable: UITableView!
    @IBOutlet weak var popularTable: UITableView!
    
    var timer = Timer()
    
    var image: [UIImage?] = []
    
    var gameManager = GameManager()
    
    var gameDat: [GameModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIBeautify()
        
        loadData()
        
        gameTable.delegate = self
        gameTable.dataSource = self
        
        popularTable.delegate = self
        popularTable.dataSource = self
        
        popularTable.register(UINib(nibName: "PopularTableViewCell", bundle: nil), forCellReuseIdentifier: "popCell")
        
        gameTable.register(UINib(nibName: "GamesTableViewCell", bundle: nil), forCellReuseIdentifier: "gamesCell")
    }
    
    func UIBeautify() {
        gamesButton.layer.cornerRadius = gamesButton.frame.height/2
        popularButton.layer.cornerRadius = popularButton.frame.height/2
        
        gamesButton.layer.shadowColor = UIColor.black.cgColor
        gamesButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        gamesButton.layer.shadowOpacity = 0.5
        gamesButton.layer.masksToBounds = false
        
        popularButton.layer.shadowColor = UIColor.black.cgColor
        popularButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        popularButton.layer.shadowOpacity = 0.5
        popularButton.layer.masksToBounds = false
    }
    
    @objc func loadData() {
        let url = URL(string: "https://api.rawg.io/api/games")
        
        let request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                
                let game = try! decoder.decode(GameData.self, from: data)
                
                game.results.forEach { (result) in
                    let newData = GameModel(name: result.name, released: result.released, bgImage: result.bgImage!, rating: result.rating)
                    
                    self.gameDat.append(newData)
                }
                
                DispatchQueue.main.async {
                    self.gameTable.reloadData()
                }
            } else {
                print("ERROR: \(data), HTTP Status: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
    }
    
    @IBAction func tabPressed(_ sender: UIButton) {
        if (sender == popularButton) {
            popularButton.backgroundColor = .black
            popularButton.tintColor = .black
            popularButton.isSelected = true
            gameTable.isHidden = true
            popularTable.isHidden = false
            titleView.text = "Popular"
            
            gamesButton.backgroundColor = .white
            gamesButton.isSelected = false
        } else {
            gamesButton.backgroundColor = .black
            gamesButton.tintColor = .black
            gamesButton.isSelected = true
            popularTable.isHidden = true
            gameTable.isHidden = false
            titleView.text = "Games"
            
            popularButton.backgroundColor = .white
            popularButton.isSelected = false
        }
    }
}

// MARK: -TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == popularTable) {
            return 1
        }
        
        return gameDat.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = gameTable.dequeueReusableCell(withIdentifier: "gamesCell", for: indexPath) as! GamesTableViewCell
        
        if (tableView == popularTable) {
            let cell2 = popularTable.dequeueReusableCell(withIdentifier: "popCell", for: indexPath) as! PopularTableViewCell
            
            return cell2
        }
        
        let data = try! Data(contentsOf: URL(string: gameDat[0].bgImage)!)
        do {
            cell.gameImage.image = UIImage(data: data)
        } catch {
            print("image not found")
        }
        
        cell.gameTitle.text = gameDat[0].name
        cell.gameRating.text = String(gameDat[0].rating)
    
        return cell
    }
    
    
}
