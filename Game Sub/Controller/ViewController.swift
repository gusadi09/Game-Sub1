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
    var popularGame: [GameModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIBeautify()
        
        loadData(url: gameManager.url!)
        loadDataPopular(url: gameManager.popUrl!)
        
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

//MARK: -loadData
    func loadData(url: URL) {
        let request = URLRequest(url: url)
        
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
    
    func loadDataPopular(url: URL) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                
                let game = try! decoder.decode(GameData.self, from: data)
                
                game.results.forEach { (result) in
                    let newData = GameModel(name: result.name, released: result.released, bgImage: result.bgImage!, rating: result.rating)
                    
                    self.popularGame.append(newData)
                }
                
                DispatchQueue.main.async {
                    self.popularTable.reloadData()
                }
            } else {
                print("ERROR: \(data), HTTP Status: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    
// MARK: -buttonFunctionality
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
            return popularGame.count
        }
        
        return gameDat.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = gameTable.dequeueReusableCell(withIdentifier: "gamesCell", for: indexPath) as! GamesTableViewCell
        
        if (tableView == popularTable) {
            let cell2 = popularTable.dequeueReusableCell(withIdentifier: "popCell", for: indexPath) as! PopularTableViewCell
            
            if indexPath.row >= 0 && indexPath.count < popularGame.count {
                print(popularGame[indexPath.row])
                let data = try! Data(contentsOf: URL(string: popularGame[indexPath.row].bgImage)!)
                do {
                    cell2.gameImage.image = UIImage(data: data)
                }
                
                cell2.gameTitle.text = popularGame[indexPath.row].name
                cell2.gameRating.text = String(popularGame[indexPath.row].rating)
            }
            
            return cell2
        }
        
        if indexPath.row >= 0 && indexPath.count < gameDat.count {
            print(gameDat[indexPath.row])
            let data = try! Data(contentsOf: URL(string: gameDat[indexPath.row].bgImage)!)
            do {
                cell.gameImage.image = UIImage(data: data)
            }
            
            cell.gameTitle.text = gameDat[indexPath.row].name
            cell.gameRating.text = String(gameDat[indexPath.row].rating)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if gameTable.isHidden == false {
                if let indexPath = self.gameTable.indexPathForSelectedRow {
                    let controller = segue.destination as! DetailViewController
                    DispatchQueue.main.async {
                        controller.gameTitle.text = self.gameDat[indexPath.row].name
                        let data = try! Data(contentsOf: URL(string: self.gameDat[indexPath.row].bgImage)!)
                        do {
                            controller.gameImage.image = UIImage(data: data)
                        }
                    }
                }
            } else {
                if let indexPath = self.popularTable.indexPathForSelectedRow {
                    let controller = segue.destination as! DetailViewController
                    DispatchQueue.main.async {
                        controller.gameTitle.text = self.popularGame[indexPath.row].name
                        let data = try! Data(contentsOf: URL(string: self.popularGame[indexPath.row].bgImage)!)
                        do {
                            controller.gameImage.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
}
