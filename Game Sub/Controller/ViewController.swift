//
//  ViewController.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 15/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

enum DownloadState {
    case new, downloaded, failed
}

class ImageDownloader: Operation {
    private let _game: GameModel
    
    init(game: GameModel) {
        _game = game
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let imageData = try? Data(contentsOf: _game.bgImage) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            _game.image = UIImage(data: imageData)
            _game.state = .downloaded
        } else {
            _game.image = nil
            _game.state = .failed
        }
    }
}

class PendingOperations {
    lazy var downloadInProgress: [IndexPath : Operation] = [:]
    
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.gusadi.imagedownload"
        queue.maxConcurrentOperationCount = 2
        return queue
    }()
}

//MARK: - ViewController
class ViewController: UIViewController {
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var gamesButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var gameTable: UITableView!
    @IBOutlet weak var popularTable: UITableView!
    @IBOutlet weak var gameSearchBar: UISearchBar!
    @IBOutlet weak var popSearchBar: UISearchBar!
    
    var filteredGame: [GameModel] = []
    
    var timer = Timer()
    var limit = 0
    var totalEntries = 419735
    
    var gameManager = GameManager()
    var isSearching = false
    var isSearchingPop = false

    var filteredPopular: [GameModel] = []
    var gameDat: [GameModel] = []
    var popularGame: [GameModel] = []
    var urlPage = ""
    var urlPagePop = ""
    var loadingData = false
    
    private let _pendingOperations = PendingOperations()
    
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
        
        gameSearchBar.delegate = self
        popSearchBar.delegate = self
        
        self.hideKeyboardWhenTappedAround()
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
    
//MARK: - Download Image
    fileprivate func startOperations(game: GameModel, indexPath: IndexPath) {
        if game.state == .new {
            startDownload(game: game, indexPath: indexPath)
        }
    }
    
