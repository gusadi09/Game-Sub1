//
//  DetailScrollViewController.swift
//  Game Sub
//
//  Created by Gus Adi on 03/08/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

class DetailScrollViewController: UIViewController {
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var ratingGame: UILabel!
    @IBOutlet weak var releaseGame: UILabel!
    @IBOutlet weak var genreGame: UILabel!
    
    @IBOutlet weak var releaseView: UIView!
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var ratingView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        releaseView.layer.cornerRadius = 5
        genreView.layer.cornerRadius = 10
        ratingView.layer.cornerRadius = 10
        
        gameImage.layer.cornerRadius = 20
    }

    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