    fileprivate func startDownload(game: GameModel, indexPath: IndexPath) {
        guard _pendingOperations.downloadInProgress[indexPath] == nil else { return }
        let manager = GameManager()
        let url = URL(string: "\(manager.urlString)/\(game.id)")
        
        let request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                
                let games = try! decoder.decode(OneGame.self, from: data)
                
                game.desc = games.desc
                
            } else {
                print("ERROR: \(data), HTTP Status: \(response.statusCode)")
            }
        }
        
        task.resume()
        
        let downloader = ImageDownloader(game: game)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            
            DispatchQueue.main.async {
                self._pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                if ((self.gameTable.cellForRow(at: indexPath)) != nil) {
                    self.gameTable.reloadRows(at: [indexPath], with: .automatic)
                }
                
                if ((self.popularTable.cellForRow(at: indexPath)) != nil) {
                    self.popularTable.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        _pendingOperations.downloadInProgress[indexPath] = downloader
        _pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    fileprivate func toggleSuspendOperations(isSuspended: Bool) {
        _pendingOperations.downloadQueue.isSuspended = isSuspended
    }
//MARK: -loadData
    func loadData(url: URL) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                
                let game = try! decoder.decode(GameData.self, from: data)
                
                self.urlPage = game.next!
                
                game.results.forEach { (result) in
                    let newData = GameModel(id: result.id, name: result.name, released: result.released, bgImage: URL(string: result.bgImage!)!, rating: result.rating, desc: "", genre: result.genres[0].name)
                    
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
                
                self.urlPagePop = game.next!
                
                game.results.forEach { (result) in
                    let newData = GameModel(id: result.id, name: result.name, released: result.released, bgImage: URL(string: result.bgImage!)!, rating: result.rating, desc: "", genre: result.genres[0].name)
                    
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
    @IBAction func tabPressed(_ sender: UIButton) {
        if (sender == popularButton) {
            popularButton.backgroundColor = .black
            popularButton.tintColor = .black
            popularButton.isSelected = true
            gameTable.isHidden = true
            popularTable.isHidden = false
            titleView.text = "Popular"
            popSearchBar.isHidden = false
            gameSearchBar.isHidden = true
            
            gamesButton.backgroundColor = .white
            gamesButton.isSelected = false
        } else {
            gamesButton.backgroundColor = .black
            gamesButton.tintColor = .black
            gamesButton.isSelected = true
            popularTable.isHidden = true
            gameTable.isHidden = false
            titleView.text = "Games"
            popSearchBar.isHidden = true
            gameSearchBar.isHidden = false
            
            popularButton.backgroundColor = .white
            popularButton.isSelected = false
        }
    }
}

//MARK: - UITextFieldDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == gameSearchBar {
            filteredGame = gameDat.filter({$0.name.prefix(searchText.count) == searchText})
            isSearching = true
            gameTable.reloadData()
        } else {
            filteredPopular = popularGame.filter({$0.name.prefix(searchText.count) == searchText})
            isSearchingPop = true
            popularTable.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == gameSearchBar {
            gameSearchBar.endEditing(true)
        } else {
            popSearchBar.endEditing(true)
        }
    }
}
// MARK: -TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == popularTable) {
            if isSearchingPop {
                return filteredPopular.count
            } else {
                return popularGame.count
            }
        }
        
        if isSearching {
            return filteredGame.count
        } else {
            return gameDat.count
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        toggleSuspendOperations(isSuspended: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        toggleSuspendOperations(isSuspended: false)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = gameTable.dequeueReusableCell(withIdentifier: "gamesCell", for: indexPath) as! GamesTableViewCell
        
        
        if (tableView == popularTable) {
            let popular = popularGame[indexPath.row]
            let cell2 = popularTable.dequeueReusableCell(withIdentifier: "popCell", for: indexPath) as! PopularTableViewCell
            let pop = popularGame.count
            
            if indexPath.row >= 0 && indexPath.count < popularGame.count {
                if  pop > 1{
                    let lastElement = pop - 1
                    if indexPath.row == lastElement {
                        //call get api for next page
                        loadDataPopular(url: URL(string: urlPagePop)!)
                    }
                }
                if isSearchingPop {
                    cell2.gameImage.image = filteredPopular[indexPath.row].image
                    cell2.gameTitle.text = filteredPopular[indexPath.row].name
                    cell2.gameRating.text = String(filteredPopular[indexPath.row].rating)
                    if filteredPopular[indexPath.row].state == .new {
                            startOperations(game: filteredPopular[indexPath.row], indexPath: indexPath)
                    }
                } else {
                    cell2.gameImage.image = popular.image
                    cell2.gameTitle.text = popular.name
                    cell2.gameRating.text = String(popular.rating)
                    if popular.state == .new {
                            startOperations(game: popular, indexPath: indexPath)
                    }
                }
            }
            
            return cell2
        }
        
        let count = gameDat.count
        
        if indexPath.row >= 0 && indexPath.count < gameDat.count {
            let game = gameDat[indexPath.row]
            if  count > 1{
                let lastElement = count - 1
                if indexPath.row == lastElement {
                    //call get api for next page
                    loadData(url: URL(string: urlPage)!)
                }
            }
            if isSearching {
                cell.gameImage.image = filteredGame[indexPath.row].image
                cell.gameTitle.text = filteredGame[indexPath.row].name
                cell.gameRating.text = String(filteredGame[indexPath.row].rating)
                
                if filteredGame[indexPath.row].state == .new {
                        startOperations(game: filteredGame[indexPath.row], indexPath: indexPath)
                }
            } else {
                cell.gameImage.image = game.image
                cell.gameTitle.text = game.name
                cell.gameRating.text = String(game.rating)
                
                if gameDat[indexPath.row].state == .new {
                        startOperations(game: gameDat[indexPath.row], indexPath: indexPath)
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailScroll", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailScroll" {
            if gameTable.isHidden == false {
                if let indexPath = self.gameTable.indexPathForSelectedRow {
                    let controller = segue.destination as! DetailScrollViewController
                    if isSearching {
                        DispatchQueue.main.async {
                            controller.gameTitle.text = self.filteredGame[indexPath.row].name
                            controller.gameImage.image = self.filteredGame[indexPath.row].image
                            controller.descText.text = self.filteredGame[indexPath.row].desc
                            controller.ratingGame.text = String(format: "%.2f", self.filteredGame[indexPath.row].rating)
                            controller.releaseGame.text = self.filteredGame[indexPath.row].released
                            controller.genreGame.text = self.filteredGame[indexPath.row].genre
                            self.startOperations(game: self.filteredGame[indexPath.row], indexPath: indexPath)
                        }
                    } else {
                        DispatchQueue.main.async {
                            controller.gameTitle.text = self.gameDat[indexPath.row].name
                            controller.gameImage.image = self.gameDat[indexPath.row].image
                            controller.descText.text = self.gameDat[indexPath.row].desc
                            controller.ratingGame.text = String(format: "%.2f", self.gameDat[indexPath.row].rating)
                            controller.releaseGame.text = self.gameDat[indexPath.row].released
                            controller.genreGame.text = self.gameDat[indexPath.row].genre
                            self.startOperations(game: self.gameDat[indexPath.row], indexPath: indexPath)
                        }
                    }
                    
                }
            } else {
                if let indexPath = self.popularTable.indexPathForSelectedRow {
                    let controller = segue.destination as! DetailScrollViewController
                    if isSearching {
                        DispatchQueue.main.async {
                            controller.gameTitle.text = self.filteredPopular[indexPath.row].name
                            controller.gameImage.image = self.filteredPopular[indexPath.row].image
                            controller.descText.text = self.filteredPopular[indexPath.row].desc
                            controller.ratingGame.text = String(format: "%.2f", self.filteredPopular[indexPath.row].rating)
                            controller.releaseGame.text = self.filteredPopular[indexPath.row].released
                            controller.genreGame.text = self.filteredPopular[indexPath.row].genre
                            self.startOperations(game: self.filteredPopular[indexPath.row], indexPath: indexPath)
                        }
                    } else {
                        DispatchQueue.main.async {
                            controller.gameTitle.text = self.popularGame[indexPath.row].name
                            controller.gameImage.image = self.popularGame[indexPath.row].image
                            controller.descText.text = self.popularGame[indexPath.row].desc
                            controller.ratingGame.text = String(format: "%.2f", self.popularGame[indexPath.row].rating)
                            controller.releaseGame.text = self.popularGame[indexPath.row].released
                            controller.genreGame.text = self.popularGame[indexPath.row].genre
                            self.startOperations(game: self.popularGame[indexPath.row], indexPath: indexPath)
                        }
                    }
                }
            }
        }
    }
}

//MARK: -HideKeyboardTapOutside
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
